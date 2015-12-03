//
//  NowPlayingViewController.swift
//  Boost
//
//  Created by Gautier Delorme on 09/01/2015.
//  Copyright (c) 2015 Gautier Delorme. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class NowPlayingViewController: UIViewController {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    /*var titleMusic : String!
    var artistMusic: String!
    var albumMusic: String!
    var artworkMusic: UIImage!
    var durationMusic: NSNumber!*/
    var player: AVPlayer!
    
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    let albumLabel = UILabel()
    
    let playPauseButton = UIButton()
    let progressSLider = UISlider()
    
    let artworkImageView = UIImageView()
    var topY: CGFloat!
    
    override func viewDidLoad() {
        var playerItem: PlayerItem = player.currentItem as PlayerItem
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("progressMusic"), userInfo: nil, repeats: true)
        
        self.navigationController?.navigationBarHidden = false
        self.view.backgroundColor = UIColor.clearColor()
        topY = self.navigationController?.navigationBar.frame.size.height
        titleLabel.frame = CGRectMake(10,topY+20, screenSize.width-20, 30)
        //titleLabel.text = playerItem.title
        titleLabel.textAlignment = NSTextAlignment.Center
        artistLabel.frame = CGRectMake(10, titleLabel.frame.origin.y+titleLabel.frame.size.height+20, screenSize.width-20, 30)
        artistLabel.text = playerItem.artist
        artistLabel.textAlignment = NSTextAlignment.Center
        artworkImageView.frame = CGRectMake(40, artistLabel.frame.origin.y+artistLabel.frame.size.height+20, screenSize.width-80, screenSize.width-80)
        artworkImageView.image = playerItem.artwork
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(artistLabel)
        self.view.addSubview(artworkImageView)
        
        progressSLider.frame = CGRectMake(0, artworkImageView.frame.origin.y+artworkImageView.frame.size.height+20, screenSize.width-20, 15)
        progressSLider.center = CGPointMake(self.view.center.x, progressSLider.center.y)
        println("1: \(CMTimeGetSeconds(player.currentTime()))")
        println("2: \(playerItem.durationItem)")
        progressSLider.minimumValue = 0
        progressSLider.value = Float(CMTimeGetSeconds(player.currentTime()))
        progressSLider.maximumValue = playerItem.durationItem
        progressSLider.sizeToFit()
        progressSLider.setThumbImage(UIImage(), forState: UIControlState.Normal)
        self.view.addSubview(progressSLider)
        /*var volumeView = MPVolumeView(frame: CGRectMake(0, artworkImageView.frame.origin.y+artworkImageView.frame.size.height+20, screenSize.width-20, 15))
        volumeView.center = CGPointMake(self.view.center.x, volumeView.center.y)
        volumeView.showsVolumeSlider = true
        volumeView.showsRouteButton = true
        volumeView.sizeToFit()
        self.view.addSubview(volumeView)*/
    }
    
    func progressMusic() {
        progressSLider.value = Float(CMTimeGetSeconds(player.currentTime()))
    }
    
    override func viewDidAppear(animated: Bool) {
        viewDidLoad()
    }
}
