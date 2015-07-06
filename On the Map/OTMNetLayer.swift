//
//  OTMNetLayer.swift
//  On the Map
//
//  Created by Troy Tobin on 5/07/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

import UIKit


/// This class provides an api layer for performing http requests to 
/// either the Parse or Udacity APIs
class OTMNetLayer: NSObject {
  
  var session: NSURLSession
  
  /// Initialise the Network Layer
  override init() {
    session = NSURLSession.sharedSession()
  }
  
  /// Escape URL parameters to create valid URL encoding
  class func escapeURLParameters(parameters: [String : String]?) -> String {
    
    var urlParameters = ""
    
    if let inParameters = parameters {
      urlParameters += "?"
      for (key, value) in inParameters {
        
        /// escape the parameter
        let escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        /// append the parameter to create a string of the form 'key=value&'
        urlParameters += "\(key)=\(escapedValue!)&"
      }
    }
    
    return urlParameters
  }
  
  /// Convert a blob of binary json to ascii encoded json
  /// Note: this block of code is found in the "Movie Manager" presented as 
  ///       a part of the iOS Networking Udacity Course
  class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
    
    var parsingError: NSError? = nil
    
    let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
    
    /// check for errors and return the appropriate response to the completion handler
    if let error = parsingError {
      completionHandler(result: nil, error: error)
    } else {
      completionHandler(result: parsedResult, error: nil)
    }
  }
  
  /// Perform a HTTP Get request to the specified URL, method and parameters
  func doGetReq(baseURL: String, method: String, params: String?, header: [NSDictionary]?, offset: Int,  completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    var fullUrl: NSURL? = nil
    
    /// set the url string
    if let inParams = params {
      fullUrl = NSURL(string: "\(baseURL)/\(method)/\(inParams)")
    } else {
      fullUrl = NSURL(string:"\(baseURL)/\(method)")
    }
    /// create the URL request and set the http parameters
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
    
    /// perform the GET request
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        /// There was an error so return as such
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Get data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        /// offset the returned data if necessary - this is required for the udacity
        /// data that is returned
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset))
        /// Parse the data to JSON
        OTMNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  /// Perform a HTTP Post request to the specified URL, method and parameters
  func doPostReq(baseURL: String, method: String, header: [NSDictionary]?, body: String, offset: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    /// create the full url string
    let urlString = "\(baseURL)/\(method)"
    
    /// Create the HTTP request and set its parameters
    var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    request.HTTPMethod = "POST"
    if let inHeader = header {
      for item in inHeader {
        if let value = item.valueForKey("value") as? String {
          if let field = item.valueForKey("field") as? String {
            request.addValue(value, forHTTPHeaderField: field)
          }
        }
      }
    }
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    
    /// Perform the HTTP POST
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        /// There was an error so return as such
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Post data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        
        /// Get any cookies that we can
        if let httpResponse = response as? NSHTTPURLResponse {
          let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(httpResponse.allHeaderFields, forURL: response.URL!) as! [NSHTTPCookie]
          NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response.URL!, mainDocumentURL: nil)
        }
        /// Offset the data if necessary - udacity API requires this
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset))
        /// Parse the returned data as JSON
        OTMNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  /// Perform a HTTP Put request to the specified URL
  func doPutReq(baseURL: String, header: [NSDictionary]?, body: String, offset: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    /// create the HTTP Request and set the parameters
    var request = NSMutableURLRequest(URL: NSURL(string: baseURL)!)
    request.HTTPMethod = "PUT"
    if let inHeader = header {
      for item in inHeader {
        if let value = item.valueForKey("value") as? String {
          if let field = item.valueForKey("field") as? String {
            request.addValue(value, forHTTPHeaderField: field)
          }
        }
      }
    }
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    
    /// Perform the HTTP PUT
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        /// There was an error so return as such
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Post data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        /// Offset the returned data if necessary - Udacity API requires this
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset))
        /// Parse the returned data as JSON
        OTMNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  
  /// Perform a HTTP Delete request to the specified URL and method
  func doDeleteReq(baseURL: String, method: String, offset: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    /// Set the full url string
    let urlString = "\(baseURL)/\(method)"
    
    /// create the URL request and set the http parameters
    var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    request.HTTPMethod = "DELETE"
    
    /// If we have a cookie from a previous POST we could use it here to delete the 
    /// session
    var xsrfCookie: NSHTTPCookie? = nil
    let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
      if cookie.name == "UY-XSRF-TOKEN" { xsrfCookie = cookie }
    }
    if let xsrfCookie = xsrfCookie {
      /// Got the cookie so set it in the http delete request
      request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
    }
    
    /// perform the HTTP DELETE
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        /// There was an error so return as such
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Delete data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        
        /// finished with the cookie so delete
        if let xsrfCookie = xsrfCookie {
          sharedCookieStorage.deleteCookie(xsrfCookie)
        }
        
        /// oofset the returned data if necessary - required for Udacity API
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset))
        /// Parse the returned data as JSON
        OTMNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
}