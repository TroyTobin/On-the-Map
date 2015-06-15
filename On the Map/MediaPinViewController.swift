//
//  MapViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 5/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MediaPinViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var MapView: MKMapView!
  @IBOutlet weak var mediaTextField: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    showPinLocation()
  }
  
  func showPinLocation() {
    if let student = OTMClient.sharedInstance().student, latitude = student.latitude, longitude = student.longitude {
      var newAnnotation = MKPointAnnotation()
      newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      var newRegion = MKCoordinateRegion()
      var newSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
      newRegion.span = newSpan
      newRegion.span = newSpan;
      newRegion.center = newAnnotation.coordinate
      dispatch_async(dispatch_get_main_queue(), {
        self.MapView.addAnnotation(newAnnotation)
        self.MapView.setRegion(newRegion, animated: true)
      })
      
      
    }
  }
  
  @IBAction func submitNewPin(sender: AnyObject) {
    
  }
}
