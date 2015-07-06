//
//  WebViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 28/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//



import UIKit

/// Web view
class WebViewController: UIViewController, UIWebViewDelegate  {
  
  
  @IBOutlet weak var activityView: UIActivityIndicatorView!
  @IBOutlet weak var errorTextField: UITextView!
  @IBOutlet weak var sadImage: UIImageView!
  @IBOutlet weak var webView: UIWebView!
  var urlRequest: NSURLRequest? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.delegate = self
    self.webView.hidden = false
    self.sadImage.hidden = true
    self.activityView.hidden = false
    
    /// set defaults and style for error field
    errorTextField.text = ""
    errorTextField.font = UIFont(name: "AvenirNext-Medium", size: 20)
    errorTextField.textColor = UIColor.blackColor()
    
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
    super.viewWillAppear(animated)
    
    /// if there is a valid url try to load it
    if let urlRequest = urlRequest {
      self.webView.loadRequest(urlRequest)
    }
    else
    {
      displayError("Invalid URL provided")
    }
  }
  
  /// success loading page
  func webViewDidFinishLoad(webView: UIWebView) {
    self.activityView.hidden = true
  }
  
  /// failed to load the page
  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    displayError(error.localizedDescription)
  }
  
  /// Set the error on the web view and a sad face :(
  func displayError(error: String) {
    self.activityView.hidden = true
    dispatch_async(dispatch_get_main_queue(), {
      self.webView.hidden = true
      self.errorTextField.text = error
      self.sadImage.hidden = false
    })
  }
  
  /// dismiss the view
  @IBAction func doneWithView(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
    
  }
}


