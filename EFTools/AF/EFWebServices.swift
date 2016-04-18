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
/// static func addHeaders(headers: [String : AnyObject])  (optional)
/// - Used to add headers to all calls
/// - Example method body:
/// - self.shared.headers = ["apiKey" : "12345", "userID" : 1]

///
/// static func addQueries(queries: [String : AnyObject])  (optional)
/// - Used to add headers to all calls
/// - Example method body:
/// - self.shared.queries = ["searchterm" : "test", "page" : 1]
@objc public protocol EFWebProtocol {
    /// Send in the baseURL for your app - do before making any network calls
    /// 
    /// Example method body:
    /// self.shared.baseURL = "http://test.com
    static func setBaseURL(url: String)
    
    /// Used to change from the default "Authorization" header when sending an auth token
    ///
    /// Example method body:
    /// self.shared.authHeader = "Token"
    optional static func setAuthHeader(headerName: String)
    
    /// Used to change from the default "Bearer " prefix before the token
    ///
    /// Example method body:
    /// self.shared.authHeader = "token="
    optional static func setAuthPrefix(headerPrefix: String)
    
    /// Used to add headers to all calls
    ///
    /// Example method body:
    /// self.shared.headers = ["apiKey" : "12345", "userID" : 1]
    optional static func addHeaders(headers: [String : AnyObject])
    
    /// Used to add queries to all calls
    ///
    /// Example method body:
    /// self.shared.queries = ["searchterm" : "test", "page" : 1]
    optional static func addQueries(queries: [String : String])
}

/// EFWebServices - subclass this to use Alamofire with a built-in AuthRouter
/// Use in concert with the EFNetworkModel protocol
public class EFWebServices: NSObject {
    public static let shared = EFWebServices()
    
    private var _baseURL = ""
    private var _authHeader = "Authorization"
    private var _authPrefix = "Bearer "
    private var _headers : [String : AnyObject]?
    private var _queries : [String : String]?
    
    public var baseURL : String {
        get {
            return _baseURL
        }
        set {
            _baseURL = newValue
        }
    }
    
    public var authHeader : String {
        get {
            return _authHeader
        }
        set {
            _authHeader = newValue
        }
    }
    
    public var authPrefix : String {
        get {
            return _authPrefix
        }
        set {
            _authPrefix = newValue
        }
    }
    
    public var headers : [String : AnyObject]? {
        get {
            return _headers
        }
        set {
            _headers = newValue
        }
    }
    
    public var queries : [String : String]? {
        get {
            return _queries
        }
        set {
            _queries = newValue
        }
    }
    
    private var authToken: String? {
        get {
            if let authTokenString:String = KeychainWrapper.stringForKey("authToken") {
                return authTokenString
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                KeychainWrapper.setString(newValue!, forKey: "authToken")
            } else {
                KeychainWrapper.removeObjectForKey("authToken")
            }
        }
    }
    
    private var authTokenExpireDate: String? {
        // Storing in the iOS Keychain (for security purposes).
        get {
            if let authExpireDate:String = KeychainWrapper.stringForKey("authTokenExpireDate") {
                return authExpireDate
            } else {
                return nil
            }
        } set {
            if newValue != nil {
                KeychainWrapper.setString(newValue!, forKey: "authTokenExpireDate")
            }
            else {
                KeychainWrapper.removeObjectForKey("authTokenExpireDate")
            }
        }
    }
    
    public func setAuthToken(token: String?, expiration: String?) {
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
            
            let dateFormatter = NSDateFormatter()
            // "Tue, 17 Mar 2015 20:04:53 GMT"
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            
            let dateString = self.authTokenExpireDate!
            let expireDate = dateFormatter.dateFromString(dateString)!
            
            let hourFromNow = NSDate().dateByAddingTimeInterval(3600)
            
            if expireDate.compare(hourFromNow) == NSComparisonResult.OrderedAscending {
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
        
        case EFRequest(EFNetworkModel)
        
        public var URLRequest: NSMutableURLRequest {
            
            switch self {
            case .EFRequest(let model):
                let URL = NSURL(string: AuthRouter.baseURLString)!
                
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(model.path()))
                
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
                    mutableURLRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                if let params = model.toDictionary() {
                    if model.method() == .GET {
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
    public func networkCheck() -> Bool {
        return IJReachability.isConnectedToNetwork()
    }
    
    
    // MARK: - Auth methods
    public func authenticateUser<T: EFNetworkModel>(user: T, completion:(user: T?, error: String?) -> ()) {
        if !networkCheck() {
            completion(user: nil, error: EFConstants.noInternetConnection)
            return
        }
        
        request(user.method(), EFWebServices.shared._baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, jsonObject, error) in
                EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    public func registerUser<T: EFNetworkModel>(user: T, completion:(user: T?, error: String?) -> ()) {
        if !networkCheck() {
            completion(user: nil, error: EFConstants.noInternetConnection)
            return
        }
        
        request(user.method(), EFWebServices.shared._baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, jsonObject, error) in
                EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    public func resetPassword<T: EFNetworkModel>(user: T, completion: (success: Bool, error: String?) -> ()) {
        if !networkCheck() {
            completion(success: false, error: EFConstants.noInternetConnection)
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
                        if let json = jsonObject, string = String(data: json, encoding: NSUTF8StringEncoding) {
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
    
    // MARK: - Generic Methods
    public func postObject<T: EFNetworkModel>(newObject: T, completion:(object: T?, error: String?) -> Void) {
        if !networkCheck() {
            completion(object: nil, error: EFConstants.noInternetConnection)
            return
        }
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) -> Void in
            EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    public func deleteObject<T: EFNetworkModel>(newObject: T, completion:(success: Bool, error: String?) -> Void) {
        if !networkCheck() {
            completion(success: false, error: EFConstants.noInternetConnection)
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
                    if let json = jsonObject, string = String(data: json, encoding: NSUTF8StringEncoding) {
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
    
    public func getObject<T: EFNetworkModel>(newObject: T, completion: (object: T?, error: String?) -> Void) {
        if !networkCheck() {
            completion(object: nil, error: EFConstants.noInternetConnection)
            return
        }
        request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) -> Void in
            EFWebServices.processResponse(response, jsonObject: jsonObject, error: error, completion: completion)
        }
    }
    
    public func getObjects<T: EFNetworkModel>(object: T, completion: (objects: [T]?, error: String?) -> Void) {
        if !networkCheck() {
            completion(objects: nil, error: EFConstants.noInternetConnection)
            return
        }
        
        request(AuthRouter.EFRequest(object)).response { (request, response, jsonObject, error) -> Void in
            var errorString: String?
            var objects: [T]?
            
            if let status = response?.statusCode {
                switch status {
                case 200:
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
                    if let json = jsonObject, string = String(data: json, encoding: NSUTF8StringEncoding) {
                        errorString = string
                    } else {
                        errorString = EFConstants.objectNotFound
                    }
                case 500:
                    if let json = jsonObject, string = String(data: json, encoding: NSUTF8StringEncoding) {
                        errorString = string
                    } else {
                        errorString = EFConstants.internalError
                    }
                default:
                    errorString = EFConstants.unknownError
                }
            } else {
                errorString = EFConstants.unknownError
            }
            
            completion(objects: objects, error: errorString)
        }
    }
    
    class func processResponse<T: EFNetworkModel>(response: NSHTTPURLResponse?, jsonObject: NSData?, error: NSError?, completion: (object: T?, error: String?) -> Void) {
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
                if let json = jsonObject, let string = String(data: json, encoding: NSUTF8StringEncoding) {
                    errorString = string
                } else {
                    errorString = EFConstants.badRequest
                }
            case 402:
                if let json = jsonObject, string = String(data: json, encoding: NSUTF8StringEncoding) {
                    errorString = string
                } else {
                    errorString = EFConstants.badUsernamePassword
                }
            case 403:
                if let json = jsonObject, string = String(data: json, encoding: NSUTF8StringEncoding) {
                    errorString = string
                } else {
                    errorString = EFConstants.unauthorized
                }
            case 404:
                if let json = jsonObject, string = String(data: json, encoding: NSUTF8StringEncoding) {
                    errorString = string
                } else {
                    errorString = EFConstants.objectNotFound
                }
            case 500:
                if let json = jsonObject, string = String(data: json, encoding: NSUTF8StringEncoding) {
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
        
        completion(object: object, error: errorString)
    }
}
