//
//  Session.swift
//  Boost
//
//  Created by Gautier Delorme on 06/01/2015.
//  Copyright (c) 2015 Gautier Delorme. All rights reserved.
//

import UIKit
import MultipeerConnectivity

@objc protocol SessionDelegate {
    optional func didReceiveStream(stream: NSInputStream, fromPeer peerID:MCPeerID)
    optional func didReceiveData(data: NSData)
    optional func didConnectToPeer(peerID: MCPeerID)
}

class Session: NSObject, MCSessionDelegate, MCBrowserViewControllerDelegate {
    let peerID : MCPeerID!
    let session : MCSession!
    let advertiser : MCAdvertiserAssistant!
    let browser : MCBrowserViewController!
    let serviceType : String!
    var delegate : SessionDelegate!
    
    override init() {
        super.init()
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
        serviceType = "boost-music"
        browser = MCBrowserViewController(serviceType:serviceType, session:self.session)
        browser.delegate = self
        advertiser = MCAdvertiserAssistant(serviceType:serviceType, discoveryInfo:nil, session:session)
        println("init ok !");
    }
    
    // MARK: - MCSessionDelegate
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
        
        if state == MCSessionState.Connecting {
            println("Connecting to \(peerID.displayName)")
        } else if state == MCSessionState.Connected {
            println("Connected to \(peerID.displayName)")
            delegate.didConnectToPeer?(peerID)
        } else if state == MCSessionState.NotConnected {
            println("Disconnected from \(peerID.displayName)")
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!)  {
            // Called when a peer sends an NSData to us
        delegate.didReceiveData?(data)
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!)  {
            // Called when a peer establishes a stream with us
        delegate.didReceiveStream?(stream, fromPeer: peerID)
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!)  {
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!)  {
            // Called when a file has finished transferring from another peer
    }
    
    // MARK: - MCBrowserViewControllerDelegate
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!)  {
            browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!)  {
            browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Others
    
    func openStreamToPeer(peerID: MCPeerID) -> NSOutputStream {
        var error : NSError? = nil
        var streamName = String(format: "%f", NSDate.timeIntervalSinceReferenceDate())
        println(streamName)
        var stream: NSOutputStream? = session.startStreamWithName(streamName, toPeer: peerID, error: &error)
        if error != nil {
            println("error stream \(error!.localizedDescription)")
        }
        return stream!
    }
    
    func startAdvertiser() {
        advertiser.start()
    }
    
    func sendData(data: NSData) {
        var error :NSError?
        session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)
        if error != nil {
            println("error send data : \(error?.userInfo)")
        }
    }
    
    func connectedPeers() -> [AnyObject] {
        return session.connectedPeers
    }
}
