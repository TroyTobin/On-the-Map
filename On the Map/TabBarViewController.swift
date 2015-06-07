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
    
  }
  
  @IBAction func refreshStudentLocations(sender: AnyObject) {
    println("Calling refresh")
    NSNotificationCenter.defaultCenter().postNotificationName("refreshView", object: nil)
  }
}
