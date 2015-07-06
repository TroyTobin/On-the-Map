//
//  MapViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 5/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit

/// provies tab view for map and table views
class TabBarViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// add ogout button to top left of nav bar
    var logoutButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutAction:")
    
    self.navigationItem.setLeftBarButtonItem(logoutButtonItem, animated: false)
    
    /// add new pin and refresh to top right of nav bar
    var pinBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), style:UIBarButtonItemStyle.Plain, target: self, action: "pinStudentLocation:")
    var refreshBarButtonItem = UIBarButtonItem(image: UIImage(named: "Refresh"), style:UIBarButtonItemStyle.Plain, target: self, action: "refreshStudentLocations:")
    
    self.navigationItem.setRightBarButtonItems([refreshBarButtonItem, pinBarButtonItem], animated: false);
  }
  
  
  /// logout of udacity account
  func logoutAction(sender: UIBarButtonItem) {
    OTMClient.sharedInstance().logoutUdacity() { success, errorString in
      if success {
        
        /// success so display the login screen (as we have logged out)
        dispatch_async(dispatch_get_main_queue(), {
          let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginController") as! UIViewController
          self.presentViewController(controller, animated: true, completion: nil)
        })
        return
      }
      
      /// display any errors
      if let error = errorString {
        ErrorViewController.displayError(self, error: error, title: "Logout Failed")
      } else {
        ErrorViewController.displayError(self, error: "Unknown Error", title: "Logout Failed")
      }
    }
  }
  
  /// if the new pin button is pressed, transisiton to new pin view
  func pinStudentLocation(sender: UIBarButtonItem) {
    dispatch_async(dispatch_get_main_queue(), {
      let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NewStudentLocationView") as! UIViewController
      self.presentViewController(controller, animated: true, completion: nil)
    })
  }
  
  /// refresh students' information
  func refreshStudentLocations(sender: UIBarButtonItem) {
    /// notify all clients to refresh their views.
    NSNotificationCenter.defaultCenter().postNotificationName("refreshView", object: nil)
  }
  
}
