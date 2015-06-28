//
//  WebViewController.swift
//  On the Map
//
//  Created by Troy Tobin on 28/06/2015.
//  Copyright (c) 2015 ttobin. All rights reserved.
//



import UIKit

class WebViewController: UIViewController, UIWebViewDelegate  {
  
  
  @IBOutlet weak var errorTextField: UITextView!
  @IBOutlet weak var sadImage: UIImageView!
  @IBOutlet weak var webView: UIWebView!
  var urlRequest: NSURLRequest? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.delegate = self
    self.webView.hidden = false
    self.sadImage.hidden = true
    
    
    errorTextField.text = ""
    errorTextField.font = UIFont(name: "AvenirNext-Medium", size: 20)
    errorTextField.textColor = UIColor.blackColor()
    
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
    super.viewWillAppear(animated)
    
    if let urlRequest = urlRequest {
      self.webView.loadRequest(urlRequest)
    }
    else
    {
      displayError("Invalid URL provided")
    }
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    println("here")
    println(webView.request!.URL!.absoluteString!)
  }
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    displayError(error.localizedDescription)
  }
  
  
  func displayError(error: String) {
    println("error \(error)")
    dispatch_async(dispatch_get_main_queue(), {
      self.webView.hidden = true
      self.errorTextField.text = error
      self.sadImage.hidden = false
    })
  }
  
  @IBAction func doneWithView(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
    
  }
}


