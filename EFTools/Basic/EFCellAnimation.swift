//
//  EFCellAnimation.swift
//  
//
//  Created by Brett Keck on 7/28/15.
//
//

import UIKit


/// Type for how the cell is presented on first load
///
/// - None: Normal loading of cell, no effects
/// - Translate: Cell slides in from the right, with no alpha fading
/// - TranslateFade: Cell slides in from the right and fades in
/// - Fade: Cell fades in with no motion effect
enum CellType {
    case None, Translate, TranslateFade, Fade
}

/// Type for when a cell is animated
///
/// - Always: Every time a cell becomes visible
/// - Reload: The first time a cell becomes visible, and reset if tableview is reloaded
/// - Once: The first time a cell becomes visible, does not reset on reload
enum ShowType {
    case Always, Reload, Once
}

class EFCellAnimation {
    /// How far the cell will travel on a Translate or TranslateFade effect
    ///
    /// Default is 50
    private var TRANSLATE_DISTANCE : CGFloat = 50
    
    /// Type of cell presentation
    ///
    /// Default is .None
    private var CELL_TYPE = CellType.None
    
    /// When to show animations
    ///
    /// Default is .Reload
    private var SHOW_TYPE = ShowType.Reload
    
    /// Duration for all effects, fade and slide in
    ///
    /// Default is 0.4
    private var DURATION = 0.4
    
    /// Initial alpha for Fade and TranslateFade effects
    ///
    /// Ranges from 0.0 to 1.0, defaults to 0.0
    private var INITIAL_ALPHA : Float = 0.0
    
    private var translateTransform : CATransform3D!
    
    private var prevIndexes : Set<NSIndexPath> = []
    
    init() {
        translateTransform = CATransform3DTranslate(CATransform3DIdentity, TRANSLATE_DISTANCE, 0, 0)
    }
    
    func setTranslateDistance(distance : Int) {
        TRANSLATE_DISTANCE = CGFloat(distance)
    }
    
    func setCellType(cellType : CellType) {
        CELL_TYPE = cellType
    }
    
    func setShowType(showType : ShowType) {
        SHOW_TYPE = showType
    }
    
    func setDuration(duration : Double) {
        DURATION = duration
    }
    
    func setInitialAlpha(alpha : Double) {
        INITIAL_ALPHA = Float(alpha)
    }
    
    func resetPrevIndexes() {
        if SHOW_TYPE != .Once {
            prevIndexes = []
        }
    }
    
    //TODO: Readme file - CocoaPods 0.38 required?
    
    
    
    func setupAnimation(indexPath: NSIndexPath, cell: UITableViewCell) {
        if prevIndexes.contains(indexPath) || SHOW_TYPE == .Always {
            prevIndexes.insert(indexPath)
            let content = cell.contentView
            switch(CELL_TYPE) {
            case .Translate:
                content.layer.transform = translateTransform
            case .Fade:
                content.layer.opacity = INITIAL_ALPHA
            case .TranslateFade:
                content.layer.transform = translateTransform
                content.layer.opacity = INITIAL_ALPHA
            case .None:
                break
            }
            UIView.animateWithDuration(DURATION, animations: { () -> Void in
                content.layer.transform = CATransform3DIdentity
                content.layer.opacity = 1.0
            })
        }
    }
}
