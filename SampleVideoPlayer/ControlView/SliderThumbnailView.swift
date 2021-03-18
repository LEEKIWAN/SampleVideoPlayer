//
//  SliderThumbnailView.swift
//  Kollus Player
//
//  Created by kiwan on 2020/07/28.
//  Copyright © 2020 kiwan. All rights reserved.
//

import UIKit

class SliderThumbnailView: UIView {
    
    var isShown: Bool = false {
        didSet {
            self.setShown(isShown)
        }
    }
    
    var thumbnailImageView = UIImageView()
    
    var currentTimeLabel = UILabel()
    
    var maximumWidth: CGFloat = 180
    
    //MARK: - Func
    override init(frame: CGRect) {
        super.init(frame: frame)
        setNib()
        setEvent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setNib()
        setUI()
        setEvent()
    }
    
    private func setNib() {
        addSubview(thumbnailImageView)
        addSubview(currentTimeLabel)

        currentTimeLabel.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview().offset(0)
            maker.centerX.equalToSuperview()
        }
                
        thumbnailImageView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.trailing.equalToSuperview()
            maker.leading.equalToSuperview()
            maker.height.equalTo(thumbnailImageView.snp.width).multipliedBy(9.0 / 16.0)
            
            maker.bottom.equalTo(currentTimeLabel.snp.top).offset(-10)
            
        }
    }
    
    func updateConstraint(thumbnailWidth: CGFloat, thumbnailHeight: CGFloat) {
        thumbnailImageView.snp.remakeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.trailing.equalToSuperview()
            maker.leading.equalToSuperview()
            maker.height.equalTo(thumbnailImageView.snp.width).multipliedBy(thumbnailHeight / thumbnailWidth)
            
            maker.bottom.equalTo(currentTimeLabel.snp.top).offset(-10)
        }
        
    }
    
    private func setUI() {
        self.backgroundColor = .clear
        
        thumbnailImageView.backgroundColor = .black        
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.layer.masksToBounds = true
        
        
        currentTimeLabel.textColor = .white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        currentTimeLabel.text = "1:23:19"
    }
    
    private func setEvent() {
        
    }
    
    private func setShown(_ shown: Bool) {
        shown ? show() : hide()
    }
    
    private func show() {
        guard let controlView = self.superview?.superview as? VideoControlView else { return }
        UIView.animate(withDuration: 0.1) { [unowned self] in
            controlView.thumbnailWidthConstraint.constant = maximumWidth
            controlView.thumbnailBottomConstraint.constant = 8
            
            controlView.sliderThumbnailView.alpha = 1
            controlView.layoutIfNeeded()
        }
    }
     
    private func hide() {
        guard let controlView = self.superview?.superview as? VideoControlView else { return }
        controlView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.1) { [unowned self] in
            controlView.thumbnailWidthConstraint.constant = maximumWidth / 2
            controlView.thumbnailBottomConstraint.constant = 0

            controlView.sliderThumbnailView.alpha = 0

            controlView.layoutIfNeeded()
        }
    }
    
    
    func setThumbnail(image: UIImage? = nil, time: String) {
        print(time)
        
//        if image != nil {
//            if ((parentViewController as? VideoViewController)?.controlView.isDisplayBookmark)! && UIScreen.main.bounds.height <= 320 {
//                thumbnailImageView.isHidden = true
//            }
//            else {
//                thumbnailImageView.image = image
//                thumbnailImageView.isHidden = false
//            }
//        }
//        else {
//            thumbnailImageView.isHidden = true
//        }
        
        
        currentTimeLabel.text = time
    }
    

}
