//
//  RTCManager.swift
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/4/15.
//

import UIKit
import AgoraRtcKit

protocol RTCManagerDelegate: NSObjectProtocol {
    func onUserJoined(_ uid: UInt)
    func onPlaybackAudioFrame(_ frame: AgoraAudioFrame, channelId: String, uid: UInt)
}

class RTCManager: NSObject {
    
    private var agoraKit: AgoraRtcEngineKit!
    @objc var roomId: String?
    
    weak var delegate: RTCManagerDelegate?
    
    private var joinedSucceed: (()->())?
    
    private func createEngine(){
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.areaCode = .global
        
        let agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        self.agoraKit = agoraKit
        // get channel name from configs
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.enableAudio()
    }

    private func joinChannel(channelName: String, uid: String) {
        let option = AgoraRtcChannelMediaOptions()
        option.autoSubscribeAudio = true
        option.autoSubscribeVideo = false
        _ = agoraKit.joinChannel(byToken: nil, channelId: channelName, uid: UInt(uid) ?? 0, mediaOptions: option)
    }

}

extension RTCManager {
    
    @objc func setAudioFrameDelegate(_ delegate: AgoraAudioFrameDelegate) {
//        agoraKit.setPlaybackAudioFrameParametersWithSampleRate(44100, channel: 1, mode: .readOnly, samplesPerCall: 1024)
//        agoraKit.setAudioFrameDelegate(delegate)
        agoraKit.setPlaybackAudioFrameBeforeMixingParametersWithSampleRate(16000, channel: 1)
        agoraKit.setAudioFrameDelegate(delegate)
    }
    
    func join(channelName:String, uid: String, delegate: RTCManagerDelegate, success: (()->())? = nil){
        createEngine()
        joinedSucceed = success
        joinChannel(channelName: channelName, uid: uid)
        self.delegate = delegate
        setAudioFrameDelegate(self)
    }
    
    @objc func leave(){
        self.agoraKit.leaveChannel()
    }
}


extension RTCManager: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        joinedSucceed?()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        delegate?.onUserJoined(uid)
    }
    
}

extension RTCManager: AgoraAudioFrameDelegate {
    func onPlaybackAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {
//        delegate?.onPlaybackAudioFrame(frame, channelId: channelId)
        return true
    }
    
    func onPlaybackAudioFrame(beforeMixing frame: AgoraAudioFrame, channelId: String, uid: UInt) -> Bool {
        delegate?.onPlaybackAudioFrame(frame, channelId: channelId, uid: uid)
        return true
    }
}

