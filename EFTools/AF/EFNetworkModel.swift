//
//  EFNetworkModel.swift
//  EFTools
//
//  Created by Brett Keck on 11/3/15.
//  Copyright © 2015 Brett Keck. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// Requires the following:
///
/// required convenience init(json: JSON)
/// - init method that takes in JSON data to initializes the model instance
///
/// func method() -> Alamofire.Method
/// - returns .GET, .POST, etc.
///
/// func path() -> String
/// - returns endpoint subpath, e.g. /api/user
///
/// func toDictionary() -> [String: AnyObject]?
/// - Returns nil for requests without parameters (like .GET requests), returns Dictionary of parameters otherwise
///
/// func headers() -> [String: AnyObject]?
/// - Returns nil for requests without added headers, returns Dictionary of headers otherwise
///
/// func patches() -> [[String: AnyObject]]?
/// - Returns nil for requests not using Patch, returns Array of Patch items otherwise
public protocol EFNetworkModel {
    /// init method that takes in JSON data to initialize the model instance
    init(json: JSON)
    
    /// Returns .GET, .POST, etc.
    func method() -> Alamofire.Method
    
    /// Returns endpoint subpath, e.g. /api/user
    func path() -> String
    
    /// Returns nil for requests without parameters (like .GET requests), returns Dictionary of parameters otherwise
    func toDictionary() -> [String: AnyObject]?
    
    /// Returns nil for requests without added headers, returns Dictionary of headers otherwise
    func headers() -> [String: AnyObject]?
    
    /// Returns nil for requests not using Patch, returns Array of Patch items otherwise
    func patches() -> [[String: AnyObject]]?
    
    /// Used to define what encoding to use
    var encoding: ParameterEncoding? { get set }
    
    /// Used for keeping track of what items to patch
    var patchAds: [String: AnyObject]? { get set }
    var patchRemoves: Set<String>? { get set }
}

extension EFNetworkModel {
    public mutating func patchItem<T: Comparable>(key: String, oldValue: T?, newValue: T?) {
        if oldValue != nil && newValue == nil {
            patchRemoves?.insert(key)
            patchAds?.removeValueForKey(key)
            return
        }
        
        if let newValue = newValue {
            if let oldValue = oldValue {
                if oldValue != newValue {
                    patchAds?[key] = newValue as? AnyObject
                }
            } else {
                patchAds?[key] = newValue as? AnyObject
            }
            patchRemoves?.remove(key)
        }
    }
    
    public mutating func resetPatch() {
        patchAds = [:]
        patchRemoves = []
    }
}