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
    

    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {

        let dict = ["peerID": peerID,"state" : state.rawValue] as [String : Any]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MCDidChangeStateNotification"), object: nil, userInfo: dict)
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    {
        
    }
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress)
    {
        
    }
    
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?)
    {
        
    }
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        
    }
    
    func setupPeerAndSessionWithDisplayName(_ displayName: String)
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
