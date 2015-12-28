//
//  SelectColorViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/28/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

class SelectColorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let colors = [UIColor.lightGrayColor(), UIColor(rgba: "#F44336"), UIColor(rgba: "#E91E63"), UIColor(rgba: "#9C27B0"), UIColor(rgba: "#673AB7"), UIColor(rgba: "#3F51B5"), UIColor(rgba: "#2196F3"), UIColor(rgba: "#03A9F4"), UIColor(rgba: "#00BCD4"), UIColor(rgba: "#009688"), UIColor(rgba: "#4CAF50"), UIColor(rgba: "#8BC34A"), UIColor(rgba: "#CDDC39"), UIColor(rgba: "#FFEB3B"), UIColor(rgba: "#FFC107"), UIColor(rgba: "#FF9800"), UIColor(rgba: "#FF5722"), UIColor(rgba: "#795548")]
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) //as! CellWithCheckmark
        
        cell.backgroundColor = colors[indexPath.row]
        
        /*if indexPath.isEqual(selectedIndex) {
            cell.checkmark.hidden = false
        } else {
            cell.checkmark.hidden = true
        }
        
        if colorsInUse.count != 0 {
            let color = colors[indexPath.row]
            if colorsInUse.contains(color) {
                cell.inUseLabel.hidden = false
            } else {
                cell.inUseLabel.hidden = true
            }
        }*/
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var numDivisibleBy: CGFloat = 4
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        for (var i: CGFloat = 4; i > 1; i--) {
            if screenWidth % i == 0 {
                numDivisibleBy = i
            }
        }
        return CGSizeMake(screenWidth/numDivisibleBy, screenWidth/numDivisibleBy)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /*let oldCell = collectionView.cellForItemAtIndexPath(selectedIndex) as? CellWithCheckmark
        let newCell = collectionView.cellForItemAtIndexPath(indexPath) as! CellWithCheckmark
        
        oldCell?.checkmark.hidden = true
        newCell.checkmark.hidden = false
        
        selectedIndex = indexPath*/
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}