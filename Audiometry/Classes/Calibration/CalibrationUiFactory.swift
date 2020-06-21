
import Foundation
import UIKit

class CalibrationSettingUIFactory {
    static let shared = CalibrationSettingUIFactory()
    
    func getElement(frequency: Int) -> CalibrationSettingValueUI{
        return CalibrationSettingValueUI(frequency)
    }
}

class CalibrationSettingValueUI {
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
        
    func extractValuesInto(values: CalibrationSettingValues) -> CalibrationSettingValues{
        values.expectedLevel = Double(self.expectedLevelTextField.text!) ?? 0.0
        values.presentationLevel = Double(self.presentationLevelTextField.text!) ?? 0.0
        values.leftMeasuredLevel = Double(self.leftMeasuredLevelTextField.text!) ?? 0.0
        values.rightMeasuredLevel = Double(self.rightMeasuredLevelTextField.text!) ?? 0.0
        return values
    }
    
    func loadValuesFrom(values: CalibrationSettingValues) {
        self.expectedLevelTextField.text = String(values.expectedLevel)
        self.presentationLevelTextField.text = String(values.presentationLevel)
        self.leftMeasuredLevelTextField.text = String(values.leftMeasuredLevel)
        self.rightMeasuredLevelTextField.text = String(values.rightMeasuredLevel)
    }
    
    func clearMeasuredLevelValues(){
        self.leftMeasuredLevelTextField.text = ""
        self.rightMeasuredLevelTextField.text = ""
    }
}
