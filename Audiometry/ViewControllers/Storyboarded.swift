//
//  Storyboarded.swift
//  Audiometry
//
//  Created by Xavier Chan on 20/1/20.
//  Copyright © 2020 TriCounty. All rights reserved.
//

import UIKit

protocol Storyboarded {
    static func instantiate(_ sb: AppStoryboards) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(_ sb: AppStoryboards) -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)

        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]

        // load our storyboard
        let storyboard = sb.instance

        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}

enum AppStoryboards : String {
    case Main = "Main"
    case AdultTest = "AdultTest"
    case ChildrenTest = "ChildrenTest"

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
}