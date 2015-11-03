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

/// Requires:
///
/// var baseURL : String
/// - this will set the base url for all network operations
public protocol EFWebProtocol {
    var baseURL : String {get set}
}

public class EFWebServices: NSObject {
//    public static let shared = EFWebServices()
    private var _baseURL = ""
    
    var baseURL : String {
        get {
            return _baseURL
        }
        set {
            _baseURL = newValue
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
    
    public func urlTest() {
        print(_baseURL)
    }
    
    public enum AuthRouter: URLRequestConvertible {
        static var baseURLString = EFWebServices.shared._baseURL
        static var OAuthToken: String?
        
        case EFRequest(EFNetworkModel)
        
        var URLRequest: NSMutableURLRequest {
            
            switch self {
            case .EFRequest(let model):
                let URL = NSURL(string: AuthRouter.baseURLString)!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(model.path()))
                mutableURLRequest.HTTPMethod = model.method().rawValue
                
                if let token = EFWebServices.shared.authToken {
                    mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                
                if let params = model.toDictionary() {
                    return ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
                }
                return mutableURLRequest
            }
        }
    }
}
