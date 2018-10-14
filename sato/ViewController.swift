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
    @IBOutlet weak var responseProgressView: UIProgressView!
    
    var responseDone: Bool?
    var progressTimer: Timer?
    
    @IBAction func refresh(_ sender: Any) {
        webView.reload()
    }
    
    @objc func progressTimerCallback() {
        if responseDone! {
            if responseProgressView.progress >= 1 {
                progressTimer!.invalidate()
            } else {
                responseProgressView.progress += 0.1
            }
        } else {
            if responseProgressView.progress >= 0.95 {
                responseProgressView.progress = 0.95
            } else {
                responseProgressView.progress += 0.01
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        urlTextField.text = webView.url?.absoluteString
        
        // response progress view
        responseProgressView.progress = 0.0
        responseDone = false
        progressTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(progressTimerCallback), userInfo: nil, repeats: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        responseDone = true
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }

}

