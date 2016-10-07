//
//  EFWebServices.swift
//  EFTools
//
//  Created by Brett Keck on 11/3/15.
//  Copyright © 2015 Brett Keck. All rights reserved.
//

import UIKit
import Alamofire
import Freddy
import Valet

/// EFWebServices - extend this to use Alamofire with a built-in AuthRouter
/// Use in concert with the EFNetworkModel protocol
open class EFWebServices: NSObject {
    public static let shared = EFWebServices()
    
    fileprivate var _baseURL = ""
    fileprivate var _authHeader = "Authorization"
    fileprivate var _authPrefix = "Bearer "
    fileprivate var _headers: [String: AnyObject]?
    fileprivate var _queries: [String: String]?
    fileprivate var _dateFormat = "YYYY-MM-DD'T'hh:mm:ssZ"
    fileprivate var _keychainIdentifier = "EFToolsID"
    
    /// Send in the baseURL for your app - do before making any network calls
    ///
    /// Example call:
    /// EFWebservices.shared.baseURL = "http://test.com"
    public var baseURL: String {
        get {
            return _baseURL
        }
        set {
            _baseURL = newValue
        }
    }
    
    /// Used to change from the default "Authorization" header when sending an auth token
    ///
    /// Example call:
    /// EFWebServices.shared.authHeader = "Token "
    public var authHeader: String {
        get {
            return _authHeader
        }
        set {
            _authHeader = newValue
        }
    }
    
    /// Used to change from the default "Bearer " prefix before the token
    ///
    /// Example call:
    /// EFWebServices.shared.authHeader = "token="
    public var authPrefix: String {
        get {
            return _authPrefix
        }
        set {
            _authPrefix = newValue
        }
    }
    
    /// Used to add headers to all calls
    ///
    /// Example call:
    /// EFWebServices.shared.headers = ["apiKey": "12345", "userID": 1]
    public var headers: [String: AnyObject]? {
        get {
            return _headers
        }
        set {
            _headers = newValue
        }
    }
    
    /// Used to add queries to all calls
    ///
    /// Example call:
    /// EFWebServices.shared.queries = ["searchterm": "test", "page": 1]
    public var queries: [String: String]? {
        get {
            return _queries
        }
        set {
            _queries = newValue
        }
    }
    
    /// Define the date format for your app
    /// Default is "YYYY-MM-DD'T'hh:mm:ssZ"
    ///
    /// Example call:
    /// EFWebServices.shared.dateFormat = "YYYY-MM-DD'T'hh:mmZ"
    public var dateFormat: String {
        get {
            return _dateFormat
        }
        set {
            _dateFormat = newValue
        }
    }
    
    /// Send in the date Format for your app - do before making any network calls
    /// Default is "EFToolsID"
    ///
    /// Example call:
    /// EFWebServices.shared.keychainIdentifier = "MYAppID"
    public var keychainIdentifier: String {
        get {
            return _keychainIdentifier
        }
        set {
            _keychainIdentifier = newValue
        }
    }
    
    fileprivate var authToken: String? {
        get {
            let myValet = VALValet(identifier: _keychainIdentifier, accessibility: .whenUnlocked)
            
            if let authTokenString = myValet?.string(forKey: EFConstants.authToken) {
                return authTokenString
            } else {
                return nil
            }
        }
        set {
            let myValet = VALValet(identifier: _keychainIdentifier, accessibility: .whenUnlocked)
            
            if let newValue = newValue {
                myValet?.setString(newValue, forKey: EFConstants.authToken)
            } else {
                myValet?.removeObject(forKey: EFConstants.authToken)
            }
        }
    }
    
    fileprivate var authTokenExpireDate: String? {
        get {
            let myValet = VALValet(identifier: _keychainIdentifier, accessibility: .whenUnlocked)
            
            if let authExpireDate = myValet?.string(forKey: EFConstants.authTokenExpireDate) {
                return authExpireDate
            } else {
                return nil
            }
        } set {
            let myValet = VALValet(identifier: _keychainIdentifier, accessibility: .whenUnlocked)
            
            if let newValue = newValue {
                myValet?.setString(newValue, forKey: EFConstants.authTokenExpireDate)
            } else {
                myValet?.removeObject(forKey: EFConstants.authTokenExpireDate)
            }
        }
    }
    
    public func setAuthToken(_ token: String?, expiration: String?) {
        authToken = token
        authTokenExpireDate = expiration
    }
    
    public func userAuthTokenExists() -> Bool {
        if self.authToken != nil {
            return true
        }
        else {
            return false
        }
    }
    
    public func userAuthTokenExpired() -> Bool {
        if self.authTokenExpireDate != nil {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = _dateFormat
            
            let dateString = self.authTokenExpireDate!
            let expireDate = dateFormatter.date(from: dateString)!
            
            let hourFromNow = Date().addingTimeInterval(3600)
            
            if expireDate.compare(hourFromNow) == ComparisonResult.orderedAscending {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    public func clearUserAuthToken() -> Void {
        if self.userAuthTokenExists() {
            self.authToken = nil
        }
    }
    
    public enum AuthRouter: URLRequestConvertible {
        static var baseURLString = EFWebServices.shared._baseURL
        static var authHeader = EFWebServices.shared._authHeader
        static var authPrefix = EFWebServices.shared._authPrefix
        static var OAuthToken: String?
        
        case efRequest(EFNetworkModel)
        
        public func asURLRequest() throws -> URLRequest {
            let URL = try AuthRouter.baseURLString.asURL()
            var urlRequest: URLRequest
            
            switch self {
            case .efRequest(let model):
                urlRequest = URLRequest(url: URL.appendingPathComponent(model.path()))
                
                urlRequest.httpMethod = model.method().rawValue
                
                if let token = EFWebServices.shared.authToken {
                    urlRequest.setValue("\(AuthRouter.authPrefix) \(token)", forHTTPHeaderField: AuthRouter.authHeader)
                }
                
                if let headers = EFWebServices.shared.headers {
                    for header in headers {
                        urlRequest.addValue("\(header.1)", forHTTPHeaderField: "\(header.0)")
                    }
                }
                
                if let headers = model.headers() {
                    for header in headers {
                        urlRequest.addValue("\(header.1)", forHTTPHeaderField: "\(header.0)")
                    }
                }
                
                if let queries = EFWebServices.shared.queries {
                    return try! URLEncoding.default.encode(urlRequest, with: queries)
                }
                
                if let params = model.patches() {
                    urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                if let params = model.toDictionary() {
                    if let encoding = model.encoding {
                        return try! encoding.encode(urlRequest, with: params)
                    } else if model.method() == .get {
                        return try! URLEncoding.default.encode(urlRequest, with: params)
                    } else {
                        return try! JSONEncoding.default.encode(urlRequest, with: params)
                    }
                }
                
                return urlRequest
            }
        }
    }
    
    
    // MARK: - Network Check
    open func networkCheck() -> Bool {
        return IJReachability.isConnectedToNetwork()
    }
    
    
    // MARK: - Auth method
    open func authenticateUser<T: EFNetworkModel>(_ user: T, autoParse: Bool = true, completion:@escaping (_ response: DataResponse<Any>?, _ user: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, EFConstants.noInternetConnection)
            return
        }
        
        request(EFWebServices.shared._baseURL + user.path(), method: user.method(), parameters: user.toDictionary(), encoding: URLEncoding.default)
            .responseJSON { (response) -> Void in
                if autoParse {
                    EFWebServices.parseResponseObject(response, completion: completion)
                } else {
                    completion(response, nil, nil)
                }
        }
    }
    
    
    // MARK: - Register methods
    open func registerUser<T: EFNetworkModel>(_ user: T, autoParse: Bool = true, completion:@escaping (_ response: DataResponse<Any>?, _ user: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, EFConstants.noInternetConnection)
            return
        }
        
        request(EFWebServices.shared._baseURL + user.path(), method: user.method(), parameters: user.toDictionary(), encoding: URLEncoding.default)
            .responseJSON { (response) -> Void in
                if autoParse {
                    EFWebServices.parseResponseObject(response, completion: completion)
                } else {
                    completion(response, nil, nil)
                }
        }
    }
    
    
    // MARK: - Generic Post Methods
    open func postObject<T: EFNetworkModel>(_ newObject: T, autoParse: Bool = true, completion:@escaping (_ response: DataResponse<Any>?, _ object: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, EFConstants.noInternetConnection)
            return
        }
        request(AuthRouter.efRequest(newObject)).responseJSON { (response) -> Void in
            EFWebServices.parseResponseObject(response, completion: completion)
        }
    }
    
    
    // MARK: - Generic Delete Methods
    open func deleteObject<T: EFNetworkModel>(_ newObject: T, autoParse: Bool = true, completion:@escaping (_ response: DataResponse<Any>?, _ object: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, EFConstants.noInternetConnection)
            return
        }
        request(AuthRouter.efRequest(newObject)).responseJSON { (response) -> Void in
            EFWebServices.parseResponseObject(response, completion: completion)
        }
    }
    
    
    // MARK: - Generic Get Methods
    open func getObject<T: EFNetworkModel>(_ newObject: T, autoParse: Bool = true, completion: @escaping (_ response: DataResponse<Any>?, _ object: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, EFConstants.noInternetConnection)
            return
        }
        request(AuthRouter.efRequest(newObject)).responseJSON { (response) -> Void in
            EFWebServices.parseResponseObject(response, completion: completion)
        }
    }
    
    open func getObjects<T: EFNetworkModel>(_ object: T, autoParse: Bool = true, completion: @escaping (_ response: DataResponse<Any>?, _ objects: [T]?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, EFConstants.noInternetConnection)
            return
        }
        
        request(AuthRouter.efRequest(object)).responseJSON { (response) -> Void in
            EFWebServices.parseResponseObjects(response, completion: completion)
        }
    }
    
    
    // MARK: - Generic Response Processing Methods
    class func parseResponseObject<T: EFNetworkModel>(_ response: DataResponse<Any>, completion: (_ response: DataResponse<Any>?, _ object: T?, _ error: String?) -> Void) {
        var object: T?
        
        guard case .success(_) = response.result, let data = response.data else {
            if let statusCode = response.response?.statusCode, statusCode >= 200, statusCode < 300 {
                completion(response, T(), nil)
            } else {
                completion(response, nil, parseError(response))
            }
            return
        }
        
        do {
            let json = try JSON(data: data)
            object = try T(json: json)
            
            completion(response, object, nil)
        } catch {
            completion(response, nil, EFConstants.processingError)
        }
    }
    
    class func parseResponseObjects<T: EFNetworkModel>(_ response: DataResponse<Any>, completion: (_ response: DataResponse<Any>?, _ objects: [T]?, _ error: String?) -> Void) {
        var errorString: String?
        var objects: [T]?
        
        guard case .success(_) = response.result, let data = response.data else {
            completion(response, nil, parseError(response))
            return
        }
        
        do {
            let json = try JSON(data: data)
            let theObjects = try json.getArray().map(T.init)
            objects = theObjects
        } catch {
            errorString = EFConstants.processingError
        }
        
        completion(response, objects, errorString)
    }
    
    class func parseError(_ response: DataResponse<Any>) -> String? {
        guard case let .failure(error) = response.result else {
            return EFConstants.unknownError
        }
        
        var errorString: String?
        
        if let error = error as? AFError {
            switch error {
            case .invalidURL(let url):
                errorString = "Invalid URL: \(url) - \(error.localizedDescription)"
            case .parameterEncodingFailed(let reason):
                errorString = "Parameter encoding failed: \(error.localizedDescription).  Failure Reason: \(reason)"
            case .multipartEncodingFailed(let reason):
                errorString = "Multipart encoding failed: \(error.localizedDescription).  Failure Reason: \(reason)"
            case .responseValidationFailed(let reason):
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    errorString = "Response validation failed: \(error.localizedDescription).  Downloaded file could not be read"
                case .missingContentType(let acceptableContentTypes):
                    errorString = "Response validation failed: \(error.localizedDescription).  Content Type Missing: \(acceptableContentTypes)"
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    errorString = "Response validation failed: \(error.localizedDescription).  Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                case .unacceptableStatusCode(let code):
                    errorString = "Response validation failed: \(error.localizedDescription).  Response status code was unacceptable: \(code)"
                }
            case .responseSerializationFailed(let reason):
                errorString = "Response serialization failed: \(error.localizedDescription).  Failure Reason: \(reason)"
            }
        } else if let error = error as? URLError {
            errorString = "URLError occurred: \(error)"
        } else {
            errorString = "Unknown error: \(error)"
        }
        
        return errorString
    }
}
