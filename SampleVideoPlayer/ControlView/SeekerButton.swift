//
//  DoubleTapSeekerButton.swift
//  CustomSliderView
//
//  Created by kiwan on 2020/06/04.
//  Copyright © 2020 kiwan. All rights reserved.
//

import UIKit


protocol SeekerButtonDelegate : class {
    func onForwadTouched(view: SeekerButton, isContinues: Bool, intervaltime: Double)
    func onBackwardTouched(view: SeekerButton, isContinues: Bool, intervaltime: Double)
}

class SeekerButton: UIView {
    enum Direction {
        case forward
        case backward
    }
    
    weak var delegate: SeekerButtonDelegate?
    
    
    
    var animationRange: Int {
//        let width = self.parentViewController?.view.frame.size.width ?? 0
        let width = 100
        
        if width <= 480 {
            return 0
        }
        else {
            return Int(width / 13)
        }
    }
    
    var interval = 10
    
    private var currentInterval = 0
    let seekButton = UIButton()
    let coverButton = UIButton()
    
    private let fadeAnimationView = UIView()
    private let secondAnimationLabel = UILabel()
    private let secondIntervalLabel = UILabel()
    
    private var labelConstraint: Constraint? = nil
    
    
    @available(iOS 10.0, *)
    private lazy var animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    
    
    var doubleTapHideTimer = Timer()
    
    var directionMode: Direction = .forward {
        didSet {
            updateDirectionUI()
        }
    }
    
    var isAnimating: Bool {
        if #available(iOS 10.0, *) {
            return doubleTapHideTimer.isValid
        }
        else {
            return false
        }
    }
    
    
    var widthValue: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 55
        }
        else {
            return 45
        }
    }
    
    var fontSize: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 16
        }
        else {
            return 13
        }
    }
    
    var isContinues: Bool {
        if currentInterval > interval {
            return true
        }
        
        return false
    }
    
    //MARK: - Func
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fadeAnimationView.layer.cornerRadius = fadeAnimationView.frame.size.height / 2
    }
    
    private func setNib() {
        addSubview(seekButton)
        addSubview(fadeAnimationView)
        addSubview(secondAnimationLabel)
        addSubview(secondIntervalLabel)
        addSubview(coverButton)
        
        seekButton.snp.makeConstraints { (maker) in
            maker.centerY.centerX.equalToSuperview()
            maker.size.equalTo(widthValue)
        }
        
        
        fadeAnimationView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(seekButton).inset(UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9))
        }
        
        secondAnimationLabel.snp.makeConstraints { [unowned self] (maker) in
            maker.centerY.equalTo(seekButton)
            self.labelConstraint = maker.centerX.equalTo(seekButton).constraint
        }
        
        secondIntervalLabel.snp.makeConstraints { (maker) in
            maker.centerY.centerX.equalTo(seekButton)
        }
        
        coverButton.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
    }
    
    private func setUI() {
        seekButton.adjustsImageWhenHighlighted = false
        seekButton.tintColor = .white
        
        
        fadeAnimationView.layer.masksToBounds = true
        fadeAnimationView.backgroundColor = .white
        fadeAnimationView.alpha = 0
        
        secondAnimationLabel.text = "\(interval)"
        secondAnimationLabel.textColor = .white
        secondAnimationLabel.font = UIFont.boldSystemFont(ofSize: fontSize + 3)
        secondAnimationLabel.alpha = 0
        secondAnimationLabel.textColor = .white
        
        
        secondIntervalLabel.text = "\(interval)"
        secondIntervalLabel.textColor = .white
        secondIntervalLabel.font = secondIntervalLabel.font.withSize(fontSize)
        
        currentInterval = interval
    }
    
    private func setEvent() {
        seekButton.addTarget(self, action: #selector(onButtonTouched(_:)), for: .touchUpInside)
        coverButton.addTarget(self, action: #selector(onButtonTouched(_:)), for: .touchUpInside)
    }
    
    // MARK: - UI
    private func updateDirectionUI() {
        secondAnimationLabel.snp.removeConstraints()
        
        if directionMode == .forward {
            seekButton.setBackgroundImage(#imageLiteral(resourceName: "forwardSec32"), for: .normal)
            secondAnimationLabel.snp.makeConstraints { [unowned self] (maker) in
                maker.centerY.equalTo(seekButton)
                self.labelConstraint = maker.leading.equalTo(seekButton.snp.trailing).constraint
            }
        }
        else {
            seekButton.setBackgroundImage(#imageLiteral(resourceName: "replaySec32"), for: .normal)
            secondAnimationLabel.snp.makeConstraints { [unowned self] (maker) in
                maker.centerY.equalTo(seekButton)
                self.labelConstraint = maker.trailing.equalTo(seekButton.snp.leading).constraint
            }
        }
    }
    
    private func updateCurrentIntervalText() {
        let mark = directionMode == .backward ? "-" : "+"
//        secondAnimationLabel.text = "\(mark)\(currentInterval)"
        secondAnimationLabel.text = "\(mark)\(interval)"
        secondAnimationLabel.sizeToFit()
        
        
        if animationRange == 0 {
            secondIntervalLabel.text = "\(currentInterval)"
        }
        
        currentInterval += interval
    }
    
    
    private func createAnimator() {
        if #available(iOS 10.0, *) {
            animator = UIViewPropertyAnimator(duration: 1.2, curve: .linear) {
                UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: [], animations: {
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0) { [unowned self] in
                        self.secondIntervalLabel.alpha = 1.0
                        self.secondAnimationLabel.alpha = 0.0
                        self.fadeAnimationView.alpha = 0.8
                        self.labelConstraint?.update(offset: 0)
                        self.seekButton.transform = CGAffineTransform(rotationAngle: 0)
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.05) { [unowned self] in
                        var t = CGAffineTransform.identity
                        if self.directionMode == .forward {
                            t = t.rotated(by: CGFloat.pi / 4)
                        }
                        else {
                            t = t.rotated(by: CGFloat.pi / -4)
                        }
                        
                        t = t.scaledBy(x: 0.8, y: 0.8)
                        self.seekButton.transform = t
                        self.layoutIfNeeded()
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.05, relativeDuration: 0.05) { [unowned self] in         // 0.1
                        if animationRange > 0 {
                            self.secondIntervalLabel.alpha = 0
                            self.layoutIfNeeded()
                        }
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.05, relativeDuration: 0.15) { [unowned self] in     // 0.2
                        var t = CGAffineTransform.identity
                        t = t.rotated(by: 0)
                        t = t.scaledBy(x: 1, y: 1)
                        self.seekButton.transform = t
                        self.fadeAnimationView.alpha = 0
                        self.layoutIfNeeded()
                    }
                    
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.2) { [unowned self] in
                        if animationRange > 0 {
                            _ = self.directionMode == .forward ? self.labelConstraint!.update(offset: self.animationRange) : self.labelConstraint!.update(offset: -self.animationRange)
                            self.secondAnimationLabel.alpha = 1.0
                            self.layoutIfNeeded()
                        }
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 1.0, relativeDuration: 0.2) { [unowned self] in
                        self.secondAnimationLabel.alpha = 0
                        self.layoutIfNeeded()
                    }
                }) { [unowned self] (completion: Bool) in
                    if completion {
                        self.labelConstraint?.update(offset: 0)
                        self.secondAnimationLabel.alpha = 0
                        self.secondIntervalLabel.alpha = 1
                        self.currentInterval = self.interval
                        secondIntervalLabel.text = "\(currentInterval)"
                    }
                }
            }
        }
    }
    
    private func animateIOS9() {
        self.layer.removeAllAnimations()
        
        self.secondIntervalLabel.alpha = 1.0
        self.secondAnimationLabel.alpha = 0.0
        self.fadeAnimationView.alpha = 0.8
        self.labelConstraint?.update(offset: 0)
        self.seekButton.transform = CGAffineTransform(rotationAngle: 0)
        
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.05, delay: 0, options: .beginFromCurrentState) { [unowned self] in
            var t = CGAffineTransform.identity
            if self.directionMode == .forward {
                t = t.rotated(by: CGFloat.pi / 4)
            }
            else {
                t = t.rotated(by: CGFloat.pi / -4)
            }
            
            t = t.scaledBy(x: 0.8, y: 0.8)
            self.seekButton.transform = t
            self.layoutIfNeeded()
        } completion: { (completion) in
            
            UIView.animate(withDuration: 0.05) { [unowned self] in
                if animationRange > 0 {
                    self.secondIntervalLabel.alpha = 0
                    self.layoutIfNeeded()
                }
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.05, options: .beginFromCurrentState, animations: { [unowned self] in
                if animationRange > 0 {
                    _ = self.directionMode == .forward ? self.labelConstraint!.update(offset: self.animationRange) : self.labelConstraint!.update(offset: -self.animationRange)
                    self.secondAnimationLabel.alpha = 1.0
                    self.layoutIfNeeded()
                }
            }, completion: nil)
                
            UIView.animate(withDuration: 0.15) { [unowned self] in
                var t = CGAffineTransform.identity
                t = t.rotated(by: 0)
                t = t.scaledBy(x: 1, y: 1)
                self.seekButton.transform = t
                self.fadeAnimationView.alpha = 0
                self.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.95, options: .overrideInheritedCurve) { [unowned self] in
                self.secondAnimationLabel.alpha = 0
                self.layoutIfNeeded()
            } completion: { [unowned self] (completion) in
                print(completion)
                if completion {
                    self.labelConstraint?.update(offset: 0)
                    self.secondAnimationLabel.alpha = 0
                    self.secondIntervalLabel.alpha = 1
                    self.currentInterval = self.interval
                    secondIntervalLabel.text = "\(currentInterval)"
                }
            }

        }
        
    }
    
    func resetDoubleTapTimer() {
        doubleTapHideTimer.invalidate()
        doubleTapHideTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hideSeekerButton), userInfo: nil, repeats: false)
    }
    
    func updateSeekRange() {
        interval = 10
        setUI()
        
    }
    
    // MARK: - Event
    @objc func onButtonTouched(_ sender: UIButton) {
        if directionMode == .backward {
            delegate?.onBackwardTouched(view: self, isContinues: isContinues, intervaltime: Double(currentInterval))
        }
        else {
            delegate?.onForwadTouched(view: self, isContinues: isContinues, intervaltime: Double(currentInterval))
        }
        
        self.updateCurrentIntervalText()
        
        if #available(iOS 10.0, *) {
            if animator.isRunning {
                animator.fractionComplete = 0.0
            }
            else {
                createAnimator()
                animator.startAnimation()
            }
        }
        else {
            animateIOS9()
        }
        
    }
    
    @objc func hideSeekerButton() {
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.alpha = 0
            self.layoutIfNeeded()
        }
    }
    
    
    deinit {
        if #available(iOS 10.0, *) {
            animator.stopAnimation(true)
        } else {
            // Fallback on earlier versions
        }
    }
}

