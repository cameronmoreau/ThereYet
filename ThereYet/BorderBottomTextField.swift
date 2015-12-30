//
//  BorderBottomTextField.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/30/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

class BorderBottomTextField: UITextField {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
