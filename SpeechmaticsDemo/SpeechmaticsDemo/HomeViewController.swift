//
//  HomeViewController.swift
//  SpeechmaticsDemo
//
//  Created by FanPengpeng on 2023/4/20.
//

import UIKit

private let kJoinSegueID = "joinChannel"

@available(iOS 16.0, *)
class HomeViewController: UIViewController {

    @IBOutlet weak var channelTF: UITextField!
    @IBOutlet weak var uidTF: UITextField!
    @IBOutlet weak var nicknameTF: UITextField!
    @IBOutlet weak var langBarButtonItem: UIBarButtonItem!
    
    var lang: String = "cmn"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    @IBAction func videoStateSwitchChanged(_ sender: Any) {
        
    }
    
    
    @IBAction func didClickLangBarButtonItem(_ sender: Any) {
        guard let path = Bundle.main.path(forResource: "SupportedLanguages", ofType: "plist") else { return  }
        let url = NSURL(fileURLWithPath: path) as URL
        guard let root: [[String: String]] = try? NSArray(contentsOf: url, error: ()) as? [[String : String]] else { return }
        let cancelItem = UIAlertAction(title: "取消", style: .cancel)
        let vc = UIAlertController(title: "选择语言", message: nil, preferredStyle: .actionSheet)
        root.forEach { item in
            guard let name = item["name"], let id = item["id"] else {return}
            let action = UIAlertAction(title: name, style: .default) { action in
                self.langBarButtonItem.title = name
                self.lang = id
            }
            vc.addAction(action)
        }
        vc.addAction(cancelItem)
        present(vc, animated: true)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == kJoinSegueID {
            guard let channel = channelTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), channel.count > 0 else {
                print("频道名称不能为空")
                return false
            }
            guard let uid = uidTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), uid.count > 0 else {
                print("频道名称不能为空")
                return false
            }
        }
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kJoinSegueID {
            guard let channelName = channelTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            guard let uid = uidTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            let nickname = nicknameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let roomVC = segue.destination as! RoomViewController
            roomVC.channelName = channelName
            roomVC.uid = uid
            roomVC.name = nickname ?? "User\(uid)"
            roomVC.lang = lang
        }
    }


}
