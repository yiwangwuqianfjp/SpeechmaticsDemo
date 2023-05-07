//
//  AppConfigs.swift
//  SpeechmaticsDemo
//
//  Created by FanPengpeng on 2023/4/21.
//

import UIKit


class AppConfigs: NSObject {
    static let shared = AppConfigs()
    
    var delay: Double?
    
    private override init() {}
}
