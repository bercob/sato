//
//  ViewController.swift
//  sato
//
//  Created by Peter Balogh on 11/10/2018.
//  Copyright © 2018 slsp. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBAction func refresh(_ sender: Any) {
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        urlTextField.text = webView.url?.absoluteString
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func registerSettingsBundle() {
        UserDefaults.standard.register(defaults: [String:AnyObject]())
    }
    
    func url() -> String {
        let environment = UserDefaults.standard.string(forKey: "environment")
        switch environment {
        case "dit2":
            return "https://tabletsato21.apptest.slsp.sk"
        case "uat2":
            return "https://tabletsato4.apptest.slsp.sk"
        default:
            // test
            return "https://www.google.com"
        }
    }
    func updateDisplayFromDefaults() {
        webView.load(URLRequest(url: URL(string: url())!))
    }
    
    @objc func defaultsChanged() {
        updateDisplayFromDefaults()
    }
    
    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
        urlTextField.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSettingsBundle()
        updateDisplayFromDefaults()
        
//        NSNotification.addObserver(NSuser, forKeyPath: "defaultsChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }

}

