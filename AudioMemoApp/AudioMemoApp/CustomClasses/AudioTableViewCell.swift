//
//  AudioTableViewCell.swift
//  AudioMemoApp
//
//  Created by Rapha on 12.09.20.
//  Copyright © 2020 Rapha. All rights reserved.
//

import UIKit

protocol audioCellDelegate {
    func shouldPlaySound(at url: URL)
}

class AudioTableViewCell: UITableViewCell {

    @IBOutlet weak var audioFileLabel: UILabel!
    
    var delegate: audioCellDelegate?
    var url: URL?
    
    @IBAction func playButtonHandler(_ sender: UIButton) {
        if let url = url {
            delegate?.shouldPlaySound(at: url)
        }
        
    }
    
}
