//
//  OTMClient.swift
//  On the Map
//
//  Created by Troy Tobin on 9/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

class OTMClient: NSObject {
  
  var session: NSURLSession
  
  override init() {
    session = NSURLSession.sharedSession()
    super.init()
  }
}