//
//  ViewController.swift
//  SpeechmaticsDemo
//
//  Created by FanPengpeng on 2023/4/18.
//

import UIKit
import Starscream
import AgoraRtcKit
import Alamofire
import MBProgressHUD

//import YYModel

private let kCellId = "TranscriptCell"

private let finalColor = UIColor.red
private let nonFinalColor = UIColor.black

class RoomViewController: UIViewController {
    
    @IBOutlet weak var transcriptButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    
    private let writeTextQueue = DispatchQueue(label: "room.writeText.queue")
    
    var channelName: String!
    var uid: String!
    var name: String!
    var lang: String!
    

    private var finalText: String = ""
//    private var currentText: String = ""
    private var currentAttriText: NSMutableAttributedString?
    private var startDate: Date?
    
    // 所有主播的id
    private var uidArray = [UInt]()
    
    private var isRecognitionStarted = false
    private var startTranscript = false
    
    private let rtcManager = RTCManager()
    private let socketManager = SocketManager()
    
    private var txtfileName: String = ""
    
    deinit {
        DLog("-销毁成功-")
        rtcManager.leave()
        socketManager.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = channelName
        rtcManager.join(channelName: channelName, uid: uid, delegate: self)
        socketManager.connentSocket(lang: lang, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppConfigs.shared.delay == nil {
            self.settingsBarButton.title = "设置"
        }else {
            self.settingsBarButton.title = "\(AppConfigs.shared.delay!)"            
        }
    }
    
    @IBAction func didClickTranscriptButton(_ sender: UIButton) {
        if !startTranscript {
            startTranscript = true
            sender.isSelected = true
            self.txtfileName = STTFilesManager.createFileName(forChannel: self.channelName)
        }else {
            sender.isEnabled = false
            socketManager.sendEndOfTranscript()
        }
    }
    
    @IBAction func didClickSettingButton(_ sender: Any) {
        
    }
    
    
    @IBAction func didClickLogBarButton(_ sender: Any) {
        let vc = STTChannelSTableViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RoomViewController {
    
    private func writeFinalText() {
        let fileName = self.txtfileName.appending("_final")
        writeTextQueue.async { [weak self] in
            guard let self = self else {return}
            STTFilesManager.writeToFile(withText: self.finalText, channel: self.channelName, fileName: fileName)
        }
    }
    
    private func writeRealTimeText(_ text: String) {
        let fileName = self.txtfileName.appending("_time")
        let newText = text.appending("\n")
        writeTextQueue.async { [weak self] in
            guard let self = self else {return}
            STTFilesManager.appendTextToFile(withText: newText, channel: self.channelName, fileName: fileName)
        }
    }
    
    private func textFromTranscriptJsonData(_ json: [String: Any]) -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return ""
        }
        guard let obj = decodePartialTranscript(jsonData) else {
            return ""
        }
        
//        var allWards = [String]()
//        obj.results?.forEach({ result in
//            let wards = result.alternatives.map({
//                $0.content
//            })
//            allWards.append(contentsOf: wards)
//        })
//        return allWards.joined(separator: " ")
        return obj.metadata?.transcript ?? ""
    }
}

extension RoomViewController: SocketManagerDelegate {
    func onDisconnected(code: UInt16, reason: String) {
        MBProgressHUD.showError("websocket断开：code = \(code), reason = \(reason)", inView: self.view)
    }
    
    
    
    func onRecognitionStarted(json: [String: Any]) {
        isRecognitionStarted = true
    }
    
    func onAudioAdded(seq_no: Int){
        
    }
    
    func onAddTranscript(json: [String: Any]){
        let newfinalText = textFromTranscriptJsonData(json)
//        currentText = finalText
        currentAttriText = NSMutableAttributedString.init(string: finalText, attributes: [NSAttributedString.Key.foregroundColor : finalColor])
        let newfinalAttriText = NSAttributedString(string: newfinalText, attributes: [NSAttributedString.Key.foregroundColor : finalColor])
        currentAttriText?.append(newfinalAttriText)
        finalText.append(newfinalText)
        writeFinalText()
        tableView.reloadData()
    }
    
    func onAddPartialTranscript(json: [String: Any]){
        if startDate == nil {
            startDate = Date()
        }
        let text = textFromTranscriptJsonData(json)
        currentAttriText = NSMutableAttributedString.init(string: finalText, attributes: [NSAttributedString.Key.foregroundColor : finalColor])
        let newNonfinalAttriText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : nonFinalColor])
        currentAttriText?.append(newNonfinalAttriText)
//        currentText = finalText.appending(text)
        writeRealTimeText(text)
        tableView.reloadData()

    }
    
    func onEndOfTranscript(json: [String: Any]){
        self.transcriptButton.isSelected = false
//        self.transcriptButton.isEnabled = true
    }
    
    func onError(code: Int?, type: String?, reason: String?){
//        self.transcriptButton.isEnabled = true
        if type != nil {
            MBProgressHUD.showInfo("type = \(type!) reason: \(reason ?? "")",inView: view)
        }
    }
    
}

extension RoomViewController: RTCManagerDelegate {
    
    func onUserJoined(_ uid: UInt) {
        self.uidArray.append(uid)
        tableView.reloadData()
    }
    
    func onPlaybackAudioFrame(_ frame: AgoraAudioFrame, channelId: String,uid: UInt) {
        if startTranscript == false {
            return
        }
        if isRecognitionStarted {
            let data = Data(bytes: frame.buffer!, count: frame.samplesPerChannel * frame.channels * frame.bytesPerSample)
            socketManager.sendAudioData(data)
        }else{
            DLog(" RecognitionStarted = false 需要等到RecognitionStarted为true 才可以发送语音")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                MBProgressHUD.showInfo("需要等到服务端响应才可以转录，请稍候再试", inView: self.view)
            }
        }
    }
}


extension RoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.uidArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath) as! TranscriptResultCell
        let uid = uidArray[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        cell.timeLabel.text = startDate != nil ? formatter.string(from: startDate!) : "--:--:--"
        cell.nicknameLabel.text = "user\(uid)"
        cell.headImgView.image = UIImage(named: "room_cover_\(uid % 4)")
        cell.resultLabel.attributedText = currentAttriText
        
        return cell
    }
    
}

