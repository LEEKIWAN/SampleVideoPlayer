//
//  ViewController.swift
//  SampleVideoPlayer
//
//  Created by 이기완 on 2021/03/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var videoView: VideoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoView.setVideoAsset(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
        
        videoView.play()
    }


}

