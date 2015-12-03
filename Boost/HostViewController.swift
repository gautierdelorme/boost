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

class HostViewController: UITableViewController, SessionDelegate {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let pauseButton = UIButton()
    var stream: NSOutputStream!
    var session = Session()
    var isPaused: Bool!
    var player: AVPlayer!
    var playerItem : PlayerItem!
    var nowPlayingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.view.backgroundColor = UIColor.blueColor()
        pauseButton.frame = CGRectMake(screenSize.width/2, 50, 70, 10)
        pauseButton.setTitle("Pause", forState: UIControlState.Normal)
        pauseButton.addTarget(self, action: "pauseMusic:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(pauseButton)
        nowPlayingButton = UIBarButtonItem(title: "Now Playing", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("goToNowPlaying:"))
        isPaused = false
        session.delegate = self
        session.startAdvertiser()
    }
    
    override func viewDidAppear(animated: Bool) {
        if player != nil && player.rate > 0 && player.error == nil {
            self.navigationItem.rightBarButtonItem = nowPlayingButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - TableView code
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MPMediaQuery.songsQuery().items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        var rowItem = MPMediaQuery.songsQuery().items[indexPath.row] as MPMediaItem
        
        cell.textLabel?.text = rowItem.valueForProperty(MPMediaItemPropertyTitle) as? String
        cell.detailTextLabel?.text = rowItem.valueForProperty(MPMediaItemPropertyArtist) as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var rowItem = MPMediaQuery.songsQuery().items[indexPath.row] as MPMediaItem
        
        let info = NSMutableDictionary()
        info.setValue(rowItem.title != nil ? rowItem.title as String! : "", forKey: "title")
        info.setValue(rowItem.artist != nil ? rowItem.artist as String! : "", forKey: "artist")
        info.setValue(rowItem.albumTitle != nil ? rowItem.albumTitle as String! : "", forKey: "album")
        
        var durNS: NSNumber? = rowItem.valueForProperty(MPMediaItemPropertyPlaybackDuration) as? NSNumber
        var durationFloat: Float? = durNS?.floatValue
        info.setValue(durationFloat != nil ? durationFloat : 0, forKey: "duration")
        
        println(info["title"])
        println(info["duration"])
        
        var artwork: MPMediaItemArtwork? = rowItem.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        var artworkImage: UIImage? = artwork?.imageWithSize(CGSizeMake(120, 120))
        info.setValue(artworkImage != nil ? artworkImage : nil, forKey: "artwork")
        
        session.sendData(NSKeyedArchiver.archivedDataWithRootObject(info.copy()))
        
        let musicUrl: NSURL? = rowItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
        
        let avAsset: AVAsset = AVAsset.assetWithURL(musicUrl) as AVAsset
        playerItem = PlayerItem(asset: avAsset)
        playerItem.config(info["title"] as String, artist: info["artist"] as String, album: info["album"] as String, artwork: info["artwork"] as UIImage, duration: info["duration"] as Float)
        
        startStreaming(musicUrl)
    }
    
    // MARK: - SessionDelegate
    
    func didConnectToPeer(peerID: MCPeerID) {
        println("peers : \(session.connectedPeers().count)")
    }
    
    func didReceiveData(data: NSData) {
        println("caca")
        dispatch_async(dispatch_get_main_queue()) {
            var msg : NSString! = NSString(data: data, encoding: NSUTF8StringEncoding)
            while CFAbsoluteTimeGetCurrent() < (msg.doubleValue+1) {
                println("yolo")
            }
            if self.player != nil && self.player.rate > 0 && self.player.error == nil {
                self.player.replaceCurrentItemWithPlayerItem(self.playerItem)
            } else {
                self.player = AVPlayer(playerItem: self.playerItem)
            }
            println("before play : \(CFAbsoluteTimeGetCurrent())")
                self.player.play()
                let npVC = NowPlayingViewController()
                npVC.player = self.player
                self.navigationController!.pushViewController(npVC, animated: true)
        }
    }
    // MARK: - Others
    
    func startStreaming(musicUrl: NSURL!) {
        if musicUrl != nil {
            if  session.connectedPeers().count > 0 {
                for i in session.connectedPeers() {
                    var outputStreamer = TDAudioOutputStreamer(outputStream: session.openStreamToPeer(i as MCPeerID))
                    outputStreamer.streamAudioFromURL(musicUrl)
                    outputStreamer.start()
                }
                /*println("before play : \(CFAbsoluteTimeGetCurrent())")
                let msg = CFAbsoluteTimeGetCurrent()+2.5;
                while CFAbsoluteTimeGetCurrent() < msg {
                    println("yolo")
                }
                if player != nil && player.rate > 0 && player.error == nil {
                    player.replaceCurrentItemWithPlayerItem(playerItem)
                } else {
                    player = AVPlayer(playerItem: playerItem)
                }
                player.play()
                println("after play : \(CFAbsoluteTimeGetCurrent())")
                let npVC = NowPlayingViewController()
                npVC.player = player
                self.navigationController!.pushViewController(npVC, animated: true)*/
            }
        } else {
            println("Can't play this song")
        }
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
    
    func goToNowPlaying(sender:UIBarButtonItem!) {
        let npVC = NowPlayingViewController()
        npVC.player = player
        self.navigationController!.pushViewController(npVC, animated: true)
    }
    
}
