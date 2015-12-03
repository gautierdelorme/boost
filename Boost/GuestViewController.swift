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
import MediaPlayer

class GuestViewController: UIViewController, SessionDelegate {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var meta = TDAudioMetaInfo()
    var session = Session()
    
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    let albumLabel = UILabel()
    
    let volumeSlider = UISlider()
    
    let artworkImageView = UIImageView()
    var topY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.view.backgroundColor = UIColor.clearColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Connect", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("connect:"))
        topY = self.navigationController?.navigationBar.frame.size.height
        titleLabel.frame = CGRectMake(10,topY+20, screenSize.width-20, 30)
        titleLabel.text = "No title"
        titleLabel.textAlignment = NSTextAlignment.Center
        artistLabel.frame = CGRectMake(10, titleLabel.frame.origin.y+titleLabel.frame.size.height+20, screenSize.width-20, 30)
        artistLabel.text = "No artist"
        artistLabel.textAlignment = NSTextAlignment.Center
        artworkImageView.frame = CGRectMake(40, artistLabel.frame.origin.y+artistLabel.frame.size.height+20, screenSize.width-80, screenSize.width-80)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(artistLabel)
        self.view.addSubview(artworkImageView)
        session.delegate = self
        
        var volumeView = MPVolumeView(frame: CGRectMake(0, artworkImageView.frame.origin.y+artworkImageView.frame.size.height+20, screenSize.width-20, 15))
        volumeView.center = CGPointMake(self.view.center.x, volumeView.center.y)
        volumeView.showsVolumeSlider = true
        volumeView.showsRouteButton = true
        volumeView.sizeToFit()
        self.view.addSubview(volumeView)
    }
    
    // MARK: - SessionDelegate
    
    func didReceiveStream(stream: NSInputStream, fromPeer peerID: MCPeerID) {
        //dispatch_async(dispatch_get_main_queue()) {
            println("e: \(self.meta.duration)")
            self.titleLabel.text = self.meta.title
            self.artistLabel.text = self.meta.artist
            TDAudioPlayer.sharedAudioPlayer().loadAudioFromStream(stream)
            var currentAdd = CFAbsoluteTimeGetCurrent()+2
            var msg: String! = currentAdd.description
            let msgData = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            self.session.sendData(msgData!)
            while CFAbsoluteTimeGetCurrent() < currentAdd {
                println("wait...")
            }
            //println("before play : \(CFAbsoluteTimeGetCurrent())")
            TDAudioPlayer.sharedAudioPlayer().play()
            //println("after play : \(CFAbsoluteTimeGetCurrent())")
        //}
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
                self.meta.title = info["title"] as? String
                println(info["artist"])
                self.meta.artist = info["artist"] as? String
                self.meta.duration = info["duration"] as? NSNumber
                self.artworkImageView.image = info["artwork"] as? UIImage
            }
        }
    }
    
    // MARK: - Others
    
    func connect(sender:UIBarButtonItem!) {
        self.presentViewController(session.browser, animated: true, completion: nil)
    }
}
