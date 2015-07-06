//
//  ErrorViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 5/07/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit

/// This class controls the view for displaying an Error message via an AlertController.
class ErrorViewController: NSObject {

  /// Create a new AlertController with the desired message
  class func displayError(view: UIViewController, error: String, title: String) {
    
    /// Create the AlertController
    let alertController: UIAlertController = UIAlertController(title: title, message: error, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))

    dispatch_async(dispatch_get_main_queue(), {
      /// Present the AlertController
      view.presentViewController(alertController, animated: true, completion: nil)
    })
  }
}
