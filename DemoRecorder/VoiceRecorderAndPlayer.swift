//
//  VoiceRecorderAndPlayer.swift
//  DemoRecorder
//
//  Created by Kiran Kumar on 3/17/19.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit
import AVFoundation

enum RecorderAndPlayerState {
    case kPaused, kPlaying, kRecording, kStopped
}

let RecordingDidFinishNotification = Notification.Name("RecordingDidFinish")
let PlaybackDidFinishNotification = Notification.Name("PlaybackDidFinish")
let PlaybackDidPauseNotification = Notification.Name("PlaybackDidPause")

class VoiceRecorderAndPlayer : NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var _soundRecorder : AVAudioRecorder!
    var _soundPlayer : AVAudioPlayer!
    var _audioSession = AVAudioSession.sharedInstance()
    var _recorderAndPlayerState = RecorderAndPlayerState.kStopped
    var _filename = "audioFile.aac"
    var _playbackVolume : Float = 1.0
    
    private override init() {} // Is it that easy to make the init private?
    
    static let shared = VoiceRecorderAndPlayer() // static constant property in the class is accessible to all instances of the class and can NOT be overridden by subclasses. The uses extend beyond singletons, but it's good for singletons nevertheless :)
    
    func setUpRecorder() {
        let audioFilename = getFullPath(forFilename: _filename)
        let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC,
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0]
            as [String : Any]
        
        do {
            _soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSettings)
            _soundRecorder.delegate = self
        } catch {
            print(error)
        }
    }
    
    func setUpPlayer() {
        let audioFilename = getFullPath(forFilename: _filename)
        do {
            _soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            _soundPlayer.delegate = self
            _soundPlayer.prepareToPlay()
            _soundPlayer.volume = _playbackVolume
        } catch {
            print(error)
        }
    }

    //MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        setUpPlayer()
        NotificationCenter.default.post(name: RecordingDidFinishNotification, object: self)
    }
    
    //MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: PlaybackDidFinishNotification, object: self)
    }
    
    //MARK: - Utilities
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFullPath(forFilename : String) -> URL{
        let audioFullFilename = getDocumentDirectory().appendingPathComponent(forFilename)
        return audioFullFilename
    }
}
