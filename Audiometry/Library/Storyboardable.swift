//
//  Storyboarded.swift
//  Audiometry
//
//  Created by Xavier Chan on 20/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

enum AppStoryboards : String {
    case Main = "Main"
    case AdultTest = "AdultTest"
    case ChildrenTest = "ChildrenTest"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

protocol Storyboardable {
    static var storyboardIdentifier: String { get }
    static func instantiate(_ sb: AppStoryboards) -> Self
}

extension Storyboardable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }
    
    static func instantiate(_ sb: AppStoryboards) -> Self {
        /// instantiate a view controller with that identifier, and force cast as the type that was requested
        let storyboard = sb.instance
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}

// MARK: helper methods
extension Storyboardable where Self: UIViewController  {
    func errorPrompt(errorMsg: String) {
        let alertCtrl = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertCtrl.addAction(cancelAction)

        self.present(alertCtrl, animated: true, completion: nil)
    }

    func alertPrompt(alertTitle: String, alertMsg: String, confirmFunction: @escaping () -> Void) {
        let alertCtrl = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in confirmFunction() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertCtrl.addAction(confirmAction)
        alertCtrl.addAction(cancelAction)

        self.present(alertCtrl, animated: true, completion: nil)
    }

    func inputPrompt(promptMsg: String, errorMsg: String, fieldMsg: String,
                     confirmFunction: @escaping (String) -> Void) {
        // Prompt for user to input setting name
        let alertCtrl = UIAlertController(title: "Save", message: promptMsg, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
            (_) in
            if let field = alertCtrl.textFields?[0] {
                if(field.text!.isEmpty) {
                    self.errorPrompt(errorMsg: errorMsg)
                } else {
                    confirmFunction(field.text!)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertCtrl.addTextField { (textField) in textField.placeholder = fieldMsg }
        alertCtrl.addAction(confirmAction)
        alertCtrl.addAction(cancelAction)

        self.present(alertCtrl, animated: true, completion: nil)
    }

    func pickerPrompt(confirmFunction: @escaping () -> Void) {

        let alertCtrl: UIAlertController! = UIAlertController(
                title: "Select a different setting",
                message: "\n\n\n\n\n\n\n\n\n",
                preferredStyle: .alert)

        let picker = UIPickerView(frame: CGRect(x: 0, y: 50, width: 260, height: 160))
        picker.delegate = self as? UIPickerViewDelegate
        picker.dataSource = self as? UIPickerViewDataSource
        alertCtrl.view.addSubview(picker)

        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in confirmFunction() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertCtrl.addAction(confirmAction)
        alertCtrl.addAction(cancelAction)

        self.present(alertCtrl, animated: true, completion: nil)
    }
}
