
import Foundation
import UIKit

class CalibrationSettingValuesUiFactory {
    static let shared = CalibrationSettingValuesUiFactory()
    
    func getElement(frequency: Int) -> CalibrationSettingValuesUi{
        return CalibrationSettingValuesUi(frequency)
    }
}

struct CalibrationSettingValuesRequest {
    var frequency: Int!
    var expectedLevel: Double!
    var presentationLevel: Double!
    var leftMeasuredLevel: Double!
    var rightMeasuredLevel: Double!
    
    var leftFinalPresentationLevel: Double! {
        get {
            return presentationLevel + expectedLevel - leftMeasuredLevel
        }
    }
    
    var rightFinalPresentationLevel: Double! {
        get {
            return presentationLevel + expectedLevel - rightMeasuredLevel
        }
    }
}

class CalibrationSettingValuesUi {
    var expectedLevelTextField = UITextField()
    var presentationLevelTextField = UITextField()
    var leftMeasuredLevelTextField = UITextField()
    var rightMeasuredLevelTextField = UITextField()
    
    var frequency: Int!
    var frequencyLabel = UILabel()
    var playButton = UIButton(type:.system)
    
    var request: CalibrationSettingValuesRequest {
        get {
            return CalibrationSettingValuesRequest(
                frequency: self.frequency,
                expectedLevel: Double(expectedLevelTextField.text!),
                presentationLevel: Double(presentationLevelTextField.text!),
                leftMeasuredLevel: Double(leftMeasuredLevelTextField.text!),
                rightMeasuredLevel: Double(rightMeasuredLevelTextField.text!)
            )
        }
    }
    
    
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
