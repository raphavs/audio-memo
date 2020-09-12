//
//  ViewController.swift
//  AudioMemoApp
//
//  Created by Rapha on 11.09.20.
//  Copyright © 2020 Rapha. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTableViewController: UIViewController {
    
    @IBOutlet weak var zeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playbarButton: UIButton!
    @IBOutlet weak var playbar: UISlider!

    var audioFiles = [String]()
    var audioUrls = [URL]()
    var playerShown = false
    var audioPlayer = AVAudioPlayer()
    var timer: Timer?
    
    override func viewWillDisappear(_ animated: Bool) {
        if playerShown {
            audioPlayer.stop()
            stopAudio()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let documentQuery = Utility.getFilenamesAndUrls(for: tabBarItem.title!)
        if documentQuery.success {
            audioUrls = documentQuery.urls
            audioFiles = documentQuery.names
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
    }

    func animatePlayer(show: Bool, completion: @escaping () -> ()) {
        if show {
            zeroHeightConstraint.isActive = false
            fullHeightConstraint.isActive = true
        } else {
            fullHeightConstraint.isActive = false
            zeroHeightConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.25, animations:  {
            self.view.layoutIfNeeded()
        }) { bool in
            completion()
        }
    }
    
    func startAudio() {
        timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        audioPlayer.play()
    }
    
    @objc func updateSlider() {
        playbar.setValue(Float(audioPlayer.currentTime), animated: true)
    }
    
    func stopAudio() {
        timer?.invalidate()
        playerShown = !playerShown
        animatePlayer(show: playerShown) {
            
        }
    }
    
    @IBAction func playbarHandler(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(playbar.value)
    }
    
    @IBAction func playbarButtonHandler(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            sender.setImage(UIImage(named: "PlayButton"), for: .normal)
            audioPlayer.pause()
        } else {
            sender.setImage(UIImage(named: "PauseButton"), for: .normal)
            audioPlayer.play()
        }
    }

}

extension AudioTableViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudio()
    }
    
}

extension AudioTableViewController: audioCellDelegate {
    
    func shouldPlaySound(at url: URL) {
        playbarButton.setImage(UIImage(named: "PauseButton"), for: .normal)
        playbar.setValue(0.0, animated: false)
        if !playerShown {
            playerShown = !playerShown
            animatePlayer(show: playerShown, completion: {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer.delegate = self
                    self.playbar.maximumValue = Float(self.audioPlayer.duration)
                    self.startAudio()
                } catch {
                    print(error)
                }
            })
        } else {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.delegate = self
                playbar.maximumValue = Float(audioPlayer.duration)
                startAudio()
            } catch {
                print(error)
            }
        }
    }
    
}

extension AudioTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! AudioTableViewCell

        cell.audioFileLabel.text = audioFiles[indexPath.row]
        cell.url = audioUrls[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let cell = tableView.cellForRow(at: indexPath) as? AudioTableViewCell {
                if Utility.deleteAudioMemo(at: cell.url!) {
                    audioUrls.remove(at: indexPath.row)
                    audioFiles.remove(at: indexPath.row)
                    tableView.reloadData()
                }
            }
        }
    }
    
}

