//
//  AudioSubtitleSelectViewController.swift
//  SampleVideoPlayer
//
//  Created by 이기완 on 2021/03/24.
//

import AVKit
import UIKit

protocol AudioSubtitleSelectViewDelegate : class {
    func onSubtitleChanged(viewController: AudioSubtitleSelectViewController, selectedSubtitleMetadata: AVMediaSelectionOption)
    func onAudioChanged(viewController: AudioSubtitleSelectViewController, selectedAudioMetadata: AVMediaSelectionOption)
}

class AudioSubtitleSelectViewController: UIViewController {
    weak var delegate: AudioSubtitleSelectViewDelegate?
    
    @IBOutlet weak var audioTableView: UITableView!
    @IBOutlet weak var subtitleTableView: UITableView!
    
    var audioMetadataList: [AVMediaSelectionOption] = []
    var subtitleMetadataList: [AVMediaSelectionOption] = []
    
    var selectedAudioMetadata: AVMediaSelectionOption?
    var selectedSubtitleMetadata: AVMediaSelectionOption?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioTableView.register(UINib(nibName: "SelectTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectTableViewCell")
        subtitleTableView.register(UINib(nibName: "SelectTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectTableViewCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func onCloseTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension AudioSubtitleSelectViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == audioTableView ? audioMetadataList.count : subtitleMetadataList.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableView == audioTableView ? audioMetadataList[indexPath.row] : subtitleMetadataList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTableViewCell", for: indexPath) as! SelectTableViewCell
        cell.data = data        
        
        cell.seperatorView.isHidden = indexPath.row == 0 ? true : false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = tableView == audioTableView ? audioMetadataList[indexPath.row] : subtitleMetadataList[indexPath.row]
        
        if tableView == audioTableView {
            if selectedAudioMetadata?.displayName == data.displayName {
                cell.setSelected(true, animated: false)
            }
            else {
                cell.setSelected(false, animated: false)
            }
        }
        else {
            selectedSubtitleMetadata?.displayName == data.displayName ? cell.setSelected(true, animated: false) : cell.setSelected(false, animated: false)
        }
        
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableView == audioTableView ? audioMetadataList[indexPath.row] : subtitleMetadataList[indexPath.row]
        if tableView == audioTableView {
            selectedAudioMetadata = data
            delegate?.onAudioChanged(viewController: self, selectedAudioMetadata: selectedAudioMetadata!)
        }
        else {
            selectedSubtitleMetadata = data
            delegate?.onSubtitleChanged(viewController: self, selectedSubtitleMetadata: selectedSubtitleMetadata!)
        }
        
        tableView.reloadData()
    }
    
    
}
