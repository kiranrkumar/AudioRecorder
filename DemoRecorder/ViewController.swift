//
//  ViewController.swift
//  DemoRecorder
//
//  Created by Kiran Kumar on 3/15/19.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit
import AVFoundation

enum PlayPauseState {
    case playing, paused
}

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate { // KRKNOTES - Looks like protocols and superclasses are part of the same list. Here, I'm inheriting from UIViewController and conforming to two protocols

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playPauseImageButton: UIButton!

    var recorderAndPlayer : VoiceRecorderAndPlayer = VoiceRecorderAndPlayer.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playButton.layer.cornerRadius = 10;
        recordButton.layer.cornerRadius = 10;
        playButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(_recordingDidStart(_:)), name: RecordingDidStartNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_recordingDidFinish(_:)), name: RecordingDidFinishNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidStart(_:)), name: PlaybackDidStartNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidFinish(_:)), name: PlaybackDidFinishNotification, object: recorderAndPlayer)
    }
    
    @objc func _recordingDidStart(_ notification:Notification) {
        print("Controller: _recordingDidStart\n")
        recordButton.setTitle("Stop", for: .normal)
        playButton.isEnabled = false;
    }
    
    @objc func _recordingDidFinish(_ notification:Notification) {
        print("Controller: _recordingDidFinish\n")
        recordButton.setTitle("Record", for: .normal)
        playButton.isEnabled = true;
    }
    
    @objc func _playbackDidStart(_ notification:Notification) {
        print("Controller: _playbackDidStart\n")
        recordButton.isEnabled = false;
        playButton.setTitle("Stop", for: .normal)
    }
    
    @objc func _playbackDidFinish(_ notification:Notification) {
        print("Controller: _playbackDidFinish\n")
        recordButton.isEnabled = true;
        playButton.setTitle("Play", for: .normal)
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    
    @IBAction func recordAction(_ sender: Any) {
        if recordButton.titleLabel?.text == "Record" {
            recorderAndPlayer.record()
        } else {
            recorderAndPlayer.stopRecording()
        }
    }
    
    @IBAction func playAction(_ sender: Any) {
        if playButton.titleLabel?.text == "Play" {
            recorderAndPlayer.play()
        } else {
            recorderAndPlayer.stopPlayback()
        }
    }
    
    
//    @IBAction func playPauseTouchUp(_ sender: Any) {
//        var imagePath : String
//        if playPauseState == .paused {
//            playPauseState = .playing
//            imagePath = Bundle.main.path(forResource: "pause", ofType: "png") ?? "" // ?? makes this default to "" if result is nil
//            soundPlayer.play()
//        } else {
//            playPauseState = .paused
//            imagePath = Bundle.main.path(forResource: "play", ofType: "png")! // ! forces "unwrap" meaning that the program will abort if result is nil
//            soundPlayer.pause()
//        }
//        playPauseImageButton.setImage(UIImage(contentsOfFile: imagePath), for: .normal)
//    }
}

