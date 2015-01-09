//
//  HostViewController.swift
//  Boost
//
//  Created by Gautier Delorme on 06/01/2015.
//  Copyright (c) 2015 Gautier Delorme. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MediaPlayer
import AVFoundation

class HostViewController: UIViewController, SessionDelegate, MPMediaPickerControllerDelegate {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let musicButton = UIButton()
    let pauseButton = UIButton()
    var stream: NSOutputStream!
    var session = Session()
    var isPaused: Bool!
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor.blueColor()
        musicButton.frame = CGRectMake(5, 50, 70, 10)
        musicButton.setTitle("Music", forState: UIControlState.Normal)
        musicButton.addTarget(self, action: "addSongs:", forControlEvents: UIControlEvents.TouchUpInside)
        pauseButton.frame = CGRectMake(screenSize.width/2, 50, 70, 10)
        pauseButton.setTitle("Pause", forState: UIControlState.Normal)
        pauseButton.addTarget(self, action: "pauseMusic:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(musicButton)
        self.view.addSubview(pauseButton)
        isPaused = false
        session.delegate = self
        session.startAdvertiser()
    }
    
    // MARK: - SessionDelegate
    
    func didConnectToPeer(peerID: MCPeerID) {
        /*stream = session.openStreamToPeer(peerID)
        stream.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        stream.open()*/
        println("peers : \(session.connectedPeers().count)")
    }
    
    // MARK: - Others
    
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let song = mediaItemCollection.items[0] as MPMediaItem
        let info = NSMutableDictionary()
        info.setValue(song.title as String!, forKey: "title")
        info.setValue(song.artist as String!, forKey: "artist")
        
        println(info["title"])
        
        session.sendData(NSKeyedArchiver.archivedDataWithRootObject(info.copy()))
        
        let musicUrl: NSURL? = mediaItemCollection.items[0].valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
        if musicUrl != nil {
            if  session.connectedPeers().count > 0 {
                let avAsset: AVAsset = AVAsset.assetWithURL(musicUrl) as AVAsset
                let playerItem = AVPlayerItem(asset: avAsset)
                player = AVPlayer(playerItem: playerItem)
                
                for i in session.connectedPeers() {
                    var outputStreamer = TDAudioOutputStreamer(outputStream: session.openStreamToPeer(i as MCPeerID))
                    outputStreamer.streamAudioFromURL(musicUrl)
                    outputStreamer.start()
                }
                player.play()
            }
        } else {
            println("Can't play this song")
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addSongs(sender:UIButton!) {
        let picker = MPMediaPickerController(mediaTypes: MPMediaType.Music);
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func pauseMusic(sender:UIButton!) {
        var msg: String!
        if isPaused! {
            msg = "play"
            player.play()
        } else {
            msg = "pause"
            player.pause()
        }
        isPaused = !isPaused
        
        let msgData = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        session.sendData(msgData!)
    }
    
}
