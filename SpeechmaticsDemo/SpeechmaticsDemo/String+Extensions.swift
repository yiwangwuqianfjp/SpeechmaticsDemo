//
//  String.swift
//  SpeechmaticsDemo
//
//  Created by FanPengpeng on 2023/4/20.
//

import UIKit

extension String {
    func jsonObject() -> [String: Any]?{
        if let jsonData = self.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any]
                return json
            } catch {
                print("Error: \(error)")
            }
        }
        return nil
    }
}
