//
//  Constants.swift
//  On the Map
//
//  Created by Troy Tobin on 9/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import Foundation

extension OTMClient {
  
  // MARK: - Constants
  struct Constants {
    
    static let ApiKey : String = "ENTER_YOUR_API_KEY_HERE"
    static let AppId  : String = "ENTER_YOU_APP_KEY_HERE"
    
    static let BaseURLUdacity : String = "https://www.udacity.com/api/"
    static let BaseURLParse   : String = "https://api.parse.com/1/classes/"
    
  }
  
  // MARK: - Udacity Methods
  struct UdacityMethods {
    static let Session = "session"
    static let Users   = "users"
  }
  
  // MARK: - Udacity HTTP Header
  struct UdacityHTTPHeader {
    static let Accept = ["field": "Accept", "value": "application/json"]
    static let ContentType = ["field": "Content-Type", "value": "application/json"]
  }
  
  // MARK: - Udacity HTTP Body
  struct UdacityHTTPBody {
    static let LoginFormat = "{\"udacity\": {\"username\": \"%s\", \"password\": \"%s\"}}"
  }
  
  // MARK: - Parse Methods
  struct ParseMethods {
    static let StudentLocation = "StudentLocation"
  }
  
  // MARK: - Parse Parameters
  struct ParseParamters {
    static let StudentLocationByKey = ["field": "where", "value": "[\"uniqueKey\":\"%d\"]"]
  }
  
  // MARK: Parse HTTP Header
  struct ParseHTTPHeader {
    static let ApplicationId = ["field": "X-Parse-Application-Id", "value": Constants.AppId]
    static let APIKey = ["field": "X-Parse-REST-API-Key", "value": Constants.ApiKey]
    static let ContentType = ["field": "Content-Type", "value": "application/json"]
  }
  
  //MARK: Parse HTTP Body
  struct ParseHTTPBody {
    static let StudentLocation = "{\"uniqueKey\": \"%d\", \"firstName\": \"%s\", \"lastName\": \"%s\",\"mapString\": \"%s\", \"mediaURL\": \"%s\",\"latitude\": %f, \"longitude\": %f}"
  }
}