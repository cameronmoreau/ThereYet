//
//  SideViewController.swift
//  AWSideBar
//
//  Created by Andrew Whitehead on 12/20/15.
//  Copyright © 2015 Andrew Whitehead. All rights reserved.
//

import UIKit

protocol SideViewControllerDelegate {
    func menuItemSelected(menuItem: MenuItem)
}

class SideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var delegate: SideViewControllerDelegate?
    
    var selectedMenuItem: MenuItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return MenuItems.numSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuItems.menuItems(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)

        let backgroundColor = UIView()
        backgroundColor.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 240/255.0, alpha: 1.0)
        cell.selectedBackgroundView = backgroundColor
        
        let menuItem = MenuItems.menuItems(indexPath.section)[indexPath.row]
        
        cell.textLabel?.text = menuItem.name
        cell.textLabel?.highlightedTextColor = menuItem.color
        cell.textLabel?.textColor = UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
        
        cell.imageView?.image = menuItem.image
        cell.imageView?.highlightedImage = menuItem.highlightedImage
        cell.imageView?.tintColor = menuItem.color
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuItemAtSelectedIndex = MenuItems.menuItems(indexPath.section)[indexPath.row]
        
        if menuItemAtSelectedIndex.action == .Navigation {
           selectedMenuItem = menuItemAtSelectedIndex
        } else {
            self.tableView.selectRowAtIndexPath(MenuItems.indexPathForMenuItem(selectedMenuItem), animated: false, scrollPosition: .None)
        }
        
        delegate?.menuItemSelected(menuItemAtSelectedIndex)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = MenuItems.sectionTitles()
        if let headerTitles = titles {
            let str = headerTitles[section]
            if (str.isEmpty == false) {
                return str.uppercaseString
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func tableView(tv: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let str = tableView(tv, titleForHeaderInSection: section)
        if str?.isEmpty == false {
            return 22
        } else {
            return 0
        }
    }
    
    func tableView(tv: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)
        headerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 22)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRectMake(10, 0, UIScreen.mainScreen().bounds.size.width-10, 22)
        titleLabel.textColor = UIColor.lightGrayColor()
        titleLabel.font = UIFont.systemFontOfSize(12)
        titleLabel.text = tableView(tv, titleForHeaderInSection: section)
        
        headerView.addSubview(titleLabel)

        return headerView
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
