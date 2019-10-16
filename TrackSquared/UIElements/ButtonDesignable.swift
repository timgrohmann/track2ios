//
//  ButtonDesignable.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 14.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

@IBDesignable
class ButtonDesignable: UIButton {

    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }
        set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }

    @IBInspectable var enabledColor: UIColor? {
        didSet {
            if self.isEnabled {
                self.backgroundColor = enabledColor
            }
        }
    }
    @IBInspectable var disabledColor: UIColor? {
        didSet {
            if !self.isEnabled {
                self.backgroundColor = disabledColor
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isEnabled {
                    self.backgroundColor = self.enabledColor
                } else {
                    self.backgroundColor = self.disabledColor
                }
            }

        }
    }

}
