//
//  ViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 3/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var activityView: UIActivityIndicatorView!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var errorTextField: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    /// Set this to be the delegate for the login text fields
    emailTextField.delegate = self
    passwordTextField.delegate = self
    activityView.hidden = true
  }
  
  @IBAction func loginButtonPressed(sender: AnyObject) {
    self.view.endEditing(true)
    self.activityView.hidden = false

    OTMClient.sharedInstance().loginUdacity(emailTextField.text, password: passwordTextField.text) { success, errorString in
      
      dispatch_async(dispatch_get_main_queue(), {
        self.activityView.hidden = true
      })
      
      if success {
        dispatch_async(dispatch_get_main_queue(), {
          let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapNavigationController") as! UINavigationController
          self.presentViewController(controller, animated: true, completion: nil)
        })

      } else if let error = errorString {
        ErrorViewController.displayError(self, error: error, title: "Login Failed")
      } else {
        ErrorViewController.displayError(self, error: "Unknown Error", title: "Login Failed")
      }
    }
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    textField.text = ""
    if(textField == passwordTextField){
      passwordTextField.secureTextEntry = true;
    }
  }

}

