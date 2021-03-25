//
//  AudioSubtitleSelectViewController.swift
//  SampleVideoPlayer
//
//  Created by 이기완 on 2021/03/24.
//

import AVKit
import UIKit

class AudioSubtitleSelectViewController: UIViewController {

    
    @IBOutlet weak var audioTableView: UITableView!
    @IBOutlet weak var subtitleTableView: UITableView!
    
    var audioMetadataList: [AVMediaSelectionOption] = []
    var subtitleMetadataList: [AVMediaSelectionOption] = []
    
    
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
        return cell
        
    }
    
    
}
