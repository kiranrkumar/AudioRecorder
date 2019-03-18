//
//  KiranButton.swift
//  DemoRecorder
//
//  Created by Kiran Kumar on 3/15/19.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit

class KiranButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set(newIsEnabled) {
            if newIsEnabled {
                self.setTitleColor(UIColor.black, for: .normal)
            }
            else {
                self.setTitleColor(UIColor.gray, for: .normal)
            }
            super.isEnabled = newIsEnabled
        }
        
    }
}
