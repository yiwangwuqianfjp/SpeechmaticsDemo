//
//  TranscriptResultCell.swift
//  SpeechmaticsDemo
//
//  Created by FanPengpeng on 2023/4/20.
//

import UIKit

class TranscriptResultCell: UITableViewCell {

    @IBOutlet weak var headImgView: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    

}
