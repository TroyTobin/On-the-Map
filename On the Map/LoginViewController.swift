//
//  ViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 3/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var errorTextField: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    /// Set this to be the delegate for the login text fields
    emailTextField.delegate = self
    passwordTextField.delegate = self
    errorTextField.text = ""
    
    errorTextField.font = UIFont(name: "AvenirNext-Medium", size: 20)
    errorTextField.textColor = UIColor.whiteColor()
  }
  
  @IBAction func loginButtonPressed(sender: AnyObject) {
    self.view.endEditing(true)

    OTMClient.sharedInstance().loginUdacity(emailTextField.text, password: passwordTextField.text) { success, errorString in
      if success {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapNavigationController") as! UINavigationController
        dispatch_async(dispatch_get_main_queue(), {
          self.presentViewController(controller, animated: true, completion: nil)
        })

      } else if let error = errorString {
        self.displayError(error)
      } else {
        self.displayError("Login Failed")
      }
    }
  }
    
  func displayError(error: String) {
    println("error \(error)")
    dispatch_async(dispatch_get_main_queue(), {
      self.errorTextField.text = error
    })
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    textField.text = ""
    errorTextField.text = ""
    if(textField == passwordTextField){
      passwordTextField.secureTextEntry = true;
    }
  }

}

