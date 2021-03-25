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
            controlView.delegate = self
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
    
    private var audioMetadataList: [AVMediaSelectionOption] = []
    private var subtitleMetadataList: [AVMediaSelectionOption] = []
    
    private var selectedAudioMetadata: AVMediaSelectionOption?
    private var selectedSubtitleMetadata: AVMediaSelectionOption?
    
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
        addPlayerObserver()
    }
    
    private func createAudioMetadataList() {
        guard let audibleGroup: AVMediaSelectionGroup = avAsset.mediaSelectionGroup(forMediaCharacteristic: .audible) else { return }
        audioMetadataList.append(contentsOf: audibleGroup.options) 
        setDefaultAudio()
    }
    
    private func createSubtitleMetadataList() {
        guard let legibleGroup: AVMediaSelectionGroup = avAsset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
        subtitleMetadataList.append(AVMediaSelectionOption())
        subtitleMetadataList.append(contentsOf: legibleGroup.options)
        setDefaultSubtitle()
    }
    
    func setDefaultAudio() {
        if let playerItem = avPlayer?.currentItem, let group = avAsset.mediaSelectionGroup(forMediaCharacteristic: .audible) {
            let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group)
            if let selectedLocale = selectedOption?.locale {
                let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: selectedLocale)
                if let option = options.first {
                    selectedAudioMetadata = option
                    avPlayer.currentItem?.select(option, in: group)
                }
            }
        }
    }
    
    func setDefaultSubtitle() {
        if let playerItem = avPlayer?.currentItem, let group = avAsset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group)
            if let selectedLocale = selectedOption?.locale {
                let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: selectedLocale)
                if let option = options.first {
                    selectedSubtitleMetadata = option
                    avPlayer.currentItem?.select(option, in: group)
                }
            }
        }
    }
    
    private func addProgressObserver() {
        avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { [weak self] (time) in
            guard let self = self else { return }
            self.controlView.updateProgressSlider(value: Float(CMTimeGetSeconds(time) / self.duration))
            self.controlView.updateTimeLabel(currentTime: CMTimeGetSeconds(time), duration: self.duration)
        }
    }
    
    private func addPlayerObserver() {
        avPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.old, .new], context: nil)
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
            if let locale = option.locale {
                let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                if let option = options.first {
                    avPlayer.currentItem?.select(option, in: group)
                }
            }
            else {
                avPlayer.currentItem?.select(nil, in: group)
            }
        }
    }
    
    func setAudio(option: AVMediaSelectionOption) {
        if let group = avAsset.mediaSelectionGroup(forMediaCharacteristic: .audible) {
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: option.locale!)
            if let option = options.first {
                avPlayer.currentItem?.select(option, in: group)
            }
        }
    }
    
    //MARK: - Observer
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.timeControlStatus), let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                switch newStatus {
                case .playing:
                    controlView.isHiddenLoadingView = true
                    controlView.playPauseButton.setPlaying(true)
                case .paused: 
                    controlView.isHiddenLoadingView = true
                    controlView.playPauseButton.setPlaying(false)
                case .waitingToPlayAtSpecifiedRate:
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                        guard let self = self else { return }
                        if self.avPlayer.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                            self.controlView.isHiddenLoadingView = false
                        }
                    }
                    
                default:
                    break
                }
                
            }
        }
        
    }
}

extension VideoView: VideoControlViewDelegate {
    func onPlayPauseTouched(view: VideoControlView, button: PlayPauseButton) {
        button.playing ? pause() : play()
    }
    
    //
    func sliderTouchBegan(view: VideoControlView, slider: PlayerSliderView) {
        pause()
    }
    
    func sliderValueChanged(view: VideoControlView, slider: PlayerSliderView) {
        let seekTime = duration * Double(slider.value)
        let seekTimeDisplay = VideoUtil.durationToString(duration: seekTime)
        
        controlView.setSliderThumbnailView(image: #imageLiteral(resourceName: "folderRecentDownload"), time: seekTimeDisplay)
    }
    
    func sliderTouchEnd(view: VideoControlView, slider: PlayerSliderView) {
        let seekTime = duration * Double(slider.value)
        seek(to: seekTime)        
        play()
    }
    
    //
    func onBackwardTouched(view: VideoControlView) {
        seek(to: currentTime - 10)
        play()
    }
    
    func onForwardTouched(view: VideoControlView) {
        seek(to: currentTime + 10)
        play()
    }
    
    func onAudioSubtitleSelectTouched(view: VideoControlView) {
        if let parentViewController = self.parentViewController {
            
            let storyBoard = UIStoryboard(name: "AudioSubtitleSelectViewController", bundle: nil)
            let viewController = storyBoard.instantiateInitialViewController() as! AudioSubtitleSelectViewController
            viewController.audioMetadataList = audioMetadataList
            viewController.subtitleMetadataList = subtitleMetadataList
            viewController.selectedAudioMetadata = selectedAudioMetadata
            viewController.selectedSubtitleMetadata = selectedSubtitleMetadata
            viewController.delegate = self
            parentViewController.present(viewController, animated: true) { [weak self] in
                self?.pause()
            }
        }
    }
}

extension VideoView: AudioSubtitleSelectViewDelegate {
    func onSubtitleChanged(viewController: AudioSubtitleSelectViewController, selectedSubtitleMetadata: AVMediaSelectionOption) {
        self.selectedSubtitleMetadata = selectedSubtitleMetadata
        setSubtitle(option: selectedSubtitleMetadata)
    }
    
    func onAudioChanged(viewController: AudioSubtitleSelectViewController, selectedAudioMetadata: AVMediaSelectionOption) {
        self.selectedAudioMetadata = selectedAudioMetadata
        setAudio(option: selectedAudioMetadata)
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
        print("pictureInPictureControllerWillStopPictureInPicture")
        //Handle PIP will stop event
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStopPictureInPicture")
        
        //Handle PIP did start event
    }
}



