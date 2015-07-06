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


/// Displays map view with student pins
class MapViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var MapView: MKMapView!
  
  var annotations = [MKAnnotation]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.MapView.delegate = self
    
    /// notifications for refreshing the information and refreshing the map view
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStudentInformation:", name: "refreshView",object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMapView:", name: "refreshMapView",object: nil)
    
    /// Make sure student information has been loaded
    loadStudentInformation()
  }
  
  /// overwrite the annotation view so we can add an info button
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    
    /// Try to get the view
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("studentPin") as? MKPinAnnotationView
    
    if let pinView = pinView {
      // All okay
    } else {
      /// create one
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "studentPin")
      pinView?.canShowCallout = true
      pinView?.animatesDrop = true
    }
    
    /// Create a new (i) button for the annotation view
    var button = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
    if let annotation = annotation as? MKPointAnnotation {
      /// add the url to the button (invisible) so we can retrieve it later
      var mediaLabel = UILabel()
      mediaLabel.text = annotation.subtitle
      mediaLabel.backgroundColor = UIColor.clearColor()
      mediaLabel.textColor =  UIColor.clearColor()
      
      button.addSubview(mediaLabel)
    }
    
    /// Add the button
    button.addTarget(self, action: "loadMedia:", forControlEvents: UIControlEvents.TouchUpInside)

    /// Add the button to the annotation view
    pinView?.rightCalloutAccessoryView = button
    
    return pinView
  }
  
  /// Load the media url in the web view
  func loadMedia(sender:UIButton!)
  {
    /// Find the label (it containes the url)
    for view in sender.subviews {
      if let label = view as? UILabel {
        /// check if the url starts with http - if not add it
        var urlStr = label.text!
        if !urlStr.hasPrefix("http://") && !urlStr.hasPrefix("https://") {
          urlStr = "http://\(urlStr)"
        }
        
        /// load the url in the web view
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
  
  /// Refresh the map pins by removing them and then loading new information
  func refreshStudentInformation(notification: NSNotification) {
    removeStudentInformation()
    loadStudentInformation()
  }
  
  /// Re-draw the map views annotations
  func refreshMapView(notification: NSNotification) {
    
    /// zoom to the users location
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

    var students = OTMClient.sharedInstance().students
    
    /// remove any stale pins
    self.annotations.removeAll(keepCapacity: false)
    
    ///for each student create a new pin anootation
    for student in students {
      var newAnnotation = MKPointAnnotation()
        
      if let latitude = student.latitude, longitude = student.longitude {
        newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      }
        
      if let firstName = student.firstName, lastName = student.lastName, mediaUrl = student.mediaUrl {
        newAnnotation.title = "\(firstName) \(lastName)"
        newAnnotation.subtitle = "\(mediaUrl)"
      }
      self.annotations.append(newAnnotation)
    }
    
    dispatch_async(dispatch_get_main_queue(), {
      
      /// zoom to users location
      if let newRegion = newRegion {
        self.MapView.setRegion(newRegion, animated: true)
      }
      /// Add all of the annotations to the view
      self.MapView.addAnnotations(self.annotations)
    })
  }
  
  /// remove all annotations
  func removeStudentInformation() {
    for annotation in self.MapView.annotations {
      
      dispatch_async(dispatch_get_main_queue(), {
        self.MapView.removeAnnotation(annotation as! MKPointAnnotation)
      })
    }
  }
  
  /// Load the student information
  func loadStudentInformation() {
    OTMClient.sharedInstance().loadStudentLocations() { result, errorString in
      
      if let error = errorString {
        ErrorViewController.displayError(self, error: error, title: "Load Student Information Failed")
      }
      
      /// success - notify listeners they can use the data
      NSNotificationCenter.defaultCenter().postNotificationName("refreshMapView", object: nil)

    }
  }
  
}
