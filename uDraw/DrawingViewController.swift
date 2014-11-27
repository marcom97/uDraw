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
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    
    var lastPoint = CGPoint()
    //var red : CGFloat?
    //var green : CGFloat?
    //CGFloat blue;
    //CGFloat brush;
    //CGFloat opacity;
    var mouseSwiped = Bool()

    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"peerDidChangeStateWithNotification:", name: "MCDidChangeStateNotification", object: nil)
        getWord()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        mouseSwiped = false
        var touch: UITouch = touches.anyObject() as UITouch
        lastPoint = touch.locationInView(self.view)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        mouseSwiped = true
        var touch: UITouch = touches.anyObject() as UITouch
        var currentPoint = touch.locationInView(self.view)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.tempDrawImage.image?.drawInRect(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10 )
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0)
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal)
        
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
        self.tempDrawImage.alpha = 1
        UIGraphicsEndImageContext()
        
        lastPoint = currentPoint
        
        UIGraphicsBeginImageContext(self.mainImage.frame.size)
        self.mainImage.image?.drawInRect((CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)), blendMode: kCGBlendModeNormal, alpha: 1.0)
        self.tempDrawImage.image?.drawInRect((CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)), blendMode: kCGBlendModeNormal, alpha: 1.0)
        
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
        self.tempDrawImage.image = nil
        UIGraphicsEndImageContext()
        
        sendImage(mainImage.image!)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if(!mouseSwiped) {
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.tempDrawImage.image?.drawInRect(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
            
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10)
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0)
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
            CGContextStrokePath(UIGraphicsGetCurrentContext())
            CGContextFlush(UIGraphicsGetCurrentContext())
            self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContext(self.mainImage.frame.size)
        self.mainImage.image?.drawInRect((CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)), blendMode: kCGBlendModeNormal, alpha: 1.0)
        self.tempDrawImage.image?.drawInRect((CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)), blendMode: kCGBlendModeNormal, alpha: 1.0)
        
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
        self.tempDrawImage.image = nil
        UIGraphicsEndImageContext()
        
        sendImage(mainImage.image!)
        
        
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
    
    func sendImage(image: UIImage)
    {
        let msg = UIImagePNGRepresentation(image)
        
        var error : NSError?
        
        appDelegate.mcManager.session.sendData(msg, toPeers: appDelegate.mcManager.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)
        
        if error != nil {
            print("Error sending data: \(error?.localizedDescription)")
        }
        
    }
    
    func getWord ()
    {
        let wordsArray = ["apple", "book", "pencil"]
        let msg = wordsArray[Int( arc4random())%wordsArray.count]
        
        let label = UILabel(frame: CGRectMake(0, 21, self.view.frame.width, 21))
        label.textAlignment = NSTextAlignment.Center

        label.text = msg;
        
        self.view.addSubview(label)
        
        var error : NSError?
        
        appDelegate.mcManager.session.sendData(msg.dataUsingEncoding(NSUTF8StringEncoding,
            allowLossyConversion: false), toPeers: appDelegate.mcManager.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
    }

}
