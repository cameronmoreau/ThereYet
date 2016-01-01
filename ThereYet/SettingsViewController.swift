//
//  SettingsViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 1/1/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import UIKit

class SettingsViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        
        
        return cell
    }
    
}
