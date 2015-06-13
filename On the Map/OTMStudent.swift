//
//  OTMStudent.swift
//  On the Map
//
//  Created by Troy Tobin on 13/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

/// This class represents a single meme
struct OTMStudent {
  var id: String
  var firstName: String?
  var lastName: String?
  
  init(id: String) {
    self.id = id
    self.firstName = nil
    self.lastName = nil
  }
  
  init(id: String, firstName: String, lastName: String) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
  }
}