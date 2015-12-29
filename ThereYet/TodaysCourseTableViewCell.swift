//
//  TodaysCourseTableViewCell.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/25/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

class TodaysCourseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var colorView: UIView!

    var colorViewBGColor: UIColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        colorView.backgroundColor = colorViewBGColor
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        colorView.backgroundColor = colorViewBGColor
    }

}
