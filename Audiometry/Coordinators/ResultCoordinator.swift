//
// Created by Xavier Chan on 8/3/20.
// Copyright (c) 2020 TriCounty. All rights reserved.
//

import Foundation

class ResultCoordinator: Coordinator {
    // MARK:
    var _navController = AppDelegate.navController
    var _patientProfileRepo = PatientProfileRepo.repo

    private var _globalSetting: GlobalSetting!
    private var _patients: [PatientProfile] = []

    func start() {
        // fetch all PatientProfiles
        do {
            _patients = try _patientProfileRepo.fetchAllSorted()
        } catch let error as NSError{
            print("Could not fetch patient profiles")
            print("\(error), \(error.userInfo)")
        }
    }

    func back() {
        _navController.popToRootViewController(animated: true)
    }

    func getAllPatientProfiles() -> [PatientProfile]{
        return _patients
    }
    
    func getPatientProfile(_ index: Int) -> PatientProfile {
        return _patients[index]
    }
    
    func getPatientProfileValues(_ index: Int) -> [PatientProfileValues] {
        return getSortedValues(_patients[index])
    }
    
    func deletePatientProfile(_ index: Int) -> Bool {
        do {
            try _patientProfileRepo.delete(_patients[index])
            _patients.remove(at: index)
            return true
        }
        catch {
            return false
        }
    }
    
    func deleteAllPatientProfiles() -> Bool {
        do {
            for patient in _patients {
                try _patientProfileRepo.delete(patient)
            }
            return true
        }
        catch {
            return false
        }
    }

    func exportAllPatients() -> URL! {
        do {
            let csvText = Audiometry.exportAllPatientsInRows(_patients)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"

            let fileName = "AudiometryPatientExport_\(dateFormatter.string(from: Date())).csv"
            print("FileName: \(fileName)")

            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            return path
        } catch {
            print("Failed to create file")
            print("\(error)")
            return nil
        }
    }
}
