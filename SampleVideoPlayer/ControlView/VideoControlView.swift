//
//  VideoControlView.swift
//  Kollus Player
//
//  Created by kiwan on 2020/07/28.
//  Copyright © 2020 kiwan. All rights reserved.
//

import UIKit
import AVKit


class VideoControlView: UIView {
    var videoView: VideoView!
    var avAsset: AVAsset!
    
    @IBOutlet weak var sliderView: PlayerSliderView!
    
    @IBOutlet weak var sliderThumbnailView: SliderThumbnailView!
    
    @IBOutlet weak var thumbnailCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    //MARK: - Func
    override init(frame: CGRect) {
        super.init(frame: frame)
        setNib()
//        setUI()
        setEvent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setNib()
//        setUI()
        setEvent()
    }
    
    private func setNib() {
        let view = Bundle.main.loadNibNamed("VideoControlView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        
        self.addSubview(view)
    }    
    
    private func setEvent() {
        sliderView.delegate = self
    }
    
//    func createThumbnailImage() {
//        var imageGenerator = AVAssetImageGenerator(asset: avAsset)
//        var time = CMTimeMake(value: 1, timescale: 1)
//        var imageRef = try! imageGenerator.copyCGImage(at: time, actualTime: nil)
//        var thumbnail = UIImage(cgImage:imageRef)
//        
//        
//        print()
//    }
    
    func updateProgressSlider(value: Float) {
        sliderView.setProgress(value, animated: true)
    }
}


extension VideoControlView: PlayerSliderViewDelegate {
    func sliderTouchBegan(slider: PlayerSliderView, thumbXPoint: CGFloat) {
        thumbnailCenterConstraint.constant = thumbXPoint
        sliderThumbnailView.isShown = true
        
    }
    
    func sliderValueChanged(slider: PlayerSliderView, thumbXPoint: CGFloat) {
        thumbnailCenterConstraint.constant = thumbXPoint
        
    }
    
    func sliderTouchEnd(slider: PlayerSliderView) {
        sliderThumbnailView.isShown = false
    }
    
    
}
