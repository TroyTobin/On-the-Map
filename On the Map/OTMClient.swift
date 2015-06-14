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
  
  var session: NSURLSession
  var geoCoder: CLGeocoder
  var student: OTMStudent?
  
  override init() {
    session = NSURLSession.sharedSession()
    geoCoder = CLGeocoder()
    student = nil
    super.init()
  }
  
  class func escapeURLParameters(params: [String : String]?) -> String {
    
    var urlParameters = ""
    
    if let inParams = params {
      urlParameters += "?"
      for (key, value) in inParams {
    
        let escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
      
        urlParameters += "\(key)=\(escapedValue!)&"
      }
    }
    
    return urlParameters
  }
  
  class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
    
    var parsingError: NSError? = nil
    
    let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
    
    if let error = parsingError {
      completionHandler(result: nil, error: error)
    } else {
      completionHandler(result: parsedResult, error: nil)
    }
  }
  
  func doGetReq(baseURL: String, method: String, params: String?, header: [NSDictionary]?, offset: Int,  completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    var fullUrl: NSURL? = nil
    if let inParams = params {
      fullUrl = NSURL(string: "\(baseURL)/\(method)/\(inParams)")
    } else {
      fullUrl = NSURL(string:"\(baseURL)/\(method)")
    }
    let request = NSMutableURLRequest(URL: fullUrl!)
    request.HTTPMethod = "GET"
    if let inHeader = header {
      for item in inHeader {
        if let value = item.valueForKey("value") as? String {
          if let field = item.valueForKey("field") as? String {
            request.addValue(value, forHTTPHeaderField: field)
          }
        }
      }
    }
    
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Get data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset))
        OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  func doPostReq(baseURL: String, method: String, body: String, offset: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    let urlString = "\(baseURL)/\(method)"
    var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Post data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset)) /* subset response data! */
        OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  func loadStudentLocations(completionHandler: (result: AnyObject?, errorString: String?) -> Void) {
    
    var httpHeader = [OTMClient.ParseHTTPHeader.APIKey, OTMClient.ParseHTTPHeader.ApplicationId]
    
    doGetReq(OTMClient.Constants.BaseURLParse, method: OTMClient.ParseMethods.StudentLocation, params: nil, header: httpHeader, offset: 0) { result, error in
      if let inError = error {
        completionHandler(result: nil, errorString: inError.localizedDescription)
      } else {
        completionHandler(result: result, errorString: nil)
      }
    }
  }
  
  func getStudentInformation(key: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    doGetReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Users, params: key, header: nil, offset: 5) { result, error in
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
    doPostReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Session, body: body, offset: 5) { result, error in
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
      } else {
        completionHandler(success: true, errorString: nil)
      }
    }
  }
  
  class func sharedInstance() -> OTMClient {
    struct Singleton {
      static var sharedInstance = OTMClient()
    }
              
    return Singleton.sharedInstance
  }
}