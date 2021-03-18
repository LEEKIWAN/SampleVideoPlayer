//
//  VerticalProgressView.swift
//  Kollus Player
//
//  Created by kiwan on 2020/07/28.
//  Copyright © 2020 kiwan. All rights reserved.
//

import UIKit
import MediaPlayer

protocol VerticalProgressViewDelegate : class {
    func verticalSliderTouchBegan(slider: VerticalProgressView)
    func verticalSliderValueChanged(slider: VerticalProgressView)
    func verticalSliderTouchEnd(slider: VerticalProgressView)
}


class VerticalProgressView: UIView {
    enum Mode {
        case sound
        case brightness
    }
    
    let volumeModifierValue = 0.0625
    
    weak var delegate: VerticalProgressViewDelegate?
    
    var isShown: Bool = false {
        didSet {
            self.setShown(isShown)
        }
    }
    
    var mode: Mode = .brightness {
        didSet {
            updateModeUI()
        }
    }
    
    var volumeView: MPVolumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 100, height: 100))
    var volumeSlider : UISlider?
    
    
    var previousProgressValue: Float = 0
    
    let panGestureView = UIView()
    let statusImageView = UIImageView()
    
    
    private var imageCenterXConstraint: Constraint? = nil
    private var progressCenterXConstraint: Constraint? = nil
    
    var currentAnimation = ""
    
    let backgroundButton = UIButton()
    
    let progressView: UIProgressView = {
        let prgressView = UIProgressView()
        prgressView.progressTintColor = .white
        prgressView.layer.cornerRadius = 2
        prgressView.clipsToBounds = true
        prgressView.transform = CGAffineTransform(rotationAngle: .pi / -2)
        prgressView.translatesAutoresizingMaskIntoConstraints = false
        return prgressView
    }()
    
    let shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = .black
        // corner radius
        shadowView.layer.cornerRadius = 2
        shadowView.transform = CGAffineTransform(rotationAngle: .pi / -2)
        // border
        shadowView.layer.borderWidth = 1.0
        shadowView.layer.borderColor = UIColor.black.cgColor

        // shadow
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 3
        return shadowView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setNib()
        setUI()
        setEvent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setNib()
        setUI()
        setEvent()
    }
    
    var savedVolume: Float = -1
    
    private func setNib() {
        addSubview(shadowView)
        addSubview(backgroundButton)
        addSubview(volumeView)
        addSubview(progressView)
        addSubview(statusImageView)
        addSubview(panGestureView)
        
        backgroundButton.snp.makeConstraints { (maker) in
            maker.top.leading.bottom.trailing.equalToSuperview()
        }
        
        panGestureView.snp.makeConstraints { (maker) in
            maker.size.equalToSuperview()
            maker.top.leading.trailing.bottom.equalToSuperview()
        }
        
        statusImageView.snp.makeConstraints { [unowned self] (maker) in
            maker.top.equalToSuperview()
            self.imageCenterXConstraint = maker.centerX.equalToSuperview().constraint
            maker.width.height.equalTo(40)
        }
        
        progressView.snp.remakeConstraints { [unowned self] (maker) in
            self.progressCenterXConstraint = maker.centerX.equalToSuperview().constraint
            maker.centerY.equalToSuperview().offset(20)
            maker.height.equalTo(4)
            maker.width.equalTo(self.snp.height).offset(-40)
        }
        
        
        shadowView.snp.makeConstraints { [unowned self] (maker) in
            maker.top.leading.bottom.trailing.equalTo(self.progressView)
        }
    }
    
    private func setUI() {
        volumeSlider = volumeView.subviews.first as? UISlider
        panGestureView.backgroundColor = .clear
        mode = .brightness
        
        
        statusImageView.layer.shadowColor = UIColor.black.cgColor
        statusImageView.layer.shadowOffset = .zero
        statusImageView.layer.shadowOpacity = 0.5
        statusImageView.layer.shadowRadius = 3
        
        
    }
    
    private func setEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onSliderTouched))
        panGestureView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(sliderValueChanged))
        panGestureView.addGestureRecognizer(panGesture)
    }
    
    
    // MARK: - UI
    private func updateModeUI() {
        self.mode == .brightness ? updateBrightnessUI() : initSoundUI()
    }
    
    
    func updateBrightnessUI(value: Float = 0) {
        UIScreen.main.brightness -= CGFloat(value)
        progressView.setProgress(Float(UIScreen.main.brightness), animated: false)
        statusImageView.image = UIScreen.main.brightness >= 0.5 ? #imageLiteral(resourceName: "btnBrightness") : #imageLiteral(resourceName: "btnBrightness")
    }
    
    func initSoundUI() {
        let audioSession = AVAudioSession.sharedInstance()
        var systemVolume: Float = 0
        
        do {
            try audioSession.setActive(true)
            systemVolume = audioSession.outputVolume
        } catch {
            print("Error Setting Up Audio Session")
        }
        
        progressView.setProgress(systemVolume, animated: false)
        statusImageView.image = nil
        
        
        statusImageView.image = systemVolume == 0 ? #imageLiteral(resourceName: "btnVolumOff") : #imageLiteral(resourceName: "btnVolumUp")
        
    }
    
    func updateSoundUI(value: Float = 0) {
        guard let volumeSlider = volumeSlider else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        var systemVolume: Float = 0
        
        do {
            try audioSession.setActive(true)
            systemVolume = audioSession.outputVolume
        } catch {
            print("Error Setting Up Audio Session")
        }
        
        volumeSlider.value -= value
        progressView.setProgress(systemVolume, animated: false)
        statusImageView.image = nil
        
        
        statusImageView.image = systemVolume == 0 ? #imageLiteral(resourceName: "btnVolumOff") : #imageLiteral(resourceName: "btnVolumUp")
    }    
    
    private func setShown(_ shown: Bool) {
        shown ? show() : hide()
    }
    
    private func show() {
//        guard let superView = self.superview?.superview as? VideoControlView, superView.isLocked == false else { return }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
            self.imageCenterXConstraint?.update(offset: 0)
            self.progressCenterXConstraint?.update(offset: 0)
            self.statusImageView.alpha = 1
            self.progressView.alpha = 1
            self.shadowView.alpha = 1
            self.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func hide() {
        if mode == .brightness {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
                self.imageCenterXConstraint?.update(offset: -10)
                self.progressCenterXConstraint?.update(offset: -10)
                self.statusImageView.alpha = 0
                self.progressView.alpha = 0
                self.shadowView.alpha = 0
                self.layoutIfNeeded()
                }, completion: nil)
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
                self.imageCenterXConstraint?.update(offset: 10)
                self.progressCenterXConstraint?.update(offset: 10)
                self.statusImageView.alpha = 0
                self.progressView.alpha = 0
                self.shadowView.alpha = 0
                self.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    //MARK: - Event
    @objc func onMuteToggleTouhced(sender: UIButton) {
        guard let volumeSlider = volumeSlider else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        var systemVolume: Float = 0
        
        do {
            try audioSession.setActive(true)
            systemVolume = audioSession.outputVolume
        } catch {
            print("Error Setting Up Audio Session")
        }
        
        if systemVolume > 0 {
            savedVolume = systemVolume
            volumeSlider.value = 0
            progressView.setProgress(0, animated: false)
        }
        else if systemVolume == 0 {
            print(systemVolume, " , savedVolume : ", savedVolume)
            volumeSlider.value = savedVolume
            progressView.setProgress(volumeSlider.value, animated: false)
        }
        
    }
    
    @objc func onSliderTouched(_ recognizer: UITapGestureRecognizer) {
        if progressView.alpha == 1 {            
            let position = recognizer.location(in: progressView)
            let value = position.x / progressView.frame.size.height
            
            progressView.setProgress(Float(value), animated: false)
            
            switch mode {
            case .brightness:
                UIScreen.main.brightness = CGFloat(value)
                
            case .sound:
                guard let volumeSlider = volumeSlider else { return }
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(true)
                } catch {
                    print("Error Setting Up Audio Session")
                }
                
                volumeSlider.value = Float(value)
            }

        }
        
        delegate?.verticalSliderValueChanged(slider: self)
        delegate?.verticalSliderTouchEnd(slider: self)
    }
    
    
    @objc func sliderValueChanged(_ recognizer: UIPanGestureRecognizer) {
//        guard let superView = self.superview?.superview as? VideoControlView, superView.isLocked == false else { return }
        
        let velocity = recognizer.velocity(in: recognizer.view)
        switch recognizer.state {
        case .began:
            delegate?.verticalSliderTouchBegan(slider: self)
        case .changed:
            delegate?.verticalSliderValueChanged(slider: self)
            if mode == .brightness {
                updateBrightnessUI(value: Float(velocity.y / 10000))
            }
            else {
                updateSoundUI(value: Float(velocity.y / 10000))
            }
            
            if (progressView.progress == 0 || progressView.progress == 1) && (previousProgressValue != progressView.progress) {
                if #available(iOS 10.0, *) {
                    UIDevice.vibrate()
                }
            }
            previousProgressValue = progressView.progress
            
        case .ended:
            delegate?.verticalSliderTouchEnd(slider: self)
        default:
            break
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else { return }
        switch key {
        case "outputVolume":
            if mode == .sound {
                guard let dict = change, let soundValue = dict[NSKeyValueChangeKey.newKey] as? Float else { return }
                progressView.setProgress(soundValue, animated: true)
                
                statusImageView.image = soundValue == 0 ? #imageLiteral(resourceName: "btnVolumOff") : #imageLiteral(resourceName: "btnVolumUp")
                
                delegate?.verticalSliderValueChanged(slider: self)
                delegate?.verticalSliderTouchEnd(slider: self)
                
            }
        default:
            break
        }
    }
    
    deinit {
//        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
//        do { try AVAudioSession.sharedInstance().setActive(false) }
//        catch { debugPrint("\(error)") }
//        print("sound deinit")
    }
}

