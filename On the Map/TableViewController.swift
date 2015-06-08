//
//  TableViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 7/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.

import UIKit

class StudentTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  let APP_ID  = "PUT YOUR APP ID HERE"
  let API_KEY = "PUT YOUR API KEY HERE"
  
  var Students: NSArray? = nil
  @IBOutlet var TableView: UITableView!
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    TableView.dataSource = self
    TableView.delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStudentInformation:", name: "refreshView",object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshListView:", name: "refreshListView",object: nil)
    
    loadStudentInformation()
  }
  
  func refreshStudentInformation(notification: NSNotification) {
    loadStudentInformation()
  }
  
  func refreshListView(notification: NSNotification) {
    dispatch_async(dispatch_get_main_queue(), {
      self.TableView.reloadData()
    })
  }
  
  func loadStudentInformation() {
    let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
    request.addValue(APP_ID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil { // Handle error...
        return
      }
      var parsingError: NSError? = nil
      let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
      self.Students = parsedResult?.valueForKey("results") as? NSArray
      
      NSNotificationCenter.defaultCenter().postNotificationName("refreshListView", object: nil)
    }
    task.resume()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let students = Students {
      return students.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let Cell = tableView.dequeueReusableCellWithIdentifier("StudentTableCell") as! UITableViewCell
    
    if let student = self.Students?[indexPath.row] as? NSDictionary {
      if let firstName = student["firstName"] as? String {
        if let lastName = student["lastName"] as? String {
          Cell.textLabel!.text = "\(firstName) \(lastName)"
        }
      }
    }
    Cell.imageView!.image = UIImage(named: "Pin")
    
    return Cell
  }
}