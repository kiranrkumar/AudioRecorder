//
//  VoiceRecorderAndPlayer.swift
//  DemoRecorder
//
//  Created by Kiran Kumar on 3/17/19.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

let RecordingDidStartNotification = Notification.Name("RecordingDidStart")
let RecordingDidFinishNotification = Notification.Name("RecordingDidFinish")
let PlaybackDidStartNotification = Notification.Name("PlaybackDidStart")
let PlaybackDidPauseNotification = Notification.Name("PlaybackDidPause")
let PlaybackDidFinishNotification = Notification.Name("PlaybackDidFinish")

class VoiceRecorderAndPlayer : NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    private var _soundRecorder : AVAudioRecorder!
    private var _soundPlayer : AVAudioPlayer!
    private var _audioSession = AVAudioSession.sharedInstance()
    private var _filename = "audioFile.aac"
    private var _playbackVolume : Float = 1.0
    private var _isPaused : Bool = false
    
    static let sharedInstance = VoiceRecorderAndPlayer()
    
    private override init() { // Is it that easy to make the init private?
        
        super.init()
        setUpRecorder()
        
        /* Initially, I got the following errors everytime I try to play back recorded audio the FIRST TIME ONLY after launching my app:
         DemoRecorder[5930:2262392] [avas] AVAudioSessionPortImpl.mm:56:ValidateRequiredFields: Unknown selected data source for Port Speaker (type: Speaker)
         DemoRecorder[5930:2262392] [avas] AVAudioSessionPortImpl.mm:56:ValidateRequiredFields: Unknown selected data source for Port Receiver (type: Receiver)
         
         These errors would show up, and my first segment of recorded audio would not play back. Subsequent segments would work just fine
         
         The fix below (from https://forums.developer.apple.com/thread/108785) does not get rid of the errors, but it DOES fix the issues that initially prevented me from playing back my first recording. Additionally, it significantly raises the playback volume.
         
         I don't know what these two lines really do. I'll have to investigate
         */
        do {
            try _audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
            try _audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {}
    }
    
    private func setUpRecorder() {
        let audioFilename = getFullPath(forFilename: _filename)
        let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC,
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0]
            as [String : Any]
        
        do {
            _soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSettings)
            _soundRecorder.delegate = self
            _soundRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    private func setUpPlayer() {
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
    
    //MARK: Recording
    func record() {
        _soundRecorder.record()
        NotificationCenter.default.post(name: RecordingDidStartNotification, object: self)
    }
    
    func stopRecording() {
        _soundRecorder.stop()
    }
    
    func isRecording() -> Bool {
        return _soundRecorder.isRecording
    }
    
    //MARK: Playback
    func play() {
        _soundPlayer.play()
        _isPaused = false
        NotificationCenter.default.post(name: PlaybackDidStartNotification, object: self)
    }
    
    func pausePlayback() {
        _soundPlayer.pause()
        _isPaused = true
        NotificationCenter.default.post(name: PlaybackDidPauseNotification, object: self)
    }
    
    func isPaused() -> Bool {
        return _isPaused
    }
    
    func stopPlayback() {
        _soundPlayer.stop()
        _soundPlayer.currentTime = 0
        _isPaused = false
        NotificationCenter.default.post(name: PlaybackDidFinishNotification, object: self)
    }
    
    func isPlaying() -> Bool {
        return _soundPlayer.isPlaying
    }

    //MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        setUpPlayer()
        NotificationCenter.default.post(name: RecordingDidFinishNotification, object: self)
    }
    
    //MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        _isPaused = false
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
