//
//  RoundButton.swift
//  Parkly
//
//  Created by Claudia Maciel on 4/12/21.
//

import UIKit

class RoundButton: UIButton {

    override func awakeFromNib() {
        // MARK: Cornder Radius
        self.layer.cornerRadius = self.frame.height / 2
        
        // MARK: Shadow
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
        
    }

}
