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
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

//        checkmarkImageView.isHidden = !selected
        
//        if selected {
            titleLabel.textColor = .white
//        }
//        else {
//            titleLabel.textColor = .darkGray
//        }
    }
    
    func updateUI() {
        
        titleLabel.text = data?.displayName
        
        
        
    }
    
}
