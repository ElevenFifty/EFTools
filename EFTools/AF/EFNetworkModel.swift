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
/// func toDictionary() -> [String : AnyObject]?
/// - Returns nil for requests without parameters (like .GET requests), returns Dictionary of parameters otherwise
protocol EFNetworkModel {
    /// init method that takes in JSON data to initialize the model instance
    init(json: JSON)
    
    /// Returns .GET, .POST, etc.
    func method() -> Alamofire.Method
    
    /// Returns endpoint subpath, e.g. /api/user
    func path() -> String
    
    /// Returns nil for requests without parameters (like .GET requests), returns Dictionary of parameters otherwise
    func toDictionary() -> [String : AnyObject]?
}