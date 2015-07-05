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
  var id: String?
  var firstName: String?
  var lastName: String?
  var latitude: Double?
  var longitude: Double?
  var location: String?
  var mediaUrl: String?
  var objectId: String?
  var update: Bool
  
  
  init(id: String) {
    self.id = id
    self.firstName = nil
    self.lastName = nil
    self.latitude = nil
    self.longitude = nil
    self.location = nil
    self.mediaUrl = nil
    self.objectId = nil
    self.update = false
  }
  
  init(id: String, firstName: String, lastName: String, latitude: Double, longitude: Double, mediaUrl: String) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.latitude = latitude
    self.longitude = longitude
    self.location = nil
    self.mediaUrl = mediaUrl
    self.objectId = nil
    self.update = false
  }
  
  init(info: NSDictionary) {
    if let id = info["uniqueKey"] as? String, firstName = info["firstName"] as? String, lastName = info["lastName"] as? String, latitude = info["latitude"] as? Double, longitude = info["longitude"] as? Double, mediaUrl = info["mediaURL"] as? String {
      self.id = id
      self.firstName = firstName
      self.lastName = lastName
      self.latitude = latitude
      self.longitude = longitude
      self.location = nil
      self.mediaUrl = mediaUrl
      self.objectId = nil
      self.update = false
    } else {
      self.id = nil
      self.firstName = nil
      self.lastName = nil
      self.latitude = nil
      self.longitude = nil
      self.location = nil
      self.mediaUrl = nil
      self.objectId = nil
      self.update = false
    }
  }
}