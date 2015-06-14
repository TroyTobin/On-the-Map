//
//  TableViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 7/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.

import UIKit

class StudentTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
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
    OTMClient.sharedInstance().loadStudentLocations() { result, errorString in
      if let parsedResult = result as? NSDictionary {
        if let results = parsedResult.valueForKey("results") as? NSArray {
          self.Students = results
          NSNotificationCenter.defaultCenter().postNotificationName("refreshListView", object: nil)
        }
      }
    }
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
          if let media = student["mediaURL"] as? String {
            Cell.textLabel!.text = "\(firstName) \(lastName)"
            Cell.detailTextLabel!.text = media
          }
        }
      }
    }
    Cell.imageView!.image = UIImage(named: "Pin")
    
    return Cell
  }
}