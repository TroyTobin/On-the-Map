//
//  OTMNetLayer.swift
//  On the Map
//
//  Created by Troy Tobin on 5/07/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

import UIKit

class OTMNetLayer: NSObject {
  
  var session: NSURLSession
  
  override init() {
    session = NSURLSession.sharedSession()
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
        OTMNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  func doPostReq(baseURL: String, method: String, header: [NSDictionary]?, body: String, offset: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    let urlString = "\(baseURL)/\(method)"
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
    
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Post data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        if let httpResponse = response as? NSHTTPURLResponse {
          let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(httpResponse.allHeaderFields, forURL: response.URL!) as! [NSHTTPCookie]
          NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response.URL!, mainDocumentURL: nil)
        }
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset)) /* subset response data! */
        OTMNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  func doPutReq(baseURL: String, header: [NSDictionary]?, body: String, offset: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
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
    
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Post data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset)) /* subset response data! */
        OTMNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }
  
  func doDeleteReq(baseURL: String, method: String, offset: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Bool {
    
    let urlString = "\(baseURL)/\(method)"
    var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    request.HTTPMethod = "DELETE"
    
    var xsrfCookie: NSHTTPCookie? = nil
    let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
      if cookie.name == "UY-XSRF-TOKEN" { xsrfCookie = cookie }
    }
    if let xsrfCookie = xsrfCookie {
      request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
    }
    let task = self.session.dataTaskWithRequest(request) { data, response, error in
      if let inError = error {
        let userInfo = [NSLocalizedDescriptionKey : "Failed to Delete data"]
        let newError =  NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
        completionHandler(result: nil, error: newError)
      } else {
        if let xsrfCookie = xsrfCookie {
          sharedCookieStorage.deleteCookie(xsrfCookie)
        }
        let newData = data.subdataWithRange(NSMakeRange(offset, data.length - offset)) /* subset response data! */
        OTMNetLayer.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
      }
    }
    task.resume()
    return true
  }

}