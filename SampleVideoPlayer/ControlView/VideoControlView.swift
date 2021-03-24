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
    var avAsset: AVAsset! {
        didSet {
            thumbnailManager = ThumbnailManager(avAsset: avAsset)
        }
    }
    
    var isHiddenLoadingView: Bool = true {
        didSet {
            indicatorView.isHidden = isHiddenLoadingView
            if isDisplayControl {
                playPauseButton.alpha = isHiddenLoadingView ? 1 : 0
            }
        }
    }
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var sliderView: PlayerSliderView! {
        didSet {
            sliderView.delegate = self
        }
    }
        
    @IBOutlet weak var brightnessVerticalProgessView: VerticalProgressView! {
        didSet {
            brightnessVerticalProgessView.mode = .brightness
            brightnessVerticalProgessView.delegate = self
        }
    }
    
    @IBOutlet weak var sliderThumbnailView: SliderThumbnailView!
    
    @IBOutlet weak var thumbnailCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    
    @IBOutlet weak var backwardSeekButton: SeekerButton! {
        didSet {
            backwardSeekButton.directionMode = .backward
            backwardSeekButton.delegate = self
        }
    }
    
    @IBOutlet weak var playPauseButton: PlayPauseButton!
    
    @IBOutlet weak var forwardSeekButton: SeekerButton! {
        didSet {
            forwardSeekButton.directionMode = .forward
            forwardSeekButton.delegate = self
        }
    }
    
    @IBOutlet weak var playControlStackView: UIStackView!
    
    
    
    private var thumbnailManager: ThumbnailManager!
    
    
    var controlViewTimer: Timer = Timer()
    var isDisplayControl: Bool = true
    
    
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
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onVideoViewTouched(_:)))
        self.addGestureRecognizer(singleTapGesture)
    }
    
    
    //MARK: - Event12
    @objc func onVideoViewTouched(_ sender: UITapGestureRecognizer?) {
        isDisplayControl = !isDisplayControl
        displayControlView(isShown: isDisplayControl)
    }
    
    func updateProgressSlider(value: Float) {
        sliderView.setProgress(value, animated: false)
        thumbnailCenterConstraint.constant = sliderView.thumbCenterX
    }
    
    func updateTimeLabel(currentTime: Float64, duration: Float64) {
        if duration.isNaN { return }
        
        
        let currentTimeDisplay = VideoUtil.durationToString(duration: currentTime)
        let durationDisplay = VideoUtil.durationToString(duration: duration)
        
        
        currentTimeLabel.text = currentTimeDisplay
        durationLabel.text = durationDisplay
    }
    

    func resetControlHideTimer(forceReset: Bool = false, second: TimeInterval = 3) {
        controlViewTimer.invalidate()
        controlViewTimer = Timer.scheduledTimer(timeInterval: second, target: self, selector: #selector(hideControlView), userInfo: nil, repeats: false)
    }
    
    @objc private func hideControlView() {
        self.displayControlView(isShown: false)
    }
    
    func displayControlView(isShown: Bool) {
        isDisplayControl = isShown
        isShown ? showControlAnimation() : hiddenControlAnimation()
    }
    
    
    internal func showControlAnimation() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.controlView.alpha = 1
            self.brightnessVerticalProgessView.isShown = true
            self.playControlStackView.alpha = 1
            self.playPauseButton.alpha = isHiddenLoadingView ? 1 : 0
            
            self.layoutIfNeeded()
        }) { (completion) in
        }
    }
    
    private func hiddenControlAnimation(progressHidden: Bool = true) {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.controlView.alpha = 0
            self.brightnessVerticalProgessView.isShown = false
            self.playControlStackView.alpha = 0
            self.layoutIfNeeded()
        }) { (completion) in
        }
    }
    
    
}


extension VideoControlView: PlayerSliderViewDelegate {
    func sliderTouchBegan(slider: PlayerSliderView, thumbXPoint: CGFloat) {
        thumbnailCenterConstraint.constant = thumbXPoint
        sliderThumbnailView.isShown = true
        
        videoView.pause()
        
    }
    
    func sliderValueChanged(slider: PlayerSliderView, thumbXPoint: CGFloat) {
        thumbnailCenterConstraint.constant = thumbXPoint
        let seekTime = videoView.duration * Double(slider.value)
        let seekTimeDisplay = VideoUtil.durationToString(duration: seekTime)
        
        thumbnailManager.getThumnailImage(second: seekTime) { [weak self] (image) in
            self?.sliderThumbnailView.setThumbnail(image: #imageLiteral(resourceName: "folderRecentDownload"), time: seekTimeDisplay)
        }
        
    }
    
    func sliderTouchEnd(slider: PlayerSliderView) {
        sliderThumbnailView.isShown = false
        let seekTime = videoView.duration * Double(slider.value)
        videoView.seek(to: seekTime)
        
        videoView.play()
    }
}

extension VideoControlView: SeekerButtonDelegate {
    func onBackwardTouched(view: SeekerButton) {
        videoView.seek(to: videoView.currentTime - 10)
    }
    
    func onForwadTouched(view: SeekerButton) {
        videoView.seek(to: videoView.currentTime + 10)
    }
}

extension VideoControlView: VerticalProgressViewDelegate {
    func verticalSliderTouchBegan(slider: VerticalProgressView) {
        controlViewTimer.invalidate()
    }
    
    func verticalSliderValueChanged(slider: VerticalProgressView) {
        
    }
    
    func verticalSliderTouchEnd(slider: VerticalProgressView) {
        
    }
    
    
}
