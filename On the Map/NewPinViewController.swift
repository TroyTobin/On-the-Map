//
//  ViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 3/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//

import UIKit
import CoreLocation

class NewPinViewController: UIViewController, UITextFieldDelegate{

  let APP_ID  = "PUT YOUR APP ID HERE"
  let API_KEY = "PUT YOUR API KEY HERE"
  
  @IBOutlet weak var locationTextField: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

  }
  
  @IBAction func findLocationOnMap(sender: AnyObject) {
    var geoCoder = CLGeocoder()
    
    geoCoder.geocodeAddressString(locationTextField.text, completionHandler: { result, error in
      if let error = error as NSError! {
        var errorString = "\(error.localizedDescription)"
        
        dispatch_async(dispatch_get_main_queue(), {
          let alertController: UIAlertController = UIAlertController(title: "Location lookup failed", message: errorString, preferredStyle: .Alert)
          
          alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
          
          
          //Present the AlertController
          self.presentViewController(alertController, animated: true, completion: nil)
        })
        return
      }
      for placemark in result {
        if let p = placemark as? CLPlacemark {
          
          let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
          request.HTTPMethod = "POST"
          request.addValue(self.APP_ID, forHTTPHeaderField: "X-Parse-Application-Id")
          request.addValue(self.API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"\(self.locationTextField.text)\", \"mediaURL\": \"https://udacity.com\",\"latitude\": \(p.location.coordinate.latitude), \"longitude\": \(p.location.coordinate.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
          let session = NSURLSession.sharedSession()
          let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if let error = error as NSError! {
              var errorString = "\(error.localizedDescription)"
              
              dispatch_async(dispatch_get_main_queue(), {
                let alertController: UIAlertController = UIAlertController(title: "Pin post failed", message: errorString, preferredStyle: .Alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                
                //Present the AlertController
                self.presentViewController(alertController, animated: true, completion: nil)
              })
              return
            }
            
            var parsingError: NSError? = nil
            let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
            if let error = parsedResult?.valueForKey("error") as? String {
              var errorString = "\(error)"
              
              dispatch_async(dispatch_get_main_queue(), {
                let alertController: UIAlertController = UIAlertController(title: "Pin post failed", message: errorString, preferredStyle: .Alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                
                //Present the AlertController
                self.presentViewController(alertController, animated: true, completion: nil)
              })
              return
            }
            if let objectID = parsedResult?.valueForKey("objectId") as? String {
              self.dismissViewControllerAnimated(true, completion: nil)
            }
          }
          task.resume()
        }
      }
    })
  }
  
}

