//
//  UIColorExtension.swift
//  EFTools
//
//  Created by Brett Keck on 7/29/15.
//  Copyright (c) 2015 Brett Keck. All rights reserved.
//

import Foundation

/// This extension allows easier creation of colors by passing in integer values for colors
/// It performs the division by 255 for each color value
///
/// red, green and blue values will range from 0-255
/// alpha value will range from 0.0 to 1.0
extension UIColor {
    class func rgba(red: NSInteger, green: NSInteger, blue: NSInteger, alpha: Float) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha))
    }
    
    class func rgb(red: NSInteger, green: NSInteger, blue: NSInteger) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
}