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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var textField : UITextField?
    var received = 0
    var word : String?
    
    var label : UILabel?

    @IBOutlet weak var drawingImage: UIImageView!
    
    override func viewDidLoad()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(GuessViewController.peerDidChangeStateWithNotification(_:)), name: Notification.Name(rawValue: "MCDidChangeStateNotification"), object: nil)
        
        appDelegate.mcManager.session.delegate = self
        
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.height-44, width: self.view.frame.width, height: 44))
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-90, height: 30))
        textField?.borderStyle = UITextBorderStyle.roundedRect
        let textFieldItem = UIBarButtonItem(customView: textField!)
        let guessButton = UIBarButtonItem(title: "Guess", style: UIBarButtonItemStyle.plain, target: self, action: #selector(GuessViewController.checkWords))
        textField?.delegate = self
        
        label = UILabel(frame: CGRect(x: 0, y: 21, width: self.view.frame.width, height: 21))
        label?.textAlignment = .center
        self.view.addSubview(label!)


        
        toolBar.items = [textFieldItem, guessButton]
    self.view.addSubview(toolBar)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField?.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
    func peerDidChangeStateWithNotification(_ notification: Notification)
    {
        let state: MCSessionState = MCSessionState(rawValue: notification.userInfo!["state"] as! Int)!
        
        if (state != MCSessionState.connecting)
        {
            if (state == MCSessionState.notConnected)
            {
                let viewController: UIViewController? = storyboard?.instantiateViewController(withIdentifier: "first") as UIViewController?
                present(viewController!, animated: true, completion: nil)
            }
            
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data,
        fromPeer peerID: MCPeerID)  {
            // Called when a peer sends an NSData to us
            if (received == 0)
            {
                word = String(data: data, encoding: String.Encoding.utf8)
                received = 1
            }
            else
            {
            // This needs to run on the main queue
            DispatchQueue.main.async
                {
                
                let msg = UIImage(data: data)
                self.drawingImage.image = msg
                
                }
            }
    }
    
    func checkWords()
    {
        if (textField?.text != "")
        {
            let guess = textField?.text
            if (guess?.caseInsensitiveCompare(word! as String) == ComparisonResult.orderedSame)
            {
                label?.text = "Correct"
            }
                
            else if(levenshtein(guess!, bStr: word! as String) < 2)
            {
                label?.text = "Correct"
            }
                
            else if (levenshtein(guess!, bStr: word! as String) < 3)
            {
                label?.text = "Close Guess"
            }
        }
    }
    
    func levenshtein(_ aStr: String, bStr: String) -> Int {
        // create character arrays
        let a = Array(aStr.characters)
        let b = Array(bStr.characters)
        
        // initialize matrix of size |a|+1 * |b|+1 to zero
        var dist = [[Int]]()
        for _ in 0...a.count {
            dist.append([Int](repeating: 0, count: b.count + 1))
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
                    let deletion = dist[i-1][j] + 1
                    let insertion = dist[i][j-1] + 1
                    let substitution = dist[i-1][j-1] + 1
                    
                    dist[i][j] = min(
                        deletion,  // deletion
                        insertion,  // insertion
                        substitution  // substitution
                    )
                }
            }
        }
        
        return dist[a.count][b.count]
    }
    
    func session(_ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with progress: Progress)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(_ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?, withError error: Error?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream,
        withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID,
        didChange state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
            
    }

}
