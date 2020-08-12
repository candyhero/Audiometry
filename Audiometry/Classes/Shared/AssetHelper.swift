//
//  AssetHelper.swift
//  Audiometry
//
//  Created by Xavier Chan on 12/8/20.
//  Copyright © 2020 TriCountyProject. All rights reserved.
//

import UIKit

func getIcon(frequency: Int, role: PatientRole) -> UIImage? {
    if let dir = getIconDirectory(role: role) {
        let imagePath = "\(dir)/\(frequency)Hz"
        return UIImage(named: imagePath)?.withRenderingMode(.alwaysOriginal)
    }
    return nil
}

func getNoSoundIcon(role: PatientRole) -> UIImage? {
    if let dir = getIconDirectory(role: role) {
        let imagePath = "\(dir)/no_sound"
        return UIImage(named: imagePath)?.withRenderingMode(.alwaysOriginal)
    }
    return nil
}

func getIconDirectory(role: PatientRole) -> String? {
    switch role {
    case .Adult:
        return SHAPE_ICON_PATH
    case .Children:
        return ANIMAL_ICON_PATH
    default:
        return nil
    }
}

