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
