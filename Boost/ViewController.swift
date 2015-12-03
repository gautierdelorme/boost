//
//  ViewController.swift
//  Boost
//
//  Created by Gautier Delorme on 29/12/2014.
//  Copyright (c) 2014 Gautier Delorme. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let browseButton = UIButton()
    let sendButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor.blueColor()
        
        sendButton.frame = CGRectMake(5, 130, 70, 10)
        sendButton.setTitle("Host", forState: UIControlState.Normal)
        sendButton.addTarget(self, action: "goToHost:", forControlEvents: UIControlEvents.TouchUpInside)
        
        browseButton.frame = CGRectMake(5, sendButton.frame.origin.y+sendButton.frame.height+50, 70, 10)
        browseButton.setTitle("Guest", forState: UIControlState.Normal)
        browseButton.addTarget(self, action: "goToGuest:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(sendButton)
        self.view.addSubview(browseButton)
    }
    
    func goToHost(sender:UIButton!) {
        self.navigationController!.pushViewController(HostViewController(), animated: true)
    }
    
    func goToGuest(sender:UIButton!) {
        self.navigationController!.pushViewController(GuestViewController(), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

