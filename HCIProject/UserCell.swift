//
//  UserCell.swift
//  HCIProject
//
//  Created by AB Brooks on 11/12/18.
//  Copyright © 2018 AB Brooks. All rights reserved.
//

import Foundation
import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var checkButton: UIButton?
    @IBOutlet weak var userLabel: UILabel?
    @IBOutlet weak var editButton: UIButton?
    @IBOutlet weak var eyeButton: UIButton?
    
    var userSelected = false
    var i = 0
    
    override func awakeFromNib() {
        checkButton?.addTarget(self, action: #selector(toggleUserAccess), for: .touchUpInside)
        eyeButton?.addTarget(self, action: #selector(clickEye), for: .touchUpInside)
        editButton?.addTarget(self, action: #selector(clickEdit), for: .touchUpInside)
    }
    
    @objc func toggleUserAccess(){
        if self.userSelected{
            self.eyeButton?.isUserInteractionEnabled = false
            self.editButton?.isUserInteractionEnabled = false
            self.checkButton?.setImage(UIImage(named: "uncheckIcon"), for: .normal)
            self.editButton?.alpha = 0.0
            self.eyeButton?.alpha = 0.3
        }else{
            self.eyeButton?.isUserInteractionEnabled = true
            self.checkButton?.setImage(UIImage(named: "checkedIcon"), for: .normal)
            self.eyeButton?.alpha = 1.0
        }
        self.userSelected = !self.userSelected
    }
    
    @objc func clickEye(){
        self.eyeButton?.isUserInteractionEnabled = false
        self.editButton?.isUserInteractionEnabled = true
        self.eyeButton?.alpha = 0.0
        self.editButton?.alpha = 1.0
    }
    
    @objc func clickEdit(){
        self.eyeButton?.isUserInteractionEnabled = true
        self.editButton?.isUserInteractionEnabled = false
        self.eyeButton?.alpha = 1.0
        self.editButton?.alpha = 0.0
    }
}
