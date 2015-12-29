//
//  SelectLocationViewController.swift
//  ThereYet
//
//  Created by Cameron Moreau on 12/28/15.
//  Copyright © 2015 Mobi. All rights reserved.
//

import UIKit
import Mapbox

protocol SelectLocationDelegate {
    func locationSelected()
    func locationCanceled()
}

class SelectLocationViewController: UIViewController {
    
    @IBOutlet weak var buttonDone: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MGLMapView!
    
    var delegate: SelectLocationDelegate?
    
    @IBAction func cancelAction(sender: AnyObject) {
        delegate?.locationCanceled()
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDone.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
