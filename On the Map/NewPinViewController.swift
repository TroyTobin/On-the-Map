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
  
  @IBOutlet weak var locationTextField: UITextView!
  @IBOutlet weak var errorTextField: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationTextField.delegate = self
    
    locationTextField.text = "Enter Location Here"
    locationTextField.font = UIFont(name: "AvenirNext-Medium", size: 25)
    locationTextField.textColor = UIColor.whiteColor()
    
    errorTextField.text = ""
    errorTextField.font = UIFont(name: "AvenirNext-Medium", size: 20)
    errorTextField.textColor = UIColor.blackColor()
    
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
    
    OTMClient.sharedInstance().updateStudentPin(locationTextField.text) { success, errorString in
      if let error = errorString {
        self.displayError(error)
      } else if success {
          dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapMediaPinViewController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
          })
      }
    }
  }
  
  func displayError(error: String) {
    println("error \(error)")
    dispatch_async(dispatch_get_main_queue(), {
      self.errorTextField.text = error
      self.locationTextField.text = "Enter Location Here"
    })
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    errorTextField.text = ""
    locationTextField.text = ""
  }
}

