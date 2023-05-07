//
//  Utils.swift
//  MetaChatDemo
//
//  Created by FanPengpeng on 2022/8/3.
//

import Foundation
import MBProgressHUD

func DLog(_ message: String..., file: String = #file, function: String = #function, lineNumber: Int = #line) {
    #if DEBUG
    print("MC ---[\(Date())] [\(function)] [\(lineNumber)] \(message) -- MC")
    #endif
}

extension MBProgressHUD {
    static func showError(_ err: String, inView: UIView) {
        /*
        let hud = MBProgressHUD(view: inView)
        hud.mode = .text
        inView.addSubview(hud)
        hud.label.text = err
        hud.removeFromSuperViewOnHide = true
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: 2)
*/
    }
    
    static func showInfo(_ info: String, inView: UIView) {
        /*
        let hud = MBProgressHUD(view: inView)
        hud.mode = .text
        inView.addSubview(hud)
        hud.label.text = info
        hud.removeFromSuperViewOnHide = true
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: 2)
         */
    }
    
}
