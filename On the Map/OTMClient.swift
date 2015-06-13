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
  
  func doGetReq(baseURL: String, method: String, params: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    let request = NSMutableURLRequest(URL: NSURL(string: "\(baseURL)/\(method)/\(params)")!)
    request.HTTPMethod = "GET"
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        println(inError)
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Get data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        println(data)
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  func doPostReq(baseURL: String, method: String, body: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    let urlString = "\(baseURL)/\(method)"
    var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        println(inError)
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Post data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  func getStudentInformation(key: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    doGetReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Users, params: key) { result, error in
      if let newError = error {
        completionHandler(success: false, errorString: error?.localizedDescription)
      } else {
        if let user = result?.valueForKey("user") as? NSDictionary {
          println("got user")
          if let student = self.student {
            self.student?.firstName = user.valueForKey("first_name") as? String
            self.student?.lastName = user.valueForKey("last_name") as? String
            println(self.student!.firstName)
            println(self.student!.lastName)
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
    doPostReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Session, body: body) { result, error in
      if let newError = error {
        completionHandler(success: false, errorString: error?.localizedDescription)
      } else if let account = result?.valueForKey("account") as? NSDictionary {
        println(account)
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

  class func sharedInstance() -> OTMClient {
    struct Singleton {
      static var sharedInstance = OTMClient()
    }
              
    return Singleton.sharedInstance
  }
}