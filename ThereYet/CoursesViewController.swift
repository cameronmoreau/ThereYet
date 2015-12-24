//
//  CoursesViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 12/24/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit

class CoursesViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //FIXME: incomplete
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //FIXME: incomplete
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        //TODO: configure cell
        
        return cell
    }
    
}
