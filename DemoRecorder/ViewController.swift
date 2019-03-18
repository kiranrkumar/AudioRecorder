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
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var audioSession : AVAudioSession!
    var playPauseState = PlayPauseState.playing
    
    var filename : String = "audioFile.aac"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Initially, I got the following errors everytime I try to play back recorded audio the FIRST TIME ONLY after launching my app:
            DemoRecorder[5930:2262392] [avas] AVAudioSessionPortImpl.mm:56:ValidateRequiredFields: Unknown selected data source for Port Speaker (type: Speaker)
            DemoRecorder[5930:2262392] [avas] AVAudioSessionPortImpl.mm:56:ValidateRequiredFields: Unknown selected data source for Port Receiver (type: Receiver)
         
            These errors would show up, and my first segment of recorded audio would not play back. Subsequent segments would work just fine
         
            The fix below (from https://forums.developer.apple.com/thread/108785) does not get rid of the errors, but it DOES fix the issues that initially prevented me from playing back my first recording. Additionally, it significantly raises the playback volume.
         
            I don't know what these two lines really do. I'll have to investigate
         */
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {}

        playButton.layer.cornerRadius = 10;
        recordButton.layer.cornerRadius = 10;
        playButton.isEnabled = false
        setUpRecorder()
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setUpRecorder() {
        let audioFilename = getDocumentDirectory().appendingPathComponent(filename)
        let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC,
                             AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                             AVNumberOfChannelsKey : 2,
        AVSampleRateKey : 44100.0] as [String : Any]
        
        do {
            soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func setUpPlayer() {
        let audioFilename = getDocumentDirectory().appendingPathComponent(filename)
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
        setUpPlayer()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    
    @IBAction func recordAction(_ sender: Any) {
        if recordButton.titleLabel?.text == "Record" {
            soundRecorder.record()
            recordButton.setTitle("Stop", for: .normal)
            playButton.isEnabled = false
        } else {
            soundRecorder.stop()
            recordButton.setTitle("Record", for: .normal)
            playButton.isEnabled = true
        }
    }
    
    @IBAction func playAction(_ sender: Any) {
        if playButton.titleLabel?.text == "Play" {
            playButton.setTitle("Stop", for: .normal)
            recordButton.isEnabled = false
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            playButton.setTitle("Play", for: .normal)
            recordButton.isEnabled = true
        }
    }
    
    
    @IBAction func playPauseTouchUp(_ sender: Any) {
        var imagePath : String
        if playPauseState == .paused {
            playPauseState = .playing
            imagePath = Bundle.main.path(forResource: "pause", ofType: "png") ?? "" // ?? makes this default to "" if result is nil
            soundPlayer.play()
        } else {
            playPauseState = .paused
            imagePath = Bundle.main.path(forResource: "play", ofType: "png")! // ! forces "unwrap" meaning that the program will abort if result is nil
            soundPlayer.pause()
        }
        playPauseImageButton.setImage(UIImage(contentsOfFile: imagePath), for: .normal)
    }
}

