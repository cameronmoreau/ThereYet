//
//  GiftCardTableViewCell.swift
//  ThereYet
//
//  Created by Cameron Moreau on 1/2/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class GiftCardTableViewCell: UITableViewCell {
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var sponsorImage: PFImageView!
    @IBOutlet weak var labelPoints: UILabel!
    
    func setGiftCard(g: GiftCard) {
        self.sponsorImage.contentMode = .ScaleAspectFit
        self.sponsorImage.layer.cornerRadius = 6
        self.sponsorImage.borderWidth = 1
        self.sponsorImage.borderColor = UIColor.grayColor()
        self.sponsorImage.backgroundColor = UIColor(rgba: g.sponsor!["colorSub"] as! String)
        self.sponsorImage.clipsToBounds = true
        self.sponsorImage.bounds = CGRectInset(self.sponsorImage.frame, 10, 10);
        self.sponsorImage.file = g.sponsor!["logo"] as? PFFile
        self.sponsorImage.loadInBackground()
        
        self.labelPoints.text = "\(g.points!) Points"
        self.labelAmount.text = "$\(g.amount!)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
