//
//  ViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 3/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    /// Set this to be the delegate for the login text fields
    emailTextField.delegate = self
    passwordTextField.delegate = self
  }
  
  @IBAction func loginButtonPressed(sender: AnyObject) {
    println("Login")
    let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailTextField.text)\", \"password\": \"\(passwordTextField.text)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
    let session = NSURLSession.sharedSession()
    println("do task")
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if (error != nil) {
        println("Error login to udacity")
        return
      }
      var parsingError: NSError? = nil
      var loginFailed: Bool = true
      let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
      
      let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
      
      println(NSString(data: newData, encoding: NSUTF8StringEncoding))
      if let error = parsingError {
        println("error parsing data")
        return
      } else if let account = parsedResult?.valueForKey("account") as? NSDictionary? {
        if let registered = account?.valueForKey("registered") as? Bool {
          if (registered == true) {
            let key = account?.valueForKey("key") as? String
            println(key)
            dispatch_async(dispatch_get_main_queue(), {
              let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapNavigationController") as! UINavigationController
              loginFailed = false;
              self.presentViewController(controller, animated: true, completion: nil)
            })
          }
        }
        
      } else {
        println("not much happening here")
      }
      
      if (loginFailed == true) {
        //Create the AlertController
        var errorString = ""
        if let errorMessage = parsedResult?.valueForKey("error") as? String {
          errorString += "\(errorMessage)"
        }

        dispatch_async(dispatch_get_main_queue(), {
          let alertController: UIAlertController = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: .Alert)
          
          alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
          
        
          //Present the AlertController
          self.presentViewController(alertController, animated: true, completion: nil)
        })
      }
    }
    task.resume()
  }
  
  func textFieldDidBeginEditing(textField: UITextField)
  {
    textField.text = ""
    if(textField == passwordTextField){
      passwordTextField.secureTextEntry = true;
    }
  }

}

