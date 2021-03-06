//
//  TextViewRoundConner.swift
//  TourGuideTracking
//
//  Created by Duc Nguyen on 11/11/16.
//  Copyright © 2016 Quoc Huy Ngo. All rights reserved.
//

import UIKit

class TextViewRoundConner: UITextView {

    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor : UIColor?{
        didSet{
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var cornerRadius : CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
        
    }

}
