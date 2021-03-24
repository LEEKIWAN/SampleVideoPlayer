//
//  VideoView.swift
//  SampleVideoPlayer
//
//  Created by 이기완 on 2021/03/16.
//

import UIKit
import AVKit


//class Subtitle {
//    let
//}

class VideoView: UIView {
    private var pictureInPictureController: AVPictureInPictureController!
    
    @IBOutlet weak var controlView: VideoControlView! {
        didSet {
            controlView.videoView = self
        }
    }
    
    var duration: Double {
        if let duration = self.avPlayer.currentItem?.duration {
            return CMTimeGetSeconds(duration)
        }
        return 0
    }
    
    var currentTime: Double {
        if let currnetTime = self.avPlayer.currentItem?.currentTime() {
            return CMTimeGetSeconds(currnetTime)
        }
        return 0
    }
    
    
    private var avAsset: AVAsset!
    private var avLayer: AVPlayerLayer!
    private var avPlayer: AVPlayer!
    
    //                         [title : metadatas]
    private var audioMetadataList: [AVMediaSelectionOption] = []
    private var subtitleMetadataList: [AVMediaSelectionOption] = []
    
    
    //MARK: - Func
    override init(frame: CGRect) {
        super.init(frame: frame)
        setNib()
        setEvent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setNib()
        setEvent()
    }
    
    private func setNib() {
        let view = Bundle.main.loadNibNamed("VideoView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

    private func setEvent() {
        
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        guard let avLayer = avLayer else { return }
        avLayer.frame = self.bounds
    }
    
    
    func setVideoAsset(url: URL) {
        avAsset = AVAsset(url: url)
        avPlayer = AVPlayer(playerItem: AVPlayerItem(asset: avAsset))
        avLayer = AVPlayerLayer(player: avPlayer)
        self.layer.insertSublayer(avLayer, at: 0)
        
        controlView.avAsset = avAsset
        
        createAudioMetadataList()
        createSubtitleMetadataList()
        addProgressObserver()
        addLoadingObserver()
    }
    
    private func createAudioMetadataList() {
        guard let audibleGroup: AVMediaSelectionGroup = avAsset.mediaSelectionGroup(forMediaCharacteristic: .audible) else { return }
        audioMetadataList = audibleGroup.options
    }
    
    private func createSubtitleMetadataList() {
        guard let legibleGroup: AVMediaSelectionGroup = avAsset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
        subtitleMetadataList = legibleGroup.options
    }
    
    private func addProgressObserver() {
        avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { [weak self] (time) in
            guard let self = self else { return }
            self.controlView.updateProgressSlider(value: Float(CMTimeGetSeconds(time) / self.duration))
            self.controlView.updateTimeLabel(currentTime: CMTimeGetSeconds(time), duration: self.duration)
        }
    }
    
    private func addLoadingObserver() {
        avPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    
    
    func play() {
        avPlayer.play()
    }
    
    func pause() {
        avPlayer.pause()
    }
    
    
    func seek(to time: Double) {
        let seekCMTime = CMTimeMakeWithSeconds(time, preferredTimescale: avAsset.duration.timescale);
        avPlayer.seek(to: seekCMTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    
    func setSubtitle(option: AVMediaSelectionOption) {
        if let group = avAsset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: option.locale!)
            if let option = options.first {
                avPlayer.currentItem?.select(option, in: group)
            }
        }
    }
    
    //MARK: - Observer
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.controlView.isHiddenLoadingView = true
                    } else if self?.controlView.isDisplayControl ?? false {
                        self?.controlView.isHiddenLoadingView = false
                    }
                }
            }
        }
    }
    
    
}


extension VideoView: AVPictureInPictureControllerDelegate {
    
    func setupPictureInPicture() {
        if (AVPictureInPictureController.isPictureInPictureSupported()) {
            guard let layer = self.layer.sublayers?.first as? AVPlayerLayer else { return }
            pictureInPictureController = AVPictureInPictureController(playerLayer: layer)
            pictureInPictureController.delegate = self
            pictureInPictureController.startPictureInPicture()
        }
        else {
            if let pictureInPictureController = pictureInPictureController {
                pictureInPictureController.stopPictureInPicture()
            }
        }
    }
    
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        //Update video controls of main player to reflect the current state of the video playback.
        //You may want to update the video scrubber position.
        print("restoreUserInterfaceForPictureInPictureStopWithCompletionHandler")
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Handle PIP will start event")
        //Handle PIP will start event
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Handle PIP did start event")
        //Handle PIP did start event
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("pictureInPictureController")
        //Handle PIP failed to start event
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //        print("pictureInPictureControllerWillStopPictureInPicture")
        //Handle PIP will stop event
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStopPictureInPicture")
        
        //Handle PIP did start event
    }
}



