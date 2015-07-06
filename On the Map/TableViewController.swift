//
//  TableViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 7/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.

import UIKit

/// Table view controller to display student information
class StudentTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet var TableView: UITableView!
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    /// we are a delegate to the table view
    TableView.dataSource = self
    TableView.delegate = self
    
    /// Add observers for refreshing the view and the student information
    /// Refresh button pressed
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStudentInformation:", name: "refreshView",object: nil)
    /// Student information downloaded so need to refresh the view
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshListView:", name: "refreshListView",object: nil)
    
    /// Finally make sure the student information is loaded
    loadStudentInformation()
  }
  
  /// Refresh the student information
  func refreshStudentInformation(notification: NSNotification) {
    loadStudentInformation()
  }
  
  /// refresh the list view
  func refreshListView(notification: NSNotification) {
    dispatch_async(dispatch_get_main_queue(), {
      self.TableView.reloadData()
    })
  }
  
  /// Load student information bu doing a request to download it via the OTMClient
  func loadStudentInformation() {
    OTMClient.sharedInstance().loadStudentLocations() { result, errorString in
      
      if let error = errorString {
        /// display any errors
        ErrorViewController.displayError(self, error: error, title: "Load Student Information Failed")
      }
      
      /// all good so refresh the view by send a notification
      NSNotificationCenter.defaultCenter().postNotificationName("refreshListView", object: nil)
    }
  }
  
  /// delegate function to return the count of elements
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return OTMClient.sharedInstance().students.count
  }
  
  
  /// delegate function to set a cell contents
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    /// get a reusable cell to populate
    let Cell = tableView.dequeueReusableCellWithIdentifier("StudentTableCell") as! UITableViewCell
    
    /// get the student at the index
    var student = OTMClient.sharedInstance().students[indexPath.row]
    
    /// set the cell contents
    if let firstName = student.firstName, lastName = student.lastName, mediaUrl = student.mediaUrl {
      Cell.textLabel!.text = "\(firstName) \(lastName)"
      Cell.detailTextLabel!.text = mediaUrl
    }
    
    Cell.imageView!.image = UIImage(named: "Pin")
    
    return Cell
  }
  
  /// delegate function when cell selected.  Want to load student media url in web view
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let webViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MediaWebViewController") as! WebViewController
    var student = OTMClient.sharedInstance().students[indexPath.row]
    
    /// get the url and spws a web view
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