//
//  MapTabController.swift
//  Pixplore
//
//  Created by Ali Shelton on 4/2/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import UIKit
import MapKit
import Parse
import CoreLocation

class MapTabController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var currLocation = Location.currLoc
    var isUsingCustomLocation = Location.isUsingCustom
    var userLocation = PFGeoPoint()
    
    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    var pinToObjectMap = [CLLocationDegrees: PFObject]()
    
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //geolocation setup
        locationManager.delegate = self
        if isUsingCustomLocation {
            centerLocation()
        }
        else {
            map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false)
        }
        map.delegate = self
        self.map.mapType = .Standard
        navBar.title = ""
        var label = UILabel(frame: CGRect(x: (self.view.bounds.width - 200)/2, y: 0, width: 200, height: 100))
        label.text = "EXPLORE"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Raleway~SemiBold", size: 18)
        navBar.titleView = label
    }
    
    override func viewDidAppear(animated: Bool) {
        if let annotations = self.map?.annotations {
            for _annotation in annotations {
                if let annotation = _annotation as? MKAnnotation
                {
                    self.map?.removeAnnotation(annotation)
                }
            }
        }
        if isUsingCustomLocation {
            if currLocation == userLocation {
                map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false)
            }
            else {
                centerLocation()
            }
        }
        else {
            map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false)
        }
        print("isUsing", isUsingCustomLocation)
        print(self.currLocation)
        findLocations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findLocations() {
        //Find user location
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.userLocation = geoPoint!
                
                /**
                 Run a query for all of the locations in the database within 25 miles of the user's current location and annotate them to the map
                 */
                let locationQuery = PFQuery(className:"Photo")
                let nearLocation = PFGeoPoint(location: Location.currLoc)
                locationQuery.whereKey("location", nearGeoPoint: nearLocation, withinMiles: 25)
                locationQuery.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // The find succeeded.
                        if let objects = objects {
                            for object in objects {
                                print("hi1")
                                let photoLocation = object["location"] as! PFGeoPoint
                                //let annotation = PinAnnotation()
                                
                                let coord = CLLocationCoordinate2DMake(photoLocation.latitude, photoLocation.longitude)
                                //                                annotation.setCoordinate(coord)
                                //                                annotation.setPhotoObject(object)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = coord
//                                map.viewForAnnotation(annotation)?.image//image of the pin
                                self.pinToObjectMap[annotation.coordinate.latitude] = object
                                self.map.addAnnotation(annotation)
                            }
                        }
                    } else {
                        // Log details of the failure
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("yo")
        self.performSegueWithIdentifier("mapToDetails", sender: view)
    }
    
    //    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    //
    //        if annotation is PinAnnotation {
    //            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
    //
    //            pinAnnotationView.pinColor = .Purple
    //            pinAnnotationView.draggable = true
    //            pinAnnotationView.canShowCallout = true
    //            pinAnnotationView.animatesDrop = true
    //
    //            let deleteButton = UIButton(type: UIButtonType.Custom) as UIButton
    //            deleteButton.frame.size.width = 44
    //            deleteButton.frame.size.height = 44
    //            deleteButton.backgroundColor = UIColor.redColor()
    //            deleteButton.setImage(UIImage(named: "trash"), forState: .Normal)
    //
    //            pinAnnotationView.leftCalloutAccessoryView = deleteButton
    //
    //            return pinAnnotationView
    //        }
    //
    //        return nil
    //    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("mapToDetails", sender: view)
        }
    }
    
    func centerLocation() {
        let location = CLLocationCoordinate2D(latitude: self.currLocation.coordinate.latitude, longitude: self.currLocation.coordinate.longitude)
        let span = MKCoordinateSpanMake(1.2, 1.2)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "mapToDetails" )
        {
            let vc = segue.destinationViewController as! DetailsViewController
            let pinTapped = sender as? MKAnnotationView
            let photoObj = self.pinToObjectMap[(pinTapped?.annotation?.coordinate.latitude)!]
            vc.photoObject = photoObj
//            photoObj!["photo"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
//                if error == nil {
//                    vc.picture.image = UIImage(data: imageData!)!
//                }
//            }
            photoObj!["photo"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    vc.picture.image = UIImage(data: imageData!)!
                    let postUser = photoObj!["uploadingUser"] as! PFUser
                    postUser.fetchIfNeededInBackgroundWithBlock {
                        (postt: PFObject?, error: NSError?) -> Void in
                        let userPic = postt?["profileImage"] as! PFFile!
                        userPic.getDataInBackgroundWithBlock {
                            (data, error) -> Void in
                            if let data = data where error == nil {
                                let tempImage = UIImage(data: data)
                                //self.uploaderImage = image!
                                vc.profileImage.image = tempImage
                            }
                        }
                    }
                }
            }
            vc.caption = (photoObj!["description"] as! String)
            vc.userName = (photoObj!["username"] as! String)
            vc.numSaves = (photoObj!["numberofSaves"] as! Int)
            let date = photoObj!.createdAt!
            let currentDate = NSDate()
            let timeBetweenDates = currentDate.timeIntervalSinceDate(date)
            let secondsInADay = 86400.0
            let daysBetween = timeBetweenDates / secondsInADay
            let days = Int(floor(daysBetween))
            vc.days = days
            vc.location = (photoObj!["location"] as! PFGeoPoint)
            let picLocation = photoObj!["location"] as! PFGeoPoint
            let picLoc:CLLocation = CLLocation(latitude: picLocation.latitude, longitude: picLocation.longitude)
            var dist = 0.0
            if isUsingCustomLocation{
                dist = self.currLocation.distanceFromLocation(picLoc)
            }
            else {
                let userLoc = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                dist = userLoc.distanceFromLocation(picLoc)
            }
            let inputDist = round(dist*0.00621371)/10
            vc.distanceVal = String(inputDist) + " Miles"
            
        }
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
