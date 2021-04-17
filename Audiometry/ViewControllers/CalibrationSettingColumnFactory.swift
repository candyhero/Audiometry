
import Foundation
import UIKit

struct CalibrationSettingColumn {
    var lbFreq: UILabel
    var pbPlay: UIButton
    var tfExpectedLv: UITextField
    var tfPresentationLv: UITextField
    var tfMeasuredLv_L: UITextField
    var tfMeasuredLv_R: UITextField
    
    init(freq: Int) {
        lbFreq = CalibrationSettingColumnFactory.newLabel(String(freq)+" Hz")
        pbPlay = CalibrationSettingColumnFactory.newButton(tag: freq)
        tfExpectedLv = CalibrationSettingColumnFactory.newTextField()
        tfPresentationLv = CalibrationSettingColumnFactory.newTextField()
        tfMeasuredLv_L = CalibrationSettingColumnFactory.newTextField()
        tfMeasuredLv_R = CalibrationSettingColumnFactory.newTextField()
    }
}

class CalibrationSettingColumnFactory {
    
    static func newLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        
        return label
    }
    
    static func newButton(tag: Int) -> UIButton {
        let button = UIButton(type:.system)
        button.tag = tag
        button.bounds = CGRect(x:0, y:0, width:300, height:300)
        button.setTitle("Off", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0,
                                          bottom: 5.0, right: 10.0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.gray
        
        return button
    }
    
    static func newTextField() -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.keyboardType = .asciiCapableNumberPad
        
        return textField
    }
}
