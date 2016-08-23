//
//  EFWebServices.swift
//  EFTools
//
//  Created by Brett Keck on 11/3/15.
//  Copyright © 2015 Brett Keck. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

/// EFWebProtocol - used to assure adherence to required and optional properties of EFWebServices
///
/// static func setBaseURL(url: String)
/// - Send in the baseURL for your app - do before making any network calls
/// - Example method body:
/// - self.shared.baseURL = "http://test.com
///
/// static func setAuthHeader(headerName: String) (optional)
/// - Used to change from the default "Authorization" header when sending an auth token
/// - Example method body:
/// - self.shared.authHeader = "Token"
///
/// static func setAuthPrefix(headerPrefix: String)  (optional)
/// - Used to change from the default "Bearer " prefix before the token
/// - Example method body:
/// - self.shared.authHeader = "token="
///
/// static func addHeaders(headers: [String: AnyObject])  (optional)
/// - Used to add headers to all calls
/// - Example method body:
/// - self.shared.headers = ["apiKey": "12345", "userID": 1]

///
/// static func addQueries(queries: [String: AnyObject])  (optional)
/// - Used to add headers to all calls
/// - Example method body:
/// - self.shared.queries = ["searchterm": "test", "page": 1]
@objc public protocol EFWebProtocol {
    /// Send in the baseURL for your app - do before making any network calls
    /// 
    /// Example method body:
    /// self.shared.baseURL = "http://test.com"
    static func setBaseURL(_ url: String)
    
    /// Used to change from the default "Authorization" header when sending an auth token
    ///
    /// Example method body:
    /// self.shared.authHeader = "Token"
    @objc optional static func setAuthHeader(_ headerName: String)
    
    /// Used to change from the default "Bearer " prefix before the token
    ///
    /// Example method body:
    /// self.shared.authHeader = "token="
    @objc optional static func setAuthPrefix(_ headerPrefix: String)
    
    /// Used to add headers to all calls
    ///
    /// Example method body:
    /// self.shared.headers = ["apiKey": "12345", "userID": 1]
    @objc optional static func addHeaders(_ headers: [String: AnyObject])
    
    /// Used to add queries to all calls
    ///
    /// Example method body:
    /// self.shared.queries = ["searchterm": "test", "page": 1]
    @objc optional static func addQueries(_ queries: [String: String])
}

/// EFWebServices - subclass this to use Alamofire with a built-in AuthRouter
/// Use in concert with the EFNetworkModel protocol
open class EFWebServices: NSObject {
    open static let shared = EFWebServices()
    
    fileprivate var _baseURL = ""
    fileprivate var _authHeader = "Authorization"
    fileprivate var _authPrefix = "Bearer "
    fileprivate var _headers: [String: AnyObject]?
    fileprivate var _queries: [String: String]?
    
    open var baseURL: String {
        get {
            return _baseURL
        }
        set {
            _baseURL = newValue
        }
    }
    
    open var authHeader: String {
        get {
            return _authHeader
        }
        set {
            _authHeader = newValue
        }
    }
    
    open var authPrefix: String {
        get {
            return _authPrefix
        }
        set {
            _authPrefix = newValue
        }
    }
    
    open var headers: [String: AnyObject]? {
        get {
            return _headers
        }
        set {
            _headers = newValue
        }
    }
    
    open var queries: [String: String]? {
        get {
            return _queries
        }
        set {
            _queries = newValue
        }
    }
    
    fileprivate var authToken: String? {
        get {
            if let authTokenString:String = KeychainWrapper.defaultKeychainWrapper().stringForKey("authToken") {
                return authTokenString
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                KeychainWrapper.defaultKeychainWrapper().setString(newValue!, forKey: "authToken")
            } else {
                KeychainWrapper.defaultKeychainWrapper().removeObjectForKey("authToken")
            }
        }
    }
    
    fileprivate var authTokenExpireDate: String? {
        // Storing in the iOS Keychain (for security purposes).
        get {
            if let authExpireDate:String = KeychainWrapper.defaultKeychainWrapper().stringForKey("authTokenExpireDate") {
                return authExpireDate
            } else {
                return nil
            }
        } set {
            if newValue != nil {
                KeychainWrapper.defaultKeychainWrapper().setString(newValue!, forKey: "authTokenExpireDate")
            }
            else {
                KeychainWrapper.defaultKeychainWrapper().removeObjectForKey("authTokenExpireDate")
            }
        }
    }
    
    open func setAuthToken(_ token: String?, expiration: String?) {
        authToken = token
        authTokenExpireDate = expiration
    }
    
    open func userAuthTokenExists() -> Bool {
        if self.authToken != nil {
            return true
        }
        else {
            return false
        }
    }
    
    open func userAuthTokenExpired() -> Bool {
        if self.authTokenExpireDate != nil {
            
            let dateFormatter = DateFormatter()
            // "Tue, 17 Mar 2015 20:04:53 GMT"
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            
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
    
    open func clearUserAuthToken() -> Void {
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
        
        public var URLRequest: NSMutableURLRequest {
            
            switch self {
            case .efRequest(let model):
                let URL = Foundation.URL(string: AuthRouter.baseURLString)!
                
                let mutableURLRequest = NSMutableURLRequest(URL: URL.appendingPathComponent(model.path()))
                
                mutableURLRequest.HTTPMethod = model.method().rawValue
                
                if let token = EFWebServices.shared.authToken {
                    mutableURLRequest.setValue("\(AuthRouter.authPrefix)\(token)", forHTTPHeaderField: AuthRouter.authHeader)
                }
                
                if let headers = EFWebServices.shared.headers {
                    for header in headers {
                        mutableURLRequest.addValue("\(header.1)", forHTTPHeaderField: "\(header.0)")
                    }
                }
                
                if let headers = model.headers() {
                    for header in headers {
                        mutableURLRequest.addValue("\(header.1)", forHTTPHeaderField: "\(header.0)")
                    }
                }
                
                if let queries = EFWebServices.shared.queries {
                    return ParameterEncoding.URL.encode(mutableURLRequest, parameters: queries).0
                }
                
                if let params = model.patches() {
                    mutableURLRequest.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                if let params = model.toDictionary() {
                    if let encoding = model.encoding {
                        return encoding.encode(mutableURLRequest, parameters: params).0
                    } else if model.method() == .GET {
                        return ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
                    } else {
                        return ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
                    }
                }
                
                return mutableURLRequest
            }
        }
    }
    
    
    // MARK: - Network Check
    open func networkCheck() -> Bool {
        return IJReachability.isConnectedToNetwork()
    }
    
    
    // MARK: - Auth methods
    open func authenticateUser<T: EFNetworkModel>(_ user: T, completion:@escaping (_ user: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, EFConstants.noInternetConnection)
            return
        }
        
        request(user.method(), EFWebServices.shared._baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, jsonObject, error) in
                EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    open func authenticateUser<T: EFNetworkModel>(_ user: T, completion:@escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, nil, NSError(domain: EFConstants.noInternetConnection, code: 0, userInfo: nil))
            return
        }
        
        request(user.method(), EFWebServices.shared._baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, jsonObject, error) in
                completion(request: request, response: response, data: jsonObject, error: error)
        }
    }
    
    
    // MARK: - Register methods
    open func registerUser<T: EFNetworkModel>(_ user: T, completion:@escaping (_ user: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, EFConstants.noInternetConnection)
            return
        }
        
        request(user.method(), EFWebServices.shared._baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, jsonObject, error) in
                EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    open func registerUser<T: EFNetworkModel>(_ user: T, completion:@escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, nil, NSError(domain: EFConstants.noInternetConnection, code: 0, userInfo: nil))
            return
        }
        
        request(user.method(), EFWebServices.shared._baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, jsonObject, error) in
                completion(request: request, response: response, data: jsonObject, error: error)
        }
    }
    
    
    // MARK: - Reset Password methods
    open func resetPassword<T: EFNetworkModel>(_ user: T, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(false, EFConstants.noInternetConnection)
            return
        }
        
        request(user.method(), EFWebServices.shared.baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, jsonObject, error) in
                var success = false
                var errorString: String?
                if let status = response?.statusCode {
                    switch status {
                    case 200:
                        success = true
                    case 400:
                        if let json = jsonObject, let string = String(data: json, encoding: NSUTF8StringEncoding) {
                            errorString = string
                        } else {
                            errorString = EFConstants.objectNotFound
                        }
                    case 500:
                        errorString = EFConstants.internalError
                    default:
                        errorString = EFConstants.unknownError
                    }
                } else {
                    errorString = EFConstants.unknownError
                }
                completion(success: success, error: errorString)
        }
    }
    
    open func resetPassword<T: EFNetworkModel>(_ user: T, completion:@escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, nil, NSError(domain: EFConstants.noInternetConnection, code: 0, userInfo: nil))
            return
        }
        
        request(user.method(), EFWebServices.shared.baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, jsonObject, error) in
                completion(request: request, response: response, data: jsonObject, error: error)
        }
    }
    
    
    // MARK: - Generic Post Methods
    open func postObject<T: EFNetworkModel>(_ newObject: T, completion:@escaping (_ object: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, EFConstants.noInternetConnection)
            return
        }
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) -> Void in
            EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    open func postObject<T: EFNetworkModel>(_ newObject: T, completion:@escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, nil, NSError(domain: EFConstants.noInternetConnection, code: 0, userInfo: nil))
            return
        }
        
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) in
            completion(request: request, response: response, data: jsonObject, error: error)
        }
    }
    
    
    // MARK: - Generic Delete Methods
    open func deleteObject<T: EFNetworkModel>(_ newObject: T, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(false, EFConstants.noInternetConnection)
            return
        }
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) -> Void in
            var errorString: String?
            var success = false
            if let status = response?.statusCode {
                switch status {
                case 200:
                    success = true
                case 400:
                    if let json = jsonObject, let string = String(data: json, encoding: NSUTF8StringEncoding) {
                        errorString = string
                    } else {
                        errorString = EFConstants.badRequest
                    }
                case 500:
                    if let json = jsonObject, let string = String(data: json, encoding: NSUTF8StringEncoding) {
                        errorString = string
                    } else {
                        errorString = EFConstants.internalError
                    }
                default:
                    errorString = error?.description ?? EFConstants.unknownError
                }
            } else {
                errorString = error?.description ?? EFConstants.unknownError
            }
            
            completion(success: success, error: errorString)
        }
    }
    
    open func deleteObject<T: EFNetworkModel>(_ newObject: T, completion:@escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, nil, NSError(domain: EFConstants.noInternetConnection, code: 0, userInfo: nil))
            return
        }
        
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) in
            completion(request: request, response: response, data: jsonObject, error: error)
        }
    }
    
    
    // MARK: - Generic Get Methods
    open func getObject<T: EFNetworkModel>(_ newObject: T, completion: @escaping (_ object: T?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, EFConstants.noInternetConnection)
            return
        }
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) -> Void in
            EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    open func getObject<T: EFNetworkModel>(_ newObject: T, completion:@escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, nil, NSError(domain: EFConstants.noInternetConnection, code: 0, userInfo: nil))
            return
        }
        
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) in
            completion(request: request, response: response, data: jsonObject, error: error)
        }
    }
    
    open func getObjects<T: EFNetworkModel>(_ object: T, completion: @escaping (_ objects: [T]?, _ error: String?) -> Void) {
        if !networkCheck() {
            completion(nil, EFConstants.noInternetConnection)
            return
        }
        
        request(AuthRouter.EFRequest(object)).response { (request, response, jsonObject, error) -> Void in
            EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    open func getObjects<T: EFNetworkModel>(_ newObject: T, completion:@escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
        if !networkCheck() {
            completion(nil, nil, nil, NSError(domain: EFConstants.noInternetConnection, code: 0, userInfo: nil))
            return
        }
        
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) in
            completion(request: request, response: response, data: jsonObject, error: error)
        }
    }
    
    
    // MARK: - Generic Response Processing Methods
    class func processResponse<T: EFNetworkModel>(_ response: HTTPURLResponse?, jsonObject: Data?, error: NSError?, completion: (_ object: T?, _ error: String?) -> Void) {
        var errorString: String?
        var object: T?
        if let status = response?.statusCode {
            switch status {
            case 200:
                if let json = jsonObject {
                    object = T(json: JSON(data: json))
                } else {
                    errorString = EFConstants.unknownError
                }
            case 201:
                if let json = jsonObject {
                    object = T(json: JSON(data: json))
                } else {
                    errorString = EFConstants.unknownError
                }
            case 400:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.badRequest
                }
            case 402:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.badUsernamePassword
                }
            case 403:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.unauthorized
                }
            case 404:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.objectNotFound
                }
            case 500:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.internalError
                }
            default:
                errorString = error?.description ?? EFConstants.unknownError
            }
        } else {
            errorString = error?.description ?? EFConstants.unknownError
        }
        
        completion(object, errorString)
    }
    
    class func processResponse<T: EFNetworkModel>(_ response: HTTPURLResponse?, jsonObject: Data?, error: NSError?, completion: (_ objects: [T]?, _ error: String?) -> Void) {
        var errorString: String?
        var objects: [T]?
        if let status = response?.statusCode {
            switch status {
            case 200, 201:
                if let json = jsonObject {
                    let jsonArray = JSON(data:json)
                    objects = []
                    if let array = jsonArray.array {
                        for object in array {
                            objects?.append(T(json: object))
                        }
                    }
                } else {
                    objects = []
                }
            case 400:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.badRequest
                }
            case 402:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.badUsernamePassword
                }
            case 403:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.unauthorized
                }
            case 404:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.objectNotFound
                }
            case 500:
                if let json = jsonObject, let string = String(data: json, encoding: String.Encoding.utf8) {
                    errorString = string
                } else {
                    errorString = EFConstants.internalError
                }
            default:
                errorString = error?.description ?? EFConstants.unknownError
            }
        } else {
            errorString = error?.description ?? EFConstants.unknownError
        }
        
        completion(objects, errorString)
    }
}
