//
//  ErrorViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 5/07/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit

class ErrorViewController: NSObject {

  class func displayError(view: UIViewController, error: String, title: String) {
    
    dispatch_async(dispatch_get_main_queue(), {
      let alertController: UIAlertController = UIAlertController(title: title, message: error, preferredStyle: .Alert)
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
      
      //Present the AlertController
      view.presentViewController(alertController, animated: true, completion: nil)
    })
  }
}
