//
//  ViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 3/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import CoreLocation


//// New pin view controller.  Used to set the location of the new pin
class NewPinViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var activityView: UIActivityIndicatorView!
  @IBOutlet weak var locationTextField: UITextView!
  var tapRecognizer: UITapGestureRecognizer? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// we are the delegate
    locationTextField.delegate = self
    
    /// set some defaults and style for the text input for the location
    locationTextField.text = "Enter Location Here"
    locationTextField.font = UIFont(name: "AvenirNext-Medium", size: 25)
    locationTextField.textColor = UIColor.whiteColor()
    
    /// capture gestures to dismiss the keyboard
    tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
    tapRecognizer?.numberOfTapsRequired = 1
    addKeyboardDismissRecognizer()
    
    dispatch_async(dispatch_get_main_queue(), {
      self.activityView.hidden = true
    })
    
    /// Check if this new pin will be an update or a completely new pin
    checkForUpdate()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    /// remove the gesture recogniser
    self.removeKeyboardDismissRecognizer()
  }
  
  /// add the keyboard dismiss recogniser
  func addKeyboardDismissRecognizer() {
    self.view.addGestureRecognizer(tapRecognizer!)
  }

  /// remove the keyboard dissmiss recogniser
  func removeKeyboardDismissRecognizer() {
    self.view.removeGestureRecognizer(tapRecognizer!)
  }
  
  /// dismiss the keyboard on single tap outside of the keyboard view
  func handleSingleTap(recognizer: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  /// Check if a pin for this student already exists via the OTMClient.
  /// If it does - any new pin will need to be an update instead of creating a new pin
  func checkForUpdate() {
    if let student = OTMClient.sharedInstance().student {
      OTMClient.sharedInstance().findStudentPin(student.id!) { success, errorString in
        if success {
          // We'll need to send an update instead of creating a new pin
          OTMClient.sharedInstance().student?.update = true
        }
      }
    }
  }
  
  /// Cancel button pressed, so cancel the new pin creation
  @IBAction func cancelNewPin(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  /// Submit button pressed, so locate the new pin
  @IBAction func findLocationOnMap(sender: AnyObject) {
    self.view.endEditing(true)
    
    /// While "finding" display the activity view so the user knows something is happening
    dispatch_async(dispatch_get_main_queue(), {
      self.activityView.hidden = false
    })
    
    
    /// try to update the pin location via the OTM client
    OTMClient.sharedInstance().updateStudentPin(locationTextField.text) { success, errorString in
      
      dispatch_async(dispatch_get_main_queue(), {
        self.activityView.hidden = true
      })
      
      if success {
        /// All good - so display the media view - so the user can input a url
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
  
  /// clear the default text once a user starts inputting data
  func textViewDidBeginEditing(textView: UITextView) {
    locationTextField.text = ""
  }
}

