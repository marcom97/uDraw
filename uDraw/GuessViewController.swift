//
//  GuessViewController.swift
//  uDraw
//
//  Created by Marco Matamoros on 11/16/14.
//  Copyright (c) 2014 BlueStars. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GuessViewController: UIViewController, MCSessionDelegate, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var textField : UITextField?
    var received = 0
    var word : NSString?
    
    var label : UILabel?

    @IBOutlet weak var drawingImage: UIImageView!
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"peerDidChangeStateWithNotification:", name: "MCDidChangeStateNotification", object: nil)
        
        appDelegate.mcManager.session.delegate = self
        
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.height-44, self.view.frame.width, 44))
        textField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width-90, 30))
        textField?.borderStyle = UITextBorderStyle.RoundedRect
        let textFieldItem = UIBarButtonItem(customView: textField!)
        let guessButton = UIBarButtonItem(title: "Guess", style: UIBarButtonItemStyle.Plain, target: self, action: "checkWords")
        textField?.delegate = self
        
        label = UILabel(frame: CGRectMake(0, 21, self.view.frame.width, 21))
        label?.textAlignment = NSTextAlignment.Center
        self.view.addSubview(label!)


        
        toolBar.items = [textFieldItem, guessButton]
    self.view.addSubview(toolBar)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        textField?.resignFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
    func peerDidChangeStateWithNotification(notification: NSNotification)
    {
        let state: MCSessionState = MCSessionState(rawValue: Int(notification.userInfo?["state"] as NSNumber)) as MCSessionState!
        
        if (state != MCSessionState.Connecting)
        {
            if (state == MCSessionState.NotConnected)
            {
                let viewController: UIViewController = storyboard?.instantiateViewControllerWithIdentifier("first") as UIViewController
                presentViewController(viewController, animated: true, completion: nil)
            }
            
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!,
        fromPeer peerID: MCPeerID!)  {
            // Called when a peer sends an NSData to us
            if (received == 0)
            {
                word = NSString(data: data, encoding: NSUTF8StringEncoding)
                received = 1
            }
            else
            {
            // This needs to run on the main queue
            dispatch_async(dispatch_get_main_queue())
                {
                
                var msg = UIImage(data: data)
                self.drawingImage.image = msg
                
                }
            }
    }
    
    func checkWords()
    {
        if (textField?.text != "")
        {
        var guess = textField?.text
        if (guess?.caseInsensitiveCompare(word!) == NSComparisonResult.OrderedSame)
            {
                label?.text = "Correct"
            }
            
            else if(levenshtein(guess!, bStr: word!) < 2)
            {
                label?.text = "Correct"
            }
            
            else if (levenshtein(guess!, bStr: word!) < 3)
            {
                label?.text = "Close Guess"
            }
        }
    }
    func levenshtein(aStr: String, bStr: String) -> Int {
        // create character arrays
        let a = Array(aStr)
        let b = Array(bStr)
        
        // initialize matrix of size |a|+1 * |b|+1 to zero
        var dist = [[Int]]()
        for row in 0...a.count {
            dist.append([Int](count: b.count + 1, repeatedValue: 0))
        }
        
        // 'a' prefixes can be transformed into empty string by deleting every char
        for i in 1...a.count {
            dist[i][0] = i
        }
        
        // 'b' prefixes can be created from empty string by inserting every char
        for j in 1...b.count {
            dist[0][j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i][j] = dist[i-1][j-1]  // noop
                } else {
                    dist[i][j] = min(
                        dist[i-1][j] + 1,  // deletion
                        dist[i][j-1] + 1,  // insertion
                        dist[i-1][j-1] + 1  // substitution
                    )
                }
            }
        }
        
        return dist[a.count][b.count]
    }
    
    func session(session: MCSession!,
        didStartReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession!,
        didFinishReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!,
        atURL localURL: NSURL!, withError error: NSError!)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!,
        withName streamName: String!, fromPeer peerID: MCPeerID!)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!,
        didChangeState state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
            
    }

}
