//
//  EFQueryTableViewController.swift
//  EFTools
//
//  Created by Brett Keck on 7/28/15.
//  Copyright (c) 2015 Brett Keck. All rights reserved.
//

import UIKit
import ParseUI

/// This class subclasses PFQueryTableViewController. Important functions to override are as follows:
///
/// func queryForTable() -> PFQuery
///
/// - This function will provide a way for you to pass a query to PFQueryTableViewController to get your data
/// 
/// func objectsWillLoad()
///
/// - Override this function to perform any operations you want to perform before Parse calls your query
/// - Always call super.objectsWillLoad() in this function
///
/// func objectsDidLoad(error: NSError?)
///
/// - Override this function to perform operations when Parse returns the dataset from your query
/// - Can access the data returned by referencing self.objects()
/// - Can provide any implementations in case an error is returned here
/// - Always call super.objectsDidLoad(error) in this function
///
/// func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell?
///
/// - Use this instead of the default UITableViewController cellForRowAtIndexPath function that returns a UITableViewCell
/// - can access the current object for this indexPath by using the object parameter
///
///
/// The following are important functions to use for cell animations:
///
/// setTranslateDistance(distance : Int)
///
/// - Call this function to change the Translate Distance for a Translate animation.  Default is 50.
///
/// setCellType(cellTypes : Set<CellType>)
///
/// - Call this function to change the cell presentation animation
/// - None: Normal loading of cell, no effects
/// - Translate: Cell slides in from the right, with no alpha fading
/// - Fade: Cell fades in with no motion effect
/// - Scale: Cell scales from a larger or smaller size
/// - Default is [.None]
///
/// setShowType(showType : ShowType)
///
/// - Call this function to change when cells are animated
/// - Always: Every time a cell becomes visible
/// - Reload: The first time a cell becomes visible, and reset if tableview is reloaded
/// - Once: The first time a cell becomes visible, does not reset on reload
/// - Default is .Reload
///
/// setDuration(duration : Double)
///
/// - Call this function to change the cell presentation animation time.
/// - Default is 0.4
///
/// setInitialAlpha(alpha : Double)
///
/// - Call this function to change the initial alpha value for any Fade animation.  Ranges from 0.0 to 1.0, defaults to 0.0
///
/// setInitialScale(xscale : Double, yscale : Double)
///
/// - Call this function to change the initial scale value for any Scale animation.
/// - Default for each is 0.8


public class EFQueryTableViewController: PFQueryTableViewController {
    let efCellAnimation = EFCellAnimation()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Call this function to change the Translate Distance for a Translate animation
    ///
    /// Default is 50
    public func setTranslateDistance(distance : Int) {
        efCellAnimation.setTranslateDistance(distance)
    }
    
    /// Call this function to change the cell presentation animation
    ///
    /// - None: Normal loading of cell, no effects
    /// - Translate: Cell slides in from the right, with no alpha fading
    /// - Fade: Cell fades in with no motion effect
    /// - Scale: Cell scales from a larger or smaller size
    ///
    /// Default is [.None]
    public func setCellType(cellTypes : Set<CellType>) {
        efCellAnimation.setCellType(cellTypes)
    }
    
    /// Call this function to change when cells are animated
    ///
    /// - Always: Every time a cell becomes visible
    /// - Reload: The first time a cell becomes visible, and reset if tableview is reloaded
    /// - Once: The first time a cell becomes visible, does not reset on reload
    ///
    /// Default is .Reload
    public func setShowType(showType : ShowType) {
        efCellAnimation.setShowType(showType)
    }
    
    /// Call this function to change the cell presentation animation time
    ///
    /// Default is 0.4
    public func setDuration(duration : Double) {
        efCellAnimation.setDuration(duration)
    }
    
    /// Call this function to change the initial alpha value for any Fade animation
    ///
    /// Ranges from 0.0 to 1.0, defaults to 0.0
    public func setInitialAlpha(alpha : Double) {
        efCellAnimation.setInitialAlpha(alpha)
    }
    
    /// Call this function to change the initial scale for Scale effects
    ///
    /// Default for each is 0.8
    public func setInitialScale(xscale : Double, yscale : Double) {
        efCellAnimation.setInitialScale(xscale, yscale: yscale)
    }
    
    /// This function will be called by parse and will reset the previous index array.
    /// If you override this function, always call super.objectsWillLoad()
    override public func objectsWillLoad() {
        efCellAnimation.resetPrevIndexes()
        super.objectsWillLoad()
    }
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        efCellAnimation.setupAnimation(indexPath, cell: cell)
    }
}