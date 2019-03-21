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
    @IBOutlet weak var playPauseImageButton: UIButton!

    var recorderAndPlayer : VoiceRecorderAndPlayer = VoiceRecorderAndPlayer.sharedInstance
    let playImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "play", ofType: "png")!)
    let pauseImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "pause", ofType: "png")!)
    let playImageID = "ButtonPlay"
    let pauseImageID = "ButtonPause"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordButton.layer.cornerRadius = 10;
        playPauseImageButton.isEnabled = false;
        playPauseImageButton.accessibilityIdentifier = playImageID
        
        NotificationCenter.default.addObserver(self, selector: #selector(_recordingDidStart(_:)), name: RecordingDidStartNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_recordingDidFinish(_:)), name: RecordingDidFinishNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidStart(_:)), name: PlaybackDidStartNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidFinish(_:)), name: PlaybackDidFinishNotification, object: recorderAndPlayer)
    }
    
    //MARK: Notification Responders
    @objc func _recordingDidStart(_ notification:Notification) {
        recordButton.setTitle("Stop", for: .normal)
        playPauseImageButton.isEnabled = false;
    }
    
    @objc func _recordingDidFinish(_ notification:Notification) {
        recordButton.setTitle("Record", for: .normal)
        playPauseImageButton.isEnabled = true;
    }
    
    @objc func _playbackDidStart(_ notification:Notification) {
        recordButton.isEnabled = false;
        updateButton(image: pauseImage!, identifer: pauseImageID)
    }
    
    @objc func _playbackDidFinish(_ notification:Notification) {
        recordButton.isEnabled = true;
        updateButton(image: playImage!, identifer: playImageID)
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playPauseImageButton.isEnabled = true
    }
    
    @IBAction func recordAction(_ sender: Any) {
        if recordButton.titleLabel?.text == "Record" {
            recorderAndPlayer.record()
        } else {
            recorderAndPlayer.stopRecording()
        }
    }
    
    @IBAction func playPauseTouchUp(_ sender: Any) {

        let identifier = playPauseImageButton.accessibilityIdentifier!
        if (identifier.elementsEqual(playImageID)) {
            recorderAndPlayer.play()
        } else if (identifier.elementsEqual(pauseImageID)) {
            recorderAndPlayer.stopPlayback()
        } else {
            assert(false, "ViewController::playPauseTouchUp -> Unexpected button identifier")
        }
    }
    
    func updateButton(image : UIImage, identifer : String) {
        playPauseImageButton.setImage(image, for: .normal)
        playPauseImageButton.accessibilityIdentifier = identifer
    }
}

