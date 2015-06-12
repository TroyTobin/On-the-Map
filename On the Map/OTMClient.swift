//
//  OTMClient.swift
//  On the Map
//
//  Created by Troy Tobin on 9/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

import UIKit

class OTMClient: NSObject {
  
  var session: NSURLSession
  
  override init() {
    session = NSURLSession.sharedSession()
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
  
  func doGetReq(baseURL: String, method: String) {
    let request = NSMutableURLRequest(URL: NSURL(string: "\(baseURL)/\(method)")!)
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

  func loginUdacity(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    var body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
    doPostReq(OTMClient.Constants.BaseURLUdacity, method: OTMClient.UdacityMethods.Session, body: body) { result, error in
      println(result)
      if let newError = error {
        completionHandler(success: false, errorString: error?.localizedDescription)
      } else if let account = result?.valueForKey("account") as? NSDictionary {
        println(account)
        if let registered = account.valueForKey("registered") as? Bool {
          if (registered == true) {
            let key = account.valueForKey("key") as? String
            completionHandler(success: true, errorString: nil)
          } else {
            completionHandler(success: false, errorString: "Invalid Response")
          }
        } else {
          completionHandler(success: false, errorString: "Invalid Response")
        }
      } else if let errorMessage = result?.valueForKey("error") as? String {
        completionHandler(success: false, errorString: errorMessage)
      } else {
        completionHandler(success: false, errorString: "Invalid Response")
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