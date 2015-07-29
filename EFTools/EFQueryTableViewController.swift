//
//  EFQueryTableViewController.swift
//  EFTools
//
//  Created by Brett Keck on 7/28/15.
//  Copyright (c) 2015 Brett Keck. All rights reserved.
//

import UIKit
import ParseUI

class EFQueryTableViewController: PFQueryTableViewController {
    let efCellAnimation = EFCellAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Call this function to change the Translate Distance for a Translate or TranslateFade animation
    ///
    /// Default is 50
    internal func setTranslateDistance(distance : Int) {
        efCellAnimation.setTranslateDistance(distance)
    }
    
    /// Call this function to change the cell presentation animation
    ///
    /// - None: Normal loading of cell, no effects
    /// - Translate: Cell slides in from the right, with no alpha fading
    /// - TranslateFade: Cell slides in from the right and fades in
    /// - Fade: Cell fades in with no motion effect
    ///
    /// Default is .None
    internal func setCellType(cellType : CellType) {
        efCellAnimation.setCellType(cellType)
    }
    
    /// Call this function to change the cell presentation animation time
    ///
    /// Default is 0.4
    internal func setDuration(duration : Double) {
        efCellAnimation.setDuration(duration)
    }
    
    /// Call this function to change the initial alpha value for any Fade or TranslateFade animation
    ///
    /// Ranges from 0.0 to 1.0, defaults to 0.0
    internal func setInitialAlpha(alpha : Double) {
        efCellAnimation.setInitialAlpha(alpha)
    }
    
    /// This function will be called by parse and will reset the previous index array.
    /// If you override this function, always call super.objectsWillLoad()
    override func objectsWillLoad() {
        efCellAnimation.resetPrevIndexes()
        super.objectsWillLoad()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        efCellAnimation.setupAnimation(indexPath, cell: cell)
    }
}