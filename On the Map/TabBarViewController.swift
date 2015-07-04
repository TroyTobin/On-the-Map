//
//  MapViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 5/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    var logoutButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutAction:")
    
    self.navigationItem.setLeftBarButtonItem(logoutButtonItem, animated: false)
    
    var pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), style:UIBarButtonItemStyle.Plain, target: self, action: "pinStudentLocation:")
    var refreshBarButtonItem = UIBarButtonItem(image: UIImage(named: "Refresh"), style:UIBarButtonItemStyle.Plain, target: self, action: "refreshStudentLocations:")
    
    self.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: false);
  }
  
  func logoutAction(sender: UIBarButtonItem) {
    OTMClient.sharedInstance().logoutUdacity() { success, errorString in
      if let error = errorString {
        
      } else {
        dispatch_async(dispatch_get_main_queue(), {
          let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginController") as! UIViewController
          self.presentViewController(controller, animated: true, completion: nil)
        })
      }
    }
  }
  
  func pinStudentLocation(sender: UIBarButtonItem) {
    dispatch_async(dispatch_get_main_queue(), {
      let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NewStudentLocationView") as! UIViewController
      self.presentViewController(controller, animated: true, completion: nil)
    })
  }
  
  func refreshStudentLocations(sender: UIBarButtonItem) {
    NSNotificationCenter.defaultCenter().postNotificationName("refreshView", object: nil)
  }
  
  func displayError(error: String) {
    println("error \(error)")
    
    ErrorViewController.displayError(self, error: error, title: "Login Failed")
  }
  
}
