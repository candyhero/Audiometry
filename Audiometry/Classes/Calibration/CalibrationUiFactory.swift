
import Foundation
import UIKit

class CalibrationSettingUiFactory {
    static let shared = CalibrationSettingUiFactory()
    
    func getElement(frequency: Int) -> CalibrationSettingValueUi{
        return CalibrationSettingValueUi(frequency)
    }
}

class CalibrationSettingValueUi {
    var expectedLevelTextField = UITextField()
    var presentationLevelTextField = UITextField()
    var leftMeasuredLevelTextField = UITextField()
    var rightMeasuredLevelTextField = UITextField()
    
    var frequency: Int!
    var frequencyLabel = UILabel()
    var playButton = UIButton(type:.system)
    
    init(_ frequency: Int) {
        self.frequency = frequency
        
        frequencyLabel.text = String(frequency)+" Hz"
        frequencyLabel.textAlignment = .center
        
        playButton.tag = frequency
        playButton.bounds = CGRect(x:0, y:0, width:300, height:300)
        playButton.setTitle("Off", for: .normal)
        playButton.setTitleColor(UIColor.white, for: .normal)
        playButton.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        playButton.backgroundColor = UIColor.gray
        
        let textfields = [
            expectedLevelTextField,
            presentationLevelTextField,
            leftMeasuredLevelTextField,
            rightMeasuredLevelTextField
        ]
        
        _ = textfields.map {
            $0.borderStyle = .roundedRect
            $0.textAlignment = .center
            $0.keyboardType = .asciiCapableNumberPad
        }
    }
    
    func loadValues(from values: CalibrationSettingValues) {
        self.expectedLevelTextField.text = String(values.expectedLevel)
        self.presentationLevelTextField.text = String(values.presentationLevel)
        self.leftMeasuredLevelTextField.text = String(values.leftMeasuredLevel)
        self.rightMeasuredLevelTextField.text = String(values.rightMeasuredLevel)
    }
    
    func clearAllValues() {
        self.expectedLevelTextField.text = ""
        self.presentationLevelTextField.text = ""
        self.leftMeasuredLevelTextField.text = ""
        self.rightMeasuredLevelTextField.text = ""
    }
    
    func clearMeasuredLevelValues() {
        self.leftMeasuredLevelTextField.text = ""
        self.rightMeasuredLevelTextField.text = ""
    }
}
