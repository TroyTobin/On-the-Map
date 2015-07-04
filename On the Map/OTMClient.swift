//
//  OTMClient.swift
//  On the Map
//
//  Created by Troy Tobin on 9/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation

class OTMClient: NSObject {
  
  var geoCoder: CLGeocoder
  var student: OTMStudent?
  var otmNet: OTMNetLayer
  
  override init() {
    geoCoder = CLGeocoder()
    student = nil
    otmNet = OTMNetLayer()
    super.init()
  }
  
  func loadStudentLocations(completionHandler: (result: AnyObject?, errorString: String?) -> Void) {
    
    var httpHeader = [OTMClient.ParseHTTPHeader.APIKey, OTMClient.ParseHTTPHeader.ApplicationId]
    
    otmNet.doGetReq(OTMClient.Constants.BaseURLParse, method: OTMClient.ParseMethods.StudentLocation, params: nil, header: httpHeader, offset: 0) { result, error in
      if let inError = error {
        completionHandler(result: nil, errorString: inError.localizedDescription)
      } else {
        completionHandler(result: result, errorString: nil)
      }
    }
  }
  
  func getStudentInformation(key: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    otmNet.doGetReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Users, params: key, header: nil, offset: 5) { result, error in
      if let newError = error {
        completionHandler(success: false, errorString: error?.localizedDescription)
      } else {
        if let user = result?.valueForKey("user") as? NSDictionary {
          if let student = self.student {
            self.student?.firstName = user.valueForKey("first_name") as? String
            self.student?.lastName = user.valueForKey("last_name") as? String
            completionHandler(success: true, errorString: nil)
            return
          }
        }
      }
      completionHandler(success: false, errorString: "Invalid User Response")
    }
  }

  func loginUdacity(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    var body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
    var header = [OTMClient.UdacityHTTPHeader.Accept, OTMClient.UdacityHTTPHeader.ContentType]
    otmNet.doPostReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Session, header:header, body: body, offset: 5) { result, error in
      if let newError = error {
        completionHandler(success: false, errorString: newError.localizedDescription)
      } else if let account = result?.valueForKey("account") as? NSDictionary {
        if let registered = account.valueForKey("registered") as? Bool {
          if (registered == true) {
            if let key = account.valueForKey("key") as? String {
              self.student = OTMStudent(id: key)
              if let student = self.student {
                self.getStudentInformation(student.id) { result, error in
                  if let newError = error {
                    completionHandler(success: false, errorString: newError)
                  } else {
                    self.findStudentPin(student.id) {
                      success, errorString in
                      if let newError = errorString {
                        completionHandler(success: false, errorString: newError)
                      }
                    }
                    completionHandler(success: true, errorString: nil)
                  }
                }
                return
              }
            }
          }
        }
      } else if let errorMessage = result?.valueForKey("error") as? String {
        completionHandler(success: false, errorString: errorMessage)
        return
      }
      completionHandler(success: false, errorString: "Invalid Login Response")
    }
  }

  func logoutUdacity(completionHandler: (success: Bool, errorString: String?) -> Void) {
    otmNet.doDeleteReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Session, offset: 5) { result, error in
      if let newError = error {
        completionHandler(success: false, errorString: newError.localizedDescription)
      } else {
        self.clearStudent()
        completionHandler(success: true, errorString: nil)
      }
    }
  }
  
  
  func geoLocateAddress(address: String, completionHandler: (success: Bool, placemarks:[AnyObject]!, errorString: String?) -> Void) {
    geoCoder.geocodeAddressString(address) { result, error in
      if let newError = error {
        completionHandler(success: false, placemarks: nil, errorString: newError.localizedDescription)
      } else if let newResult = result {
        completionHandler(success: true, placemarks: result, errorString: nil)
      } else {
        completionHandler(success: false, placemarks: nil, errorString: "Unknown Error")
      }
    }
  }
  
  func updateStudentPin(address: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    self.geoLocateAddress(address) { success, placemarks, errorString in
      if let error = errorString {
        completionHandler(success: false, errorString: error)
      } else if let student = self.student, placemark = placemarks[0] as? CLPlacemark {
          self.student?.location = address
          self.student?.latitude = placemark.location.coordinate.latitude
          self.student?.longitude = placemark.location.coordinate.longitude
          completionHandler(success: true, errorString: nil)
      } else {
        completionHandler(success: false, errorString: "Unknown Error")
      }
    }
  }
  
  func submitNewPin(completionHandler: (success: Bool, errorString: String?) -> Void) {
    if let student = student, firstName = student.firstName, lastName = student.lastName, latitude = student.latitude, longitude = student.longitude, location = student.location, media = student.mediaUrl {
      
      var body = "{\"uniqueKey\": \"\(student.id)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(media)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
      
      var header = [OTMClient.ParseHTTPHeader.ContentType, OTMClient.ParseHTTPHeader.APIKey, OTMClient.ParseHTTPHeader.ApplicationId]
    
      
      if student.update {
        if let objectId = student.objectId {
          var putUrl = "\(OTMClient.Constants.BaseURLParse)/\(OTMClient.ParseMethods.StudentLocation)/\(objectId)"
          otmNet.doPutReq(putUrl, header: header, body: body, offset: 0) { result, error in
            if let newError = error {
              completionHandler(success: false, errorString: newError.localizedDescription)
            } else {
              completionHandler(success: true, errorString: nil)
            }
          }
        }
      } else {
        otmNet.doPostReq(OTMClient.Constants.BaseURLParse, method: OTMClient.ParseMethods.StudentLocation, header: header, body: body, offset: 0) { result, error in
          if let newError = error {
            completionHandler(success: false, errorString: newError.localizedDescription)
          } else {
            completionHandler(success: true, errorString: nil)
          }
        }
      }
    }
  }
  
  func findStudentPin(keyID: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
    var httpHeader = [OTMClient.ParseHTTPHeader.APIKey, OTMClient.ParseHTTPHeader.ApplicationId]
    if let value = OTMClient.ParseParamters.StudentLocationByKey["value"], key = OTMClient.ParseParamters.StudentLocationByKey["key"], id = keyID.toInt() {
      var param = String(format: value, id)
      
      var keyParam = OTMNetLayer.escapeURLParameters([key: param])
  
      otmNet.doGetReq(OTMClient.Constants.BaseURLParse, method: OTMClient.ParseMethods.StudentLocation, params: keyParam, header: httpHeader, offset: 0) { result, error in
        if let newError = error {
          completionHandler(success: false, errorString: newError.localizedDescription)
        } else {
          if let results = result?.valueForKey("results") as? NSArray {
            if results.count > 0 {
              if let oldPin = results[0] as? NSDictionary, student = self.student {
                self.student!.latitude = oldPin.valueForKey("latitude") as? Double
                self.student!.longitude = oldPin.valueForKey("longitude") as? Double
                self.student!.objectId = oldPin.valueForKey("objectId") as? String
                completionHandler(success: true, errorString: nil)
                return
              }
            }
          }
        }
        completionHandler(success: false, errorString: nil)
      }
    }
  }
  
  func clearStudent() {
    self.student = nil
  }
  
    
  class func sharedInstance() -> OTMClient {
    struct Singleton {
      static var sharedInstance = OTMClient()
    }
              
    return Singleton.sharedInstance
  }
}