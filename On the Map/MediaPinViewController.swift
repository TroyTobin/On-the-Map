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

class MediaPinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
  
  @IBOutlet weak var activityView: UIActivityIndicatorView!
  @IBOutlet weak var MapView: MKMapView!
  @IBOutlet weak var mediaUrl: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    mediaUrl.font = UIFont(name: "AvenirNext-Medium", size: 25)
    mediaUrl.textColor = UIColor.whiteColor()
    mediaUrl.delegate = self
    
    dispatch_async(dispatch_get_main_queue(), {
      self.activityView.hidden = true
    })
    
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
  
  @IBAction func cancelNewPin(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func submitNewPin(sender: AnyObject) {
    if let student = OTMClient.sharedInstance().student {
      
      dispatch_async(dispatch_get_main_queue(), {
        self.activityView.hidden = false
      })
      
      OTMClient.sharedInstance().student!.mediaUrl = mediaUrl.text
      OTMClient.sharedInstance().submitNewPin() { success, errorString in
        
        dispatch_async(dispatch_get_main_queue(), {
          self.activityView.hidden = true
        })
        
        if success {
          dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
          })
          return
        }
        
        if let error = errorString {
          ErrorViewController.displayError(self, error: error, title: "Pin Update Failed")
        } else {
          ErrorViewController.displayError(self, error: "Unknown Error", title: "Pin Update Failed")
        }
      }
    } else {
      ErrorViewController.displayError(self, error: "No student loaded", title: "Pin Update Failed")
    }
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    mediaUrl.text = ""
  }
}
