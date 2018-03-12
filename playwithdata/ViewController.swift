//
//  ViewController.swift
//  playwithdata
//
//  Created by miperry on 3/10/18.
//  Copyright © 2018 miperry. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreMotion
import MessageUI

class ViewController: UIViewController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    static var messageCount = 1
    static var accelerometerData = ""
    var wcSession: WCSession!
    
    let motion = CMMotionManager()
    
    @IBOutlet weak var lblNumber: UILabel!
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        ViewController.accelerometerData = message["message"] as! String
        ViewController.messageCount += 1
        lblNumber.text = "\(ViewController.messageCount)"
        
        if ViewController.accelerometerData != "" {
            // Converting it to NSData.
            let data = ViewController.accelerometerData.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)
            
            // Unwrapping the optional.
            if let content = data {
                print("NSData: \(content)")
            }
            
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            emailController.setSubject("CSV File")
            emailController.setMessageBody("", isHTML: false)
            emailController.setToRecipients(["smoosh12@msn.com"])
            
            // Attaching the .CSV file to the email.
            emailController.addAttachmentData(data!, mimeType: "text/csv", fileName: "Sample.csv")
            
            if MFMailComposeViewController.canSendMail() {
                self.present(emailController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

