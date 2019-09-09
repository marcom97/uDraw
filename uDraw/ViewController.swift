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

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.mcManager.setupPeerAndSessionWithDisplayName(UIDevice.current.name)
        appDelegate.mcManager.advertiseSelf()
        
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.peerDidChangeStateWithNotification(_:)), name: NSNotification.Name(rawValue: "MCDidChangeStateNotification"), object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func nearbyButton(_ sender: UIButton)
    {
        appDelegate.mcManager.setupMCBrowser()
        appDelegate.mcManager.browser?.delegate = self
        present(appDelegate.mcManager.browser!, animated: true, completion: nil)
    }
    
    @IBAction func onlineButton(_ sender: UIButton) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func peerDidChangeStateWithNotification(_ notification: Notification)
    {
        let state: MCSessionState? = MCSessionState(rawValue: Int(truncating: notification.userInfo?["state"] as! NSNumber)) as MCSessionState?
        
        if (state != MCSessionState.connecting)
        {
            if (state == MCSessionState.connected)
            {
                performSegue(withIdentifier: "startGuess", sender: self)
            }
            
        }

    }
    
    func browserViewControllerDidFinish(
        _ browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismiss(animated: true, completion: nil)
            
            performSegue(withIdentifier: "NearbyDraw", sender: self)
    }
    
    func browserViewControllerWasCancelled(
        _ browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is cancelled
            
            self.dismiss(animated: true, completion: nil)
            appDelegate.mcManager.session.disconnect()
    }


}

