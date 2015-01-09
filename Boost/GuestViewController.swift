//
//  GuestViewController.swift
//  Boost
//
//  Created by Gautier Delorme on 06/01/2015.
//  Copyright (c) 2015 Gautier Delorme. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Foundation

class GuestViewController: UIViewController, SessionDelegate {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let connectButton = UIButton()
    
    var stream: NSInputStream!
    var session = Session()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor.redColor()
        connectButton.frame = CGRectMake(5, 30, 70, 10)
        connectButton.setTitle("Connect", forState: UIControlState.Normal)
        connectButton.addTarget(self, action: "connect:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(connectButton)

        session.delegate = self
    }
    
    // MARK: - SessionDelegate
    
    func didReceiveStream(stream: NSInputStream, fromPeer peerID: MCPeerID) {
        self.stream = stream
        dispatch_async(dispatch_get_main_queue()) {
            TDAudioPlayer.sharedAudioPlayer().loadAudioFromStream(stream)
            TDAudioPlayer.sharedAudioPlayer().play()
        }
    }
    
    func didReceiveData(data: NSData) {
        dispatch_async(dispatch_get_main_queue()) {
            var msg = NSString(data: data, encoding: NSUTF8StringEncoding)
            if msg == "pause" {
                TDAudioPlayer.sharedAudioPlayer().pause()
            } else if msg == "play" {
                TDAudioPlayer.sharedAudioPlayer().play()
            }else {
                let info = NSKeyedUnarchiver.unarchiveObjectWithData(data) as NSDictionary
                println(info["artist"])
            }
        }
    }
    
    // MARK: - Others
    
    func connect(sender:UIButton!) {
        self.presentViewController(session.browser, animated: true, completion: nil)
    }
}
