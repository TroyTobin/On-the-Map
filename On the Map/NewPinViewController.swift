//
//  ViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 3/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import CoreLocation

class NewPinViewController: UIViewController, UITextFieldDelegate{
  
  @IBOutlet weak var locationTextField: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

  }
  
  
  @IBAction func cancelNewPin(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  @IBAction func findLocationOnMap(sender: AnyObject) {
    var geoCoder = CLGeocoder()
    
  }
  
}

