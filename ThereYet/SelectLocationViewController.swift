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
    func locationSelected(location: CLLocationCoordinate2D)
}

class SelectLocationViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var buttonDone: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MGLMapView!
    
    var selectedLocation: CLLocationCoordinate2D!
    var delegate: SelectLocationDelegate?
    let locationStorage = LocationStorage()
    
    @IBAction func doneAction(sender: AnyObject) {
        delegate?.locationSelected(selectedLocation)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        if let currentLocation = locationStorage.location {
            selectedLocation = currentLocation
        } else {
            selectedLocation = CLLocationCoordinate2DMake(0, 0)
        }
        
        self.mapView.setCenterCoordinate(selectedLocation, zoomLevel: 18, animated: true)
        self.view.addSubview(generateFrameMarker())
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    
        if selectedLocation != nil {
            delegate?.locationSelected(selectedLocation)
        }
    }
    
    private func generateFrameMarker() -> UIImageView {
        let size = CGFloat(50)
        let x = self.mapView.frame.origin.x + (self.view.frame.width / 2) - (size / 2)
        let y = ((self.view.frame.height + self.mapView.frame.origin.y) / 2) - size
        
        let frameMarker = UIImageView(frame: CGRectMake(x, y, size, size))
        frameMarker.image = UIImage(named: "ic_map_marker.png")
        return frameMarker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Mapbox
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        selectedLocation = mapView.centerCoordinate
    }
}
