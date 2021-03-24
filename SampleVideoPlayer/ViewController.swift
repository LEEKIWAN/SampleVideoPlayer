//
//  ViewController.swift
//  SampleVideoPlayer
//
//  Created by 이기완 on 2021/03/16.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var videoView: VideoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoView.setVideoAsset(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
//        videoView.setVideoAsset(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        
        videoView.play()
        
        
//              videoAsset = AVAsset(url: URL(string: "http://sample.vodobox.com/planete_interdite/planete_interdite_alternate.m3u8")!)
//              videoAsset = AVAsset(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
        
        
        
        
//        let imageview = UIImageView(image: image)
        
        
    }}

