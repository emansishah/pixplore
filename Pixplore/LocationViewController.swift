//
//  LocationViewController.swift
//  Pixplore
//
//  Created by Ali Shelton on 4/24/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import LocationPickerViewController
import MapKit

class LocationViewController: UIViewController {
    var currLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            self.currLocation = CLLocation(latitude: pickedLocationItem.coordinate.latitude, longitude: pickedLocationItem.coordinate.longitude)
        }
        locationPicker.addButtons()
        navigationController!.pushViewController(locationPicker, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
