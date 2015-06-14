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

class MapViewController: UIViewController, MKMapViewDelegate {
  
  
  @IBOutlet weak var MapView: MKMapView!
  
  var annotations = [MKAnnotation]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.MapView.delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStudentInformation:", name: "refreshView",object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMapView:", name: "refreshMapView",object: nil)
    
    loadStudentInformation()
  }
  
  func refreshStudentInformation(notification: NSNotification) {
    removeStudentInformation()
    loadStudentInformation()
  }
  
  
  func refreshMapView(notification: NSNotification) {
    dispatch_async(dispatch_get_main_queue(), {
      self.MapView.addAnnotations(self.annotations)
    })
  }
  
  func removeStudentInformation() {
    for annotation in self.MapView.annotations {
      
      dispatch_async(dispatch_get_main_queue(), {
        self.MapView.removeAnnotation(annotation as! MKPointAnnotation)
      })
    }
  }
  
  func loadStudentInformation() {
    OTMClient.sharedInstance().loadStudentLocations() { result, errorString in
      if let parsedResult = result as? NSDictionary {
        self.annotations.removeAll(keepCapacity: false)
        if let results = parsedResult.valueForKey("results") as? NSArray {
          for entry in results {
            var newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = CLLocationCoordinate2D(latitude: entry["latitude"] as! Double, longitude: entry["longitude"] as! Double)
            if let firstName = entry["firstName"] as? String {
              if let lastName = entry["lastName"] as? String {
                if let mediaUrl = entry["mediaURL"] as? String {
                  newAnnotation.title = "\(firstName) \(lastName)"
                  newAnnotation.subtitle = "\(mediaUrl)"
                  self.annotations.append(newAnnotation)
                  
                  NSNotificationCenter.defaultCenter().postNotificationName("refreshMapView", object: nil)
                }
              }
            }
          }
        }
      }
    }
  }
  
}
