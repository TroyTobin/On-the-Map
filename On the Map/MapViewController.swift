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
  
  // Here we add disclosure button inside annotation window
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    
    if annotation is MKUserLocation {
      //return nil
      return nil
    }
    
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
      //println("Pinview was nil")
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.animatesDrop = true
    }
    
    var button = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton // button with info sign in it
    if let annotation = annotation as? MKPointAnnotation {
      var mediaLabel = UILabel()
      mediaLabel.text = annotation.subtitle
      mediaLabel.backgroundColor = UIColor.clearColor()
      mediaLabel.textColor =  UIColor.clearColor()
      
      button.addSubview(mediaLabel)
    }
    button.addTarget(self, action: "loadMedia:", forControlEvents: UIControlEvents.TouchUpInside)

    
    pinView?.rightCalloutAccessoryView = button
    
    
    return pinView
  }
  
  func loadMedia(sender:UIButton!)
  {
    for view in sender.subviews {
      if let label = view as? UILabel {
        println(label.text)
        var urlStr = label.text!
        if !urlStr.hasPrefix("http://") && !urlStr.hasPrefix("https://") {
          urlStr = "http://\(urlStr)"
        }

        let webViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MediaWebViewController") as! WebViewController
        var url = NSURL(string: urlStr)
        if let url = url as NSURL! {
          webViewController.urlRequest = NSMutableURLRequest(URL: url)
        }
        dispatch_async(dispatch_get_main_queue(), {
          self.presentViewController(webViewController, animated: true, completion: nil)
        })
      }
    }

  }
  
  func refreshStudentInformation(notification: NSNotification) {
    removeStudentInformation()
    loadStudentInformation()
  }
  
  
  func refreshMapView(notification: NSNotification) {
    
    var newRegion: MKCoordinateRegion? = nil
    if let student = OTMClient.sharedInstance().student, latitude = student.latitude, longitude = student.longitude {
      var newAnnotation = MKPointAnnotation()
      newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      newRegion = MKCoordinateRegion()
      var newSpan = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
      newRegion?.span = newSpan
      newRegion?.span = newSpan;
      newRegion?.center = newAnnotation.coordinate
    }

    dispatch_async(dispatch_get_main_queue(), {
      if let newRegion = newRegion {
        self.MapView.setRegion(newRegion, animated: true)
      }
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
          } // for
          return
        }
      }
      
      if let error = errorString {
        ErrorViewController.displayError(self, error: error, title: "Load Student Information Failed")
      } else {
        ErrorViewController.displayError(self, error: "Unknown Error", title: "Load Student Information Failed")
      }
    }
  }
  
}
