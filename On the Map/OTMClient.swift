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


/// This class represents the On the Map API to the View controllers
class OTMClient: NSObject {
  
  var geoCoder: CLGeocoder
  var student: OTMStudent?
  var otmNet: OTMNetLayer
  
  /// Array of all students "On the Map"
  var students = [OTMStudent]()
  
  /// initialise and create a Geocoder and OTM network layer
  override init() {
    geoCoder = CLGeocoder()
    student = nil
    otmNet = OTMNetLayer()
    super.init()
  }
  
  /// Load all student locations and information
  func loadStudentLocations(completionHandler: (result: AnyObject?, errorString: String?) -> Void) {
    
    /// Make sure we clear out any old cache of student informations
    students.removeAll(keepCapacity: false)
    
    /// Set the http header for the request
    var httpHeader = [OTMClient.ParseHTTPHeader.APIKey, OTMClient.ParseHTTPHeader.ApplicationId]
    
    /// Perform a GET request to the parse api to get the student locations - limits to 100 students
    otmNet.doGetReq(OTMClient.Constants.BaseURLParse, method: OTMClient.ParseMethods.StudentLocation, params: nil, header: httpHeader, offset: 0) { result, error in
      if let inError = error {
        /// An error occured so return the error string
        completionHandler(result: nil, errorString: inError.localizedDescription)
      } else {
        /// okay so far - bit were there results?
        if let parsedResults = result.valueForKey("results") as? NSArray {
          /// iterate through the parsed results and create a new student for each
          for entry in parsedResults {
            var newStudent = OTMStudent(info: entry as! NSDictionary)
            self.students.append(newStudent)
          }
        }
        completionHandler(result: result, errorString: nil)
      }
    }
  }
  
  /// Get a single students information from an ID
  func getStudentInformation(key: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
    /// Do a GET request to the Parse API to retrieve the students information
    otmNet.doGetReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Users, params: key, header: nil, offset: 5) { result, error in
      if let newError = error {
        /// An error occured so return is string representation
        completionHandler(success: false, errorString: error?.localizedDescription)
      } else {
        /// Okay so far - but is there a "user" JSON object?
        if let user = result?.valueForKey("user") as? NSDictionary {
          if let student = self.student {
            /// valid results retrieved  - so extract the first and last name of the student
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

  /// Login to Udacity account
  func loginUdacity(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    /// Set the http body for the POST
    var body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
    
    /// Set the http header for the POST
    var header = [OTMClient.UdacityHTTPHeader.Accept, OTMClient.UdacityHTTPHeader.ContentType]
    
    /// Perform the POST request to the Udacity API for athentication
    otmNet.doPostReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Session, header:header, body: body, offset: 5) { result, error in
      if let newError = error {
        /// An error occured so return its string representation
        completionHandler(success: false, errorString: newError.localizedDescription)
      } else if let account = result?.valueForKey("account") as? NSDictionary {
        
        /// Okay so far - but sanity check the result before using
        if let registered = account.valueForKey("registered") as? Bool {
          if (registered == true) {
            if let key = account.valueForKey("key") as? String {
              /// Log in has been successful at this stage and we have the student ID
              /// So create the student
              self.student = OTMStudent(id: key)
              if let student = self.student {
                /// Using the student ID retrive their first and last name
                self.getStudentInformation(student.id!) { result, error in
                  if let newError = error {
                    /// An error occured so return
                    completionHandler(success: false, errorString: newError)
                  } else {
                    /// have the students name - now find their location
                    self.findStudentPin(student.id!) {
                      success, errorString in
                      if let newError = errorString {
                        completionHandler(success: false, errorString: newError)
                      }
                    }
                    /// success
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

  /// Log out of the udacity session
  func logoutUdacity(completionHandler: (success: Bool, errorString: String?) -> Void) {
    
    /// delete the active session (stored in cookie)
    otmNet.doDeleteReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Session, offset: 5) { result, error in
      if let newError = error {
        completionHandler(success: false, errorString: newError.localizedDescription)
      } else {
        /// success - so clear all information for the current session
        ///           including all student information
        self.clearStudents()
        completionHandler(success: true, errorString: nil)
      }
    }
  }
  
  /// Geo locate a string address
  func geoLocateAddress(address: String, completionHandler: (success: Bool, placemarks:[AnyObject]!, errorString: String?) -> Void) {
    geoCoder.geocodeAddressString(address) { result, error in
      if let newError = error {
        completionHandler(success: false, placemarks: nil, errorString: newError.localizedDescription)
      } else if let newResult = result {
        /// success
        completionHandler(success: true, placemarks: result, errorString: nil)
      } else {
        completionHandler(success: false, placemarks: nil, errorString: "Unknown Error")
      }
    }
  }
  
  
  /// Update the current students pin location
  func updateStudentPin(address: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
    /// where is the pin to be placed?
    self.geoLocateAddress(address) { success, placemarks, errorString in
      if let error = errorString {
        completionHandler(success: false, errorString: error)
      } else if let student = self.student, placemark = placemarks[0] as? CLPlacemark {
        /// update the students internal represetnation and return for the view controller to do something useful.
        self.student?.location = address
        self.student?.latitude = placemark.location.coordinate.latitude
        self.student?.longitude = placemark.location.coordinate.longitude
        completionHandler(success: true, errorString: nil)
      } else {
        completionHandler(success: false, errorString: "Unknown Error")
      }
    }
  }
  
  
  /// submit a new pin location.
  /// This could be a new pin, or an updated pin
  func submitNewPin(completionHandler: (success: Bool, errorString: String?) -> Void) {
    if let student = student, id = student.id, firstName = student.firstName, lastName = student.lastName, latitude = student.latitude, longitude = student.longitude, location = student.location, media = student.mediaUrl {
      
      /// Set the body for the HTTP request
      var body = "{\"uniqueKey\": \"\(id)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(media)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
      
      /// Set the header for the HTTP request
      var header = [OTMClient.ParseHTTPHeader.ContentType, OTMClient.ParseHTTPHeader.APIKey, OTMClient.ParseHTTPHeader.ApplicationId]
    
      /// Check if we are updating the student location or not
      if student.update {
        /// Update so need to PUT the data
        if let objectId = student.objectId {
          var putUrl = "\(OTMClient.Constants.BaseURLParse)/\(OTMClient.ParseMethods.StudentLocation)/\(objectId)"
          
          /// do the HTTP PUT
          otmNet.doPutReq(putUrl, header: header, body: body, offset: 0) { result, error in
            if let newError = error {
              completionHandler(success: false, errorString: newError.localizedDescription)
            } else {
              /// success
              completionHandler(success: true, errorString: nil)
            }
          }
        }
      } else {
        /// Completely new pin - so POST the data
        otmNet.doPostReq(OTMClient.Constants.BaseURLParse, method: OTMClient.ParseMethods.StudentLocation, header: header, body: body, offset: 0) { result, error in
          if let newError = error {
            completionHandler(success: false, errorString: newError.localizedDescription)
          } else {
            /// success
            completionHandler(success: true, errorString: nil)
          }
        }
      }
    }
  }
  
  
  /// Find a students pin location
  func findStudentPin(keyID: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
    /// set the http header for the request
    var httpHeader = [OTMClient.ParseHTTPHeader.APIKey, OTMClient.ParseHTTPHeader.ApplicationId]
    
    /// set the method parameters based on a format string and values (OTMConstants.swift)
    if let value = OTMClient.ParseParamters.StudentLocationByKey["value"], key = OTMClient.ParseParamters.StudentLocationByKey["key"], id = keyID.toInt() {
      var param = String(format: value, id)
      
      /// Create an escaped URL
      var keyParam = OTMNetLayer.escapeURLParameters([key: param])
  
      /// Do the GET request
      otmNet.doGetReq(OTMClient.Constants.BaseURLParse, method: OTMClient.ParseMethods.StudentLocation, params: keyParam, header: httpHeader, offset: 0) { result, error in
        if let newError = error {
          completionHandler(success: false, errorString: newError.localizedDescription)
        } else {
          
          /// success, but sanity check the results before using
          if let results = result?.valueForKey("results") as? NSArray {
            if results.count > 0 {
              if let oldPin = results[0] as? NSDictionary, student = self.student {
                /// set the location in the student model
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
  
  
  /// Clear all student information
  func clearStudents() {
    self.student = nil
    self.students.removeAll(keepCapacity: false)
  }
  
  
  /// Return the client singleton
  class func sharedInstance() -> OTMClient {
    struct Singleton {
      static var sharedInstance = OTMClient()
    }
              
    return Singleton.sharedInstance
  }
}