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

/// view controller for view allowing user to input a media url to attach to their pin
class MediaPinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
  
  @IBOutlet weak var activityView: UIActivityIndicatorView!
  @IBOutlet weak var MapView: MKMapView!
  @IBOutlet weak var mediaUrl: UITextField!
  
  var tapRecognizer: UITapGestureRecognizer?
  
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
    
    /// add gesture to dismiss the keyboard on single tap
    tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
    tapRecognizer?.numberOfTapsRequired = 1
    addKeyboardDismissRecognizer()
    
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.removeKeyboardDismissRecognizer()
  }
  
  /// add keyboard dismiss recogniser
  func addKeyboardDismissRecognizer() {
    self.view.addGestureRecognizer(tapRecognizer!)
  }
  
  /// remove keyboard dismiss recogniser
  func removeKeyboardDismissRecognizer() {
    self.view.removeGestureRecognizer(tapRecognizer!)
  }
  
  /// on single tap, dismiss the keyboard - i.e. end editiing
  func handleSingleTap(recognizer: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    /// dismiss the keyboard
    return textField.resignFirstResponder()
  }
  
  /// zoom to the location of the pin when entering the media url
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
  
  /// Cancel button pressed so cancel adding the pin
  @IBAction func cancelNewPin(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  /// All data has been entered so submit the new pin
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
          
          /// Go back to the map view
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
