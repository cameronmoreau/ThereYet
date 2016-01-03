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
    
    var offers = [Offer]()
    var giftCards = [GiftCard]()
    var purchases = [Purchase]()
    var totalPoints: UIBarButtonItem!
    var points: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewTab.selectedSegmentIndex = 0
        tableView.delegate = self
        tableView.dataSource = self
        
        //Points
        let defaults = NSUserDefaults.standardUserDefaults()
        points = defaults.integerForKey("points")
        
        totalPoints = UIBarButtonItem(title: "\(points) points", style: .Done, target: self, action: nil)
        totalPoints.tintColor = UIColor.whiteColor()
        totalPoints.enabled = true
        self.navigationItem.rightBarButtonItem = totalPoints
        
        let loadingHUD = JGProgressHUD(style: .Dark)
        loadingHUD.textLabel.text = "Loading"
        loadingHUD.showInView(self.view, animated: true)
        
        self.loadData({
            loadingHUD.dismiss()
            self.tableView.reloadData()
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
            
        case TYPE.GiftCards.rawValue:
            return giftCards.count
            
        case TYPE.History.rawValue:
            return purchases.count
            
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if viewTab.selectedSegmentIndex == TYPE.GiftCards.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier("GiftCardCell") as! GiftCardTableViewCell
            cell.setGiftCard(self.giftCards[indexPath.row])
            return cell
        }
        
        else if viewTab.selectedSegmentIndex == TYPE.Offers.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier("OfferCell")! as UITableViewCell
            let offer = self.offers[indexPath.row]
            cell.textLabel?.text = "\(offer.title!) (\(offer.points!) points)"
            cell.detailTextLabel?.text = offer.sponsor!["title"] as? String
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell")! as UITableViewCell
            cell.textLabel?.text = self.purchases[indexPath.row].toString()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if viewTab.selectedSegmentIndex == TYPE.GiftCards.rawValue {
            return 138
        }
        
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let purchase = PFObject(className: "Purchase")
        
        switch(self.viewTab.selectedSegmentIndex) {
        case TYPE.Offers.rawValue:
            let o = self.offers[indexPath.row]
            
            if points < o.points {
                self.showBasicError("Reward", message: "Not enouch points")
            } else {
                purchase["item"] = ["title": o.title!, "points": o.points!]
                purchase["sponsor"] = o.sponsor
                purchase["type"] = "offer"
                
                purchase.saveInBackground()
                rewardSuccess(purchase, cost: o.points!)
            }
            
            break
            
        case TYPE.GiftCards.rawValue:
            let g = self.giftCards[indexPath.row]
            
            if points < g.points {
                self.showBasicError("Reward", message: "Not enouch points")
            } else {
                purchase["item"] = ["amount": g.amount!, "points": g.points!]
                purchase["sponsor"] = g.sponsor
                purchase["type"] = "giftcard"
                
                purchase.saveInBackground()
                rewardSuccess(purchase, cost: g.points!)
            }
            
            break
            
        default:
            break
        }
    }
    
    func rewardSuccess(purchase: PFObject, cost: Int) {
        
        //Update stored
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(points - cost, forKey: "points")
        defaults.synchronize()
        
        let u = PFUser.currentUser()!
        u["points"] = points - cost
        u.saveInBackground()
        
        //Update text
        totalPoints.title = "\(points - cost) points"
        
        self.purchases.append(Purchase(item: purchase["item"] as! [String:AnyObject], type: purchase["type"] as! String))
        
        let alertController = UIAlertController(title: "Reward Update", message: "You will receive an email shortly about your reward", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    func loadData(completion: (() -> ())) {
        let query = PFQuery(className: "Sponsor")
        
        query.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) in
            
            if let sponsors = objects {
                for sponsor in sponsors {
                    
                    //Gift cards
                    if let gcs = sponsor["giftCards"] {
                        for gc in gcs as! [AnyObject] {
                            self.giftCards.append(GiftCard(sponsor: sponsor, object: gc as! [String:AnyObject]))
                        }
                    }
                    
                    //Offers
                    if let os = sponsor["offers"] {
                        for o in os as! [AnyObject] {
                            self.offers.append(Offer(sponsor: sponsor, object: o as! [String:AnyObject]))
                        }
                    }
                }
            }
            
            //Purches
            let query2 = PFQuery(className: "Purchase")
            query2.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) in
                
                if let ps = objects {
                    for p in ps {
                        self.purchases.append(Purchase(item: p["item"] as! [String:AnyObject], type: p["type"] as! String))
                    }
                }
                
                completion()
            })
            
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
