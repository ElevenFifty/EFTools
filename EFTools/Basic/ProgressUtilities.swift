//
//  ProgressUtilities.swift
//  EFTools
//
//  Created by Brett Keck on 7/31/15.
//  Copyright (c) 2015 Brett Keck. All rights reserved.
//

import Foundation

class ProgressUtilities {
    
    private static var hud : MBProgressHUD?
    
    class func showSpinner(superView : UIView) {
        if let thisHud = hud {
            thisHud.hide(false)
            hud = nil
        }
        hud = MBProgressHUD.showHUDAddedTo(superView, animated: true)
    }
    
    class func showSpinner(superView : UIView, title : String) {
        if let thisHud = hud {
            thisHud.hide(false)
            hud = nil
        }
        hud = MBProgressHUD.showHUDAddedTo(superView, animated: true)
        hud!.labelText = title
    }
    
    class func hideSpinner() {
        if let thisHud = hud {
            thisHud.hide(true)
        }
    }
    
    class func getHud() -> MBProgressHUD? {
        return hud
    }
}