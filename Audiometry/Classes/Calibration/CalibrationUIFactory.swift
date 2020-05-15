
import Foundation
import UIKit

class CalibrationSettingUiFactory {
    static let shared = CalibrationSettingUiFactory()
    
    func getElement(frequency: Int) -> CalibrationSettingUi{
        return CalibrationSettingUi(frequency)
    }
}

class CalibrationSettingUi {
    var expectedLvTextField = UITextField()
    var presentationLvTextField = UITextField()
    var leftMeasuredLvTextField = UITextField()
    var rightMeasuredLvTextField = UITextField()
    
    var frequencyLabel = UILabel()
    var playButton = UIButton(type:.system)
    
    init(_ frequency: Int) {
        frequencyLabel.text = String(frequency)+" Hz"
        frequencyLabel.textAlignment = .center
        
        playButton.tag = frequency
        playButton.bounds = CGRect(x:0, y:0, width:300, height:300)
        playButton.setTitle("Off", for: .normal)
        playButton.setTitleColor(UIColor.white, for: .normal)
        playButton.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        playButton.backgroundColor = UIColor.gray
        
        let textfields = [expectedLvTextField, presentationLvTextField,
                          leftMeasuredLvTextField, rightMeasuredLvTextField]
        _ = textfields.map {
            $0.borderStyle = .roundedRect
            $0.textAlignment = .center
            $0.keyboardType = .asciiCapableNumberPad
        }
    }
        
    func extractValuesInto(_ values: CalibrationSettingValues) {
//        values.expectedLv = Double(self.tfExpectedLv.text!) ?? 0.0
//        values.presentationLv = Double(self.tfPresentationLv.text!) ?? 0.0
//        values.measuredLv_L = Double(self.tfMeasuredLv_L.text!) ?? 0.0
//        values.measuredLv_R = Double(self.tfMeasuredLv_R.text!) ?? 0.0
    }
    
    func updateDisplayValues(_ values: CalibrationSettingValues) {
//        self.tfExpectedLv.text = String(values.expectedLv)
//        self.tfPresentationLv.text = String(values.presentationLv)
//        self.tfMeasuredLv_L.text = String(values.measuredLv_L)
//        self.tfMeasuredLv_R.text = String(values.measuredLv_R)
    }
}
