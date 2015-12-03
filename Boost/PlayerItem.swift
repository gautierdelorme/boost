//
//  PlayerItem.swift
//  Boost
//
//  Created by Gautier Delorme on 10/01/2015.
//  Copyright (c) 2015 Gautier Delorme. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerItem: AVPlayerItem {
    var title : String!
    var artist: String!
    var album: String!
    var artwork: UIImage!
    var durationItem: Float!
    
    func config(title: String, artist: String, album: String, artwork: UIImage, duration: Float) {
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.durationItem = duration
    }
}
