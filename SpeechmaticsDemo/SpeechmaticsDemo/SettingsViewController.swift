//
//  SettingsViewController.swift
//  SpeechmaticsDemo
//
//  Created by FanPengpeng on 2023/4/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var delayTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AppConfigs.shared.delay != nil {
            delayTF.text = "\(AppConfigs.shared.delay!)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        AppConfigs.shared.delay = Double(delayTF.text ?? "")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        AppConfigs.shared.delay = Double(delayTF.text ?? "")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
