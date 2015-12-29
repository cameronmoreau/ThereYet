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
    
    var selectedIndex: NSIndexPath?
    
    var addCourseViewController: AddCourse2ViewController!
    
    let colors = ["#D3D3D3", "#F44336", "#E91E63", "#9C27B0", "#673AB7", "#3F51B5", "#2196F3", "#03A9F4", "#00BCD4", "#009688", "#4CAF50", "#8BC34A", "#CDDC39", "#FFEB3B", "#FFC107", "#FF9800", "#FF5722", "#795548"]
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if selectedIndex != nil {
            addCourseViewController.course?.hexColor = colors[selectedIndex!.row]
            addCourseViewController.colorCell.backgroundColor = UIColor(rgba: colors[selectedIndex!.row])
            addCourseViewController.colorCell.textLabel?.text = ""
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CellWithCheckmark
        
        cell.backgroundColor = UIColor(rgba: colors[indexPath.row])
        
        if indexPath.isEqual(selectedIndex) {
            cell.checkmark.hidden = false
        } else {
            cell.checkmark.hidden = true
        }
        
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
        var oldCell: CellWithCheckmark?
        if selectedIndex != nil {
            oldCell = collectionView.cellForItemAtIndexPath(selectedIndex!) as? CellWithCheckmark
        }
        let newCell = collectionView.cellForItemAtIndexPath(indexPath) as! CellWithCheckmark
        
        oldCell?.checkmark.hidden = true
        newCell.checkmark.hidden = false
        
        selectedIndex = indexPath
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}

class CellWithCheckmark: UICollectionViewCell {

    @IBOutlet var checkmark: UIImageView!
    
}