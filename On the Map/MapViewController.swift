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
  
  let APP_ID  = "PUT YOUR APP ID HERE"
  let API_KEY = "PUT YOUR API KEY HERE"
  
  
  @IBOutlet weak var MapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.MapView.delegate = self
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStudentInformation:", name: "refreshView",object: nil)
    loadStudentInformation()
    
  }
  
  func refreshStudentInformation(notification: NSNotification) {
    println("refresh student info")
    removeStudentInformation()
    loadStudentInformation()
  }
  
  func removeStudentInformation() {
    for annotation in self.MapView.annotations {
      
      dispatch_async(dispatch_get_main_queue(), {
        self.MapView.removeAnnotation(annotation as! MKPointAnnotation)
      })
    }
  }
  
  func loadStudentInformation() {
    println("load student location")
    let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
    request.addValue(APP_ID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil { // Handle error...
        return
      }
      var parsingError: NSError? = nil
      let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
      if let results = parsedResult?.valueForKey("results") as? NSArray {
        for entry in results {
          var newAnnotation = MKPointAnnotation()
          newAnnotation.coordinate = CLLocationCoordinate2D(latitude: entry["latitude"] as! Double, longitude: entry["longitude"] as! Double)
          if let firstName = entry["firstName"] as? String {
            if let lastName = entry["lastName"] as? String {
              if let mediaUrl = entry["mediaURL"] as? String {
                newAnnotation.title = "\(firstName) \(lastName)"
                newAnnotation.subtitle = "\(mediaUrl)"
                
                dispatch_async(dispatch_get_main_queue(), {
                  self.MapView.addAnnotation(newAnnotation)
                })
              }
            }
          }
          println(entry)
        }
        println(results.count)
      }
    }
    task.resume()
  }
  
}
