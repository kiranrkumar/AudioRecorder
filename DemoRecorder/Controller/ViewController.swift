//
//  ViewController.swift
//  DemoRecorder
//
//  Created by Kiran Kumar on 3/15/19.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate { // KRKNOTES - Looks like protocols and superclasses are part of the same list. Here, I'm inheriting from UIViewController and conforming to two protocols

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playPauseImageButton: UIButton!

    var recorderAndPlayer : VoiceRecorderAndPlayer = VoiceRecorderAndPlayer.sharedInstance
    let playImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "play", ofType: "png")!)
    let pauseImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "pause", ofType: "png")!)
    let recordImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "record", ofType: "png")!)
    let stopImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "stop", ofType: "png")!)
    
    let playImageID = "ButtonPlay"
    let pauseImageID = "ButtonPause"
    let recordImageID = "ButtonRecord"
    let stopImageID = "ButtonStop"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playPauseImageButton.isEnabled = false;
        playPauseImageButton.accessibilityIdentifier = playImageID
        recordButton.accessibilityIdentifier = recordImageID
        
        NotificationCenter.default.addObserver(self, selector: #selector(_recordingDidStart(_:)), name: RecordingDidStartNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_recordingDidFinish(_:)), name: RecordingDidFinishNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidStart(_:)), name: PlaybackDidStartNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidFinish(_:)), name: PlaybackDidFinishNotification, object: recorderAndPlayer)
    }
    
    //MARK: Notification Responders
    @objc func _recordingDidStart(_ notification:Notification) {
        playPauseImageButton.isEnabled = false;
        updateButton(button: recordButton, image: stopImage!, identifer: stopImageID)
    }
    
    @objc func _recordingDidFinish(_ notification:Notification) {
        updateButton(button: recordButton, image: recordImage!, identifer: recordImageID)
        playPauseImageButton.isEnabled = true;
    }
    
    @objc func _playbackDidStart(_ notification:Notification) {
        recordButton.isEnabled = false;
        updateButton(button : playPauseImageButton, image: pauseImage!, identifer: pauseImageID)
    }
    
    @objc func _playbackDidFinish(_ notification:Notification) {
        updateButton(button : playPauseImageButton, image: playImage!, identifer: playImageID)
        recordButton.isEnabled = true;
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
    
    @IBAction func recordTouchUp(_ sender: Any) {
        let identifier = recordButton.accessibilityIdentifier!
        if (identifier.elementsEqual(recordImageID)) {
            recorderAndPlayer.record()
        } else if (identifier.elementsEqual(stopImageID)) {
            recorderAndPlayer.stopRecording()
        } else {
            assert(false, "ViewController::recordTouchUp -> Unexpected button identifier")
        }
    }
    
    func updateButton(button : UIButton, image : UIImage, identifer : String) {
        button.setImage(image, for: .normal)
        button.accessibilityIdentifier = identifer
    }
}

