//
//  EFTableViewController.swift
//  
//
//  Created by Brett Keck on 7/28/15.
//
//

import UIKit


/// This class subclasses UITableViewController.
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
/// - Call this function to change the initial alpha value for any Fade animation.
/// - Ranges from 0.0 to 1.0, defaults to 0.0
///
/// setInitialScale(scale : Double)
///
/// - Call this function to change the initial scale value for any Scale animation.
/// - Default is 0.8
///
/// resetCellAnimations()
///
/// - Call this function any time you are reloading your tableView; e.g. when you call tableView.reloadData()

public class EFTableViewController: UITableViewController {
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
    /// Default is 0.8
    public func setInitialScale(scale : Double) {
        efCellAnimation.setInitialScale(scale)
    }
    
    /// This function will need to be called any time a tableview is reloaded UNLESS you don't want the cells to rerun any animations
    public func resetCellAnimations() {
        efCellAnimation.resetPrevIndexes()
    }
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        efCellAnimation.setupAnimation(indexPath, cell: cell)
    }
}
