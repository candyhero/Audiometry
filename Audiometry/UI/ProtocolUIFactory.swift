//
//  ProtocolUIFactory.swift
//  Audiometry
//
//  Created by Xavier Chan on 15/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

class ProtocolUIFactory: NSObject{

    static func GetNewFrequencyButton(frequency: Int) -> UIButton{
        let button = UIButton(type:.system)
        button.setTitle(String(frequency) + " Hz", for: .normal)
        button.tag = frequency
        button.bounds = CGRect(x:0, y:0, width:300, height:300)
        button.backgroundColor = UIColor.gray
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        return button
    }
    
}
