//
//  SocketManager.swift
//  SpeechmaticsDemo
//
//  Created by FanPengpeng on 2023/4/20.
//

import UIKit
import Starscream
import Alamofire

protocol SocketManagerDelegate: NSObjectProtocol {
    func onRecognitionStarted(json: [String: Any])
    func onAudioAdded(seq_no: Int)
    func onAddTranscript(json: [String: Any])
    func onAddPartialTranscript(json: [String: Any])
    func onEndOfTranscript(json: [String: Any])
    func onError(code: Int?, type: String?, reason: String?)
    func onDisconnected(code: UInt16, reason: String)

}

class SocketManager: NSObject {
    
    private var tempToken: String?
    private var socket: WebSocket!
    private var lang: String = "cmn"
    private var seq_no = 0
    var isConnected = false
    var isRecognitionStarted = false

    
    weak var delegate: SocketManagerDelegate?
   
    private func reqTempToken(_ completion:(()->())?){
        // set the URL and request headers
        let url = URL(string: "https://mp.speechmatics.com/v1/api_keys?type=rt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // set the request body
        let ttl = ["ttl": 60]
        let jsonBody = try? JSONSerialization.data(withJSONObject: ttl)
        request.httpBody = jsonBody

        // create a URLSessionDataTask and execute the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Response status code: \(response.statusCode)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
            if let dic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let token = dic["key_value"] as? String {
                    print("token = \(token)")
                    self.tempToken = token
                    completion?()
                }
            }
        }
        task.resume()
    }
    
    private func handleError(_ error: Error?) {
        if let e = error as? WSError {
            DLog("websocket encountered an error: \(e.message)")
        } else if let e = error {
            DLog("websocket encountered an error: \(e.localizedDescription)")
        } else {
            DLog("websocket encountered an error")
        }
    }
    
    private func handldeReceivedText(_ string: String) {
        DLog("Received text: \(string)")
        guard let json = string.jsonObject() else { return }
        guard let msgType = json["message"] as? String else {return}
        switch msgType {
        case "RecognitionStarted":
            isRecognitionStarted = true
            delegate?.onRecognitionStarted(json: json)
        case "AudioAdded":
            seq_no = json["seq_no"] as! Int
            delegate?.onAudioAdded(seq_no: seq_no)
        case "AddTranscript":
            delegate?.onAddTranscript(json: json)
        case "AddPartialTranscript":
            delegate?.onAddPartialTranscript(json: json)
        case "EndOfTranscript":
            // 转录结束 可以安全断开连接了
            delegate?.onEndOfTranscript(json: json)
            break
        case "Error":
            DLog("Error code = \(String(describing: json["code"])) type = \(String(describing:json["type"] )) reason = \(String(describing: json["reason"]))")
            delegate?.onError(code:json["code"] as? Int, type: json["type"] as? String, reason: json["reason"] as? String )
        default:
            break
        }
    }
}

extension SocketManager {
    func connentSocket(lang: String, delegate: SocketManagerDelegate){
        self.lang = lang
        self.delegate = delegate
        var token: String = ""
        var wss: String = ""
        if KeyCenter.PRO {
            token = KeyCenter.APIKEY_PRO
            wss = KeyCenter.WSS_PRO
        }else {
            wss = KeyCenter.WSS
            if tempToken == nil {
                DLog("temp token == nil")
                reqTempToken { [weak self] in
                    self?.connentSocket(lang: lang, delegate: delegate)
                }
                return
            }
            token = tempToken!
        }
        
        guard let url = URL(string: "\(wss)\(lang)") else {
            return
        }
        let header = HTTPHeader.authorization(bearerToken: token)
        var request = URLRequest(url: url)
        request.headers.add(header)
        socket = WebSocket(request:request)
        socket.delegate = self
        socket.connect()
    }
    
    func sendStartRecognitionMessage(){
        if !isConnected {
            DLog("Error websocket 断开")
            socket.connect()
            return
        }
//        let msg = "{\"message\": \"StartRecognition\",\"audio_format\": {\"type\": \"raw\",\"encoding\": \"pcm_s16le\",\"sample_rate\": 16000},\"transcription_config\": {\"language\": \"\(lang)\", \"max_delay\": \(AppConfigs.shared.delay ?? 3.5),\"enable_partials\": true,\"punctuation_overrides\": {\"permitted_marks\": [\",\", \".\"]}}}"
//        socket.write(string: msg)
//        return
        var msgDic = [String: Any]()
        msgDic["message"] = "StartRecognition"
        var audio_formatDic = [String: Any]()
        audio_formatDic["type"] = "raw"
        audio_formatDic["encoding"] = "pcm_s16le"
        audio_formatDic["sample_rate"] = 16000
        msgDic["audio_format"] = audio_formatDic
        var transcription_configDic = [String: Any]()
        transcription_configDic["language"] = "\(lang)"
        if AppConfigs.shared.delay != nil {
            transcription_configDic["max_delay"] = AppConfigs.shared.delay
        }
        transcription_configDic["enable_partials"] = true
//        transcription_configDic["punctuation_overrides"] = "{\"permitted_marks\": [\",\", \".\"]}"
        let permitted_marks = [",","."]
        transcription_configDic["punctuation_overrides"] = ["permitted_marks" : permitted_marks]
        msgDic["transcription_config"] = transcription_configDic
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: msgDic, options: .prettyPrinted) else {
            return
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        print(" jsonString = \(jsonString)")
        socket.write(string: "\(jsonString)")
    }
    
    func sendEndOfTranscript() {
        if !isConnected {
            DLog("Error websocket 断开")
            return
        }
        let msg = "{\"message\": \"EndOfStream\",\"last_seq_no\":\(seq_no)}"
        socket.write(string: msg)
    }
    
    func sendAudioData(_ data: Data) {
        socket.write(data: data)
    }
    
    func disconnect(){
        socket.disconnect()
    }
    
}

extension SocketManager: WebSocketDelegate {
    
    // MARK: - WebSocketDelegate
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            DLog("websocket is connected: \(headers)")
            sendStartRecognitionMessage()
        case .disconnected(let reason, let code):
            isConnected = false
            DLog("websocket is disconnected: \(reason) with code: \(code)")
            delegate?.onDisconnected(code: code, reason: reason)
        case .text(let string):
           handldeReceivedText(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            socket.connect()
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
}
