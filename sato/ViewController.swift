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
    
    let ResponseTimeout: Double = 20
    
    var responseDone: Bool?
    var progressTimer: Timer?
    var responseTimer: Timer?
    var currentEnvironment: String?
    
    func showAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        webView.reload()
    }
    
    @objc func responseTimerCallback() {
        NSLog("\(urlTextField.text ?? "unknown") url response timeout after \(String(ResponseTimeout)) s")
        webView.stopLoading()
        responseFinished()
        showAlert(alertMessage: "Response timeout.")
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
    
    func responseFinished() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        responseDone = true
        responseTimer?.invalidate()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        urlTextField.text = webView.url?.absoluteString
        
        // response timeout
        responseTimer = Timer.scheduledTimer(timeInterval: ResponseTimeout, target: self, selector: #selector(responseTimerCallback), userInfo: nil, repeats: false)
        
        // response progress view
        responseProgressView.progress = 0.0
        responseDone = false
        progressTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(progressTimerCallback), userInfo: nil, repeats: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        responseFinished()
    }
    
    func registerAndObserveSettingsBundle() {
        UserDefaults.standard.register(defaults: [String:AnyObject]())
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    func url(environment: String) -> String {
        switch environment {
        case "demo":
            return "https://sporomatdemo5.apptest.slsp.sk"
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
        let environment = UserDefaults.standard.string(forKey: "environment") ?? "test"
        if (environment != currentEnvironment) {
            currentEnvironment = environment
            webView.load(URLRequest(url: URL(string: url(environment: environment))!))
        }
    }
    
    @objc func defaultsChanged(notification: NSNotification) {
        if (notification.object as? UserDefaults) != nil {
            updateDisplayFromDefaults()
        }
    }
    
    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerAndObserveSettingsBundle()
        updateDisplayFromDefaults()
    }

}

