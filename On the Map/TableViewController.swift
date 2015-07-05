//
//  TableViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 7/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.

import UIKit

class StudentTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
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
    OTMClient.sharedInstance().loadStudentLocations() { result, errorString in
      
      if let error = errorString {
        ErrorViewController.displayError(self, error: error, title: "Load Student Information Failed")
      }
      
      NSNotificationCenter.defaultCenter().postNotificationName("refreshListView", object: nil)
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return OTMClient.sharedInstance().students.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let Cell = tableView.dequeueReusableCellWithIdentifier("StudentTableCell") as! UITableViewCell
    
    var student = OTMClient.sharedInstance().students[indexPath.row]
    
    if let firstName = student.firstName, lastName = student.lastName, mediaUrl = student.mediaUrl {
      Cell.textLabel!.text = "\(firstName) \(lastName)"
      Cell.detailTextLabel!.text = mediaUrl
    }
    
    Cell.imageView!.image = UIImage(named: "Pin")
    
    return Cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let webViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MediaWebViewController") as! WebViewController
    var student = OTMClient.sharedInstance().students[indexPath.row]
    
    if let mediaUrl = student.mediaUrl {
      var urlStr = mediaUrl
      if !urlStr.hasPrefix("http://") {
        urlStr = "http://\(urlStr)"
      }
      var url = NSURL(string: urlStr)
      if let url = url as NSURL! {
        webViewController.urlRequest = NSMutableURLRequest(URL: url)
      }
    }
    
    dispatch_async(dispatch_get_main_queue(), {
      self.presentViewController(webViewController, animated: true, completion: nil)
    })
  }
}