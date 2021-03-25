//
//  PlayerSliderView.swift
//  Kollus Player
//
//  Created by kiwan on 2020/07/28.
//  Copyright © 2020 kiwan. All rights reserved.
//

import UIKit

extension UISlider {

    var trackBounds: CGRect {
        return trackRect(forBounds: bounds)
    }

    var trackFrame: CGRect {
        guard let superView = superview else { return CGRect.zero }
        return self.convert(trackBounds, to: superView)
    }

    var thumbBounds: CGRect {
        return thumbRect(forBounds: frame, trackRect: trackBounds, value: value)
    }

    var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackFrame, value: value)
    }
}


protocol PlayerSliderViewDelegate : class {
    func sliderTouchBegan(slider: PlayerSliderView, thumbXPoint: CGFloat)
    func sliderValueChanged(slider: PlayerSliderView, thumbXPoint: CGFloat)
    func sliderTouchEnd(slider: PlayerSliderView)
    
}

class PlayerSliderView: UISlider {
    
    // MARK: - variable
    var totalDuration: Double = 0
    
    weak var delegate: PlayerSliderViewDelegate?
    
    public var progress: Float = 0 {
        didSet {
            self.setProgress(progress, animated: false)
        }
    }
    
    var thumbCenterX: CGFloat {
        return thumbBounds.midX
    }
    
    
    private var progressView = UIProgressView()
    
    // MARK: - function
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureSlider()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSlider()
    }
    
    private func configureSlider() {
        self.insertSubview(progressView, at: 0)
        progressView.progressTintColor = .red
        self.thumbTintColor = .red
        progressView.backgroundColor = .clear

        progressView.snp.makeConstraints { (make) in
            make.leading.equalTo(1)
            make.trailing.equalTo(-1)
            make.center.equalToSuperview().priorityHigh()
        }
        
        self.addTarget(self, action: #selector(onSliderValueChanged(slider:event:)), for: .valueChanged)
    }
    
    func setProgress(_ progress: Float, animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.value = progress
            self?.progressView.setProgress(progress, animated: animated)
        }
    }
    
    // MARK: - Event
    
    @objc func onSliderValueChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                delegate?.sliderTouchBegan(slider: self, thumbXPoint: thumbCenterX)
            case .moved:
                delegate?.sliderValueChanged(slider: self, thumbXPoint: thumbCenterX)
            case .ended:
                setProgress(slider.value, animated: false)
                delegate?.sliderTouchEnd(slider: self)
            default:
                setProgress(slider.value, animated: false)
                delegate?.sliderTouchEnd(slider: self)
                break
            }
        }
    }
}
