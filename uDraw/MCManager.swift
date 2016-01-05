//
//  MCManager.swift
//  uDraw
//
//  Created by Marco Matamoros on 11/15/14.
//  Copyright (c) 2014 BlueStars. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MCManager: NSObject, MCSessionDelegate
{
    var peerID:MCPeerID?
    var session:MCSession!
    var browser:MCBrowserViewController?
    var advertiser:MCAdvertiserAssistant!
    

    
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState)
    {

        let dict: NSDictionary = ["peerID": peerID,"state" : state.rawValue]
        
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: dict as [NSObject : AnyObject])
        
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID)
    {
        
    }
    
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress)
    {
        
    }
    
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?)
    {
        
    }
    
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        
    }
    
    func setupPeerAndSessionWithDisplayName(displayName: NSString)
    {
        peerID = MCPeerID(displayName: displayName as String)
        
        session = MCSession(peer: peerID!)
        session.delegate = self
    }
    
    func setupMCBrowser()
    {
        browser = MCBrowserViewController(serviceType: "uDraw", session: session)
    }
    
    func advertiseSelf()
    {
        advertiser = MCAdvertiserAssistant(serviceType: "uDraw", discoveryInfo: nil, session: session)
        advertiser.start()
    }
    
    
}
