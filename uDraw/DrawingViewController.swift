//
//  DrawingViewController.swift
//  uDraw
//
//  Created by Marco Matamoros on 11/16/14.
//  Copyright (c) 2014 BlueStars. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DrawingViewController: UIViewController  {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var tempDrawImage: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    var lastPoint = CGPoint()
    //var red : CGFloat?
    //var green : CGFloat?
    //CGFloat blue;
    //CGFloat brush;
    //CGFloat opacity;
    var touchSwiped = Bool()

    override func viewDidLoad()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(DrawingViewController.peerDidChangeStateWithNotification(_:)), name: NSNotification.Name(rawValue: "MCDidChangeStateNotification"), object: nil)
        getWord()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchSwiped = false
        let touch: UITouch = touches.first!
        lastPoint = touch.location(in: self.view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchSwiped = true
        let touch: UITouch = touches.first!
        let currentPoint = touch.location(in: self.view)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.mainImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
        UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
        UIGraphicsGetCurrentContext()?.setLineWidth(10 )
        UIGraphicsGetCurrentContext()?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.normal)
        
        UIGraphicsGetCurrentContext()?.strokePath()
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        lastPoint = currentPoint
        
        sendImage(mainImage.image!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!touchSwiped) {
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.mainImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(10)
            UIGraphicsGetCurrentContext()?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.strokePath()
            self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        sendImage(mainImage.image!)
        
        
    }
    
    @objc func peerDidChangeStateWithNotification(_ notification: Notification)
    {
        let state = MCSessionState(rawValue: notification.userInfo!["state"] as! Int)
        
        if (state != MCSessionState.connecting)
        {
            if (state == MCSessionState.notConnected)
            {
                let viewController: UIViewController = (storyboard?.instantiateViewController(withIdentifier: "first") as UIViewController?)!
                present(viewController, animated: true, completion: nil)

            }
            
        }
    }
    
    func sendImage(_ image: UIImage)
    {
        let msg = image.pngData()!
        
        try! appDelegate.mcManager.session.send(msg, toPeers: appDelegate.mcManager.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
    }
    
    func getWord ()
    {
        let wordsArray = ["apple", "book", "pencil"]
        let msg = wordsArray[Int( arc4random())%wordsArray.count]
        
        let label = UILabel(frame: CGRect(x: 0, y: 21, width: self.view.frame.width, height: 21))
        label.textAlignment = NSTextAlignment.center

        label.text = msg;
        
        self.view.addSubview(label)
        
        try! appDelegate.mcManager.session.send(msg.data(using: String.Encoding.utf8,
            allowLossyConversion: false)!, toPeers: appDelegate.mcManager.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        
    }

}
