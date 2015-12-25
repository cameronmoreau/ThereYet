//
//  RewardsViewController.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/24/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

class RewardsViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var viewTab: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UISearchBar!
    
    @IBAction func tabPressed(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    private enum TYPE: Int {
        case Offers = 0
        case GiftCards
        case History
    }
    
    var offers: [Offer] = []
    //var giftCards:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewTab.selectedSegmentIndex = 0
        tableView.delegate = self
        tableView.dataSource = self
        
        let loadingHUD = JGProgressHUD(style: .Dark)
        loadingHUD.textLabel.text = "Loading"
        loadingHUD.showInView(self.view, animated: true)
        
        self.fetchOffers({
            (offers: [Offer]?) in
            
            loadingHUD.dismiss()
            
            if offers != nil {
                self.offers = offers!
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(self.viewTab.selectedSegmentIndex) {
        case TYPE.Offers.rawValue:
            return offers.count
            
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if viewTab.selectedSegmentIndex == TYPE.GiftCards.rawValue {
            cell = tableView.dequeueReusableCellWithIdentifier("GiftCardCell")
        }
        
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("OfferCell")
            
            let offer = self.offers[indexPath.row]
            cell.textLabel?.text = offer.title
            cell.detailTextLabel?.text = offer.company
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func fetchOffers(completion: ((offers: [Offer]?) -> ())) {
        let query = PFQuery(className: Offer.parseClassName())
        query.limit = 25
        
        query.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) in
            
            if error == nil {
                completion(offers: objects as? [Offer])
            } else {
                completion(offers: nil)
            }
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
