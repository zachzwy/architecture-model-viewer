//
//  ModelCell.swift
//  HCIProject
//
//  Created by AB Brooks on 11/8/18.
//  Copyright © 2018 AB Brooks. All rights reserved.
//

import Foundation
import UIKit

class ModelCell: UICollectionViewCell {
    @IBOutlet weak var modelImageView: UIImageView?
    @IBOutlet weak var modelTitle: UILabel?
    @IBOutlet weak var modelDate: UILabel?
    @IBOutlet weak var checkImageView: UIImageView?

    var editting = false
    
    override var isSelected: Bool {
        didSet {
            if(editting){
                checkImageView?.alpha = isSelected ? 1.0 : 0.0
            }
        }
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView?.alpha = 0.0
        isSelected = false
    }
    
}
