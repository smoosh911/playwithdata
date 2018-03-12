//
//  InterfaceController.swift
//  watchkit Extension
//
//  Created by miperry on 3/10/18.
//  Copyright © 2018 miperry. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    let motion = CMMotionManager()
    var wcSession: WCSession!
    
    let numbers = [200,1,2,3]
    
    @IBOutlet var list: WKInterfacePicker!
    
    @IBAction func listAction(_ value: Int) {
        let message = ["message": "\(numbers[value])"]
        wcSession.sendMessage(message, replyHandler: nil) { (error) in
            print(error)
        }
    }
    
    var counter = 0
    var xyzData = "x,y,z\n"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let item = WKPickerItem()
        let item1 = WKPickerItem()
        let item2 = WKPickerItem()
        let item3 = WKPickerItem()
        item.title = "\(numbers[0])"
        item1.title = "\(numbers[1])"
        item2.title = "\(numbers[2])"
        item3.title = "\(numbers[3])"
        list.setItems([item, item1, item2, item3])
        
        if self.motion.isAccelerometerAvailable { // && self.motion.isGyroAvailable {
            print("we are in")
//            self.motion.gyroUpdateInterval = 1.0 / 60.0
//            self.motion.startGyroUpdates()
            self.motion.accelerometerUpdateInterval = 2.0 / 60.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            
            // Configure a timer to fetch the data.
            let timer = Timer(fire: Date(), interval: (2.0/60.0),  repeats: true, block: { (timer) in
                // Get the accelerometer data.
                if let data = self.motion.accelerometerData {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    let stringOfData = "\(x),\(y),\(z)\n"
                    self.xyzData += stringOfData
                }
//                if let data = self.motion.gyroData {
//                    let x = data.rotationRate.x
//                    let y = data.rotationRate.y
//                    let z = data.rotationRate.z
//                    let stringOfData = "\(x),\(y),\(z),Gyroscope\n"
//                    self.xyzData += stringOfData
//                }
                self.counter += 1
                if (self.counter % 900) == 0 {
                    let message = ["message": self.xyzData]
                    self.wcSession.sendMessage(message, replyHandler: nil) { (error) in
                        print(error)
                    }
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        motion.stopAccelerometerUpdates()
        motion.stopGyroUpdates()
    }

}
