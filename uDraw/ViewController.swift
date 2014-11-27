//
//  ViewController.swift
//  uDraw
//
//  Created by Marco Matamoros on 11/15/14.
//  Copyright (c) 2014 BlueStars. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.mcManager.setupPeerAndSessionWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mcManager.advertiseSelf()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"peerDidChangeStateWithNotification:", name: "MCDidChangeStateNotification", object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func nearbyButton(sender: UIButton)
    {
        appDelegate.mcManager.setupMCBrowser()
        appDelegate.mcManager.browser?.delegate = self
        presentViewController(appDelegate.mcManager.browser!, animated: true, completion: nil)
    }
    
    @IBAction func onlineButton(sender: UIButton) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func peerDidChangeStateWithNotification(notification: NSNotification)
    {
        let state: MCSessionState = MCSessionState(rawValue: Int(notification.userInfo?["state"] as NSNumber)) as MCSessionState!
        
        if (state != MCSessionState.Connecting)
        {
            if (state == MCSessionState.Connected)
            {
                performSegueWithIdentifier("startGuess", sender: self)
            }
            
        }

    }
    
    func browserViewControllerDidFinish(
        browserViewController: MCBrowserViewController!)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            performSegueWithIdentifier("NearbyDraw", sender: self)
    }
    
    func browserViewControllerWasCancelled(
        browserViewController: MCBrowserViewController!)  {
            // Called when the browser view controller is cancelled
            
            self.dismissViewControllerAnimated(true, completion: nil)
            appDelegate.mcManager.session.disconnect()
    }


}

