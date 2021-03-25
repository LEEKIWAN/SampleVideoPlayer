//
//  SelectTableViewCell.swift
//  SampleVideoPlayer
//
//  Created by 이기완 on 2021/03/24.
//

import UIKit
import AVKit

class SelectTableViewCell: UITableViewCell {

    var data: AVMediaSelectionOption? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        checkmarkImageView.isHidden = !selected
        if selected {
            
            titleLabel.textColor = .white
        }
        else {
            titleLabel.textColor = .systemGray2
        }
    }
    
    func updateUI() {
        guard let data = data else { return }
        
//        var title = ""
//        let titles = AVMetadataItem.metadataItems(from: data.commonMetadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: .common)
//
//        if titles.count > 0 {
//            let titlesForPreferredLanguages = AVMetadataItem.metadataItems(from: titles, filteredAndSortedAccordingToPreferredLanguages: NSLocale.preferredLanguages)
//
//            if titlesForPreferredLanguages.count > 0 {
//                title = (titlesForPreferredLanguages.first?.stringValue)!
//            }
//            else {
//                title = (titles.first?.stringValue)!
//            }
//        }
        
//        titleLabel.text = "\(title)(\(data.displayName))"
        
        if data.commonMetadata.isEmpty {
            titleLabel.text = "끄기"
        }
        else {
            titleLabel.text = data.displayName
        }
        
        
    }
    
}
