//
//  ViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 3/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import CoreLocation

class NewPinViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var activityView: UIActivityIndicatorView!
  @IBOutlet weak var locationTextField: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationTextField.delegate = self
    
    locationTextField.text = "Enter Location Here"
    locationTextField.font = UIFont(name: "AvenirNext-Medium", size: 25)
    locationTextField.textColor = UIColor.whiteColor()
    
    dispatch_async(dispatch_get_main_queue(), {
      self.activityView.hidden = true
    })
    
    checkForUpdate()
  }
  
  func checkForUpdate() {
    if let student = OTMClient.sharedInstance().student {
      OTMClient.sharedInstance().findStudentPin(student.id) { success, errorString in
        if success {
          // We'll need to send an update instead of creating a new pin
          OTMClient.sharedInstance().student?.update = true
        }
      }
    }
  }
  
  @IBAction func cancelNewPin(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  @IBAction func findLocationOnMap(sender: AnyObject) {
    self.view.endEditing(true)
    
    dispatch_async(dispatch_get_main_queue(), {
      self.activityView.hidden = false
    })
    
    OTMClient.sharedInstance().updateStudentPin(locationTextField.text) { success, errorString in
      
      dispatch_async(dispatch_get_main_queue(), {
        self.activityView.hidden = true
      })
      
      if success {
        dispatch_async(dispatch_get_main_queue(), {
          let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapMediaPinViewController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
        return
      }
      
      if let error = errorString {
        ErrorViewController.displayError(self, error: error, title: "Geocode Failed")
      } else {
        ErrorViewController.displayError(self, error: "Unknown Error", title: "Geocode Failed")
      }
    }
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    locationTextField.text = ""
  }
}

