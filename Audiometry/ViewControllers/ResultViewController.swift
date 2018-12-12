//
//  MenuViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
//------------------------------------------------------------------------------
// Local Variables
//------------------------------------------------------------------------------
    private let managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var globalSetting: GlobalSetting!
    private var currentPatient: PatientProfile!
    
    private var array_patients: [PatientProfile] = []
    private var array_freqSeq: [Int] = []
    
    private var patientSectionRows: [Int] = [] // section, row
    
//------------------------------------------------------------------------------
// UI Components
//------------------------------------------------------------------------------
    @IBOutlet weak var lbThreshold: UILabel!
    @IBOutlet weak var lbFreq: UILabel!
    
    @IBOutlet weak var tbPatients: UITableView!
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var pbPrevFreq: UIButton!
    @IBOutlet weak var pbNextFreq: UIButton!
    
    @IBAction func deleteCurrentPatient(_ sender: UIButton) {
        let alertMsg = "Are you sure to delete \"" + (currentPatient?.name)! + "\" ?"
        
        alertPrompt(alertTitle: "Delete patient profile",
                    alertMsg: alertMsg,
                    confirmFunction: deletePatient,
                    uiCtrl: self)
    }
    
//------------------------------------------------------------------------------
// TableView Functions
//------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return array_patients.count
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let button = UIButton(type: .system)
        
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self,
                         action: #selector(handleExpandClose),
                         for: .touchUpInside)
        
        let patient = array_patients[section]
        let tag = (patient.isAdult) ? "(Adult)":"(Child)"
        let title = (patient.name ?? "NAME_ERROR") + tag
        button.setTitle(title, for: .normal)
        button.tag = section
        
        return button
    }
    
    @objc func handleExpandClose(button: UIButton!){
        
        currentPatient = array_patients[button.tag]
        let values = getSortedValues(currentPatient)
        var array_indexPath = [IndexPath]()
        
        for freqIndex in values.indices {
            let indexPath = IndexPath(row: freqIndex, section: button.tag)
            array_indexPath.append(indexPath)
        }
        
        if(patientSectionRows[button.tag] > 0){
            
            patientSectionRows[button.tag] = 0
            tbPatients.deleteRows(at: array_indexPath, with: .fade)
        }
        else {
            patientSectionRows[button.tag] = values.count
            tbPatients.insertRows(at: array_indexPath, with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    // Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientSectionRows[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve patient brief info
        currentPatient = array_patients[indexPath.section]
        let values = getSortedValues(currentPatient)[indexPath.row]
        
        // Configure table cell style
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let label_L = (values.threshold_L >= 0) ?
            String(values.threshold_L): "NR"
        
        let label_R = (values.threshold_R >= 0) ?
            String(values.threshold_R): "NR"
        
        cell.textLabel?.text = String(values.frequency) +
            " Hz; Threshold (dB): " + label_L + " / " + label_R
        
        cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        cell.textLabel?.textAlignment = .center;
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentPatient = array_patients[indexPath.section]
        let values = getSortedValues(currentPatient)
        updateGraph(values[indexPath.row])
    }
    
//------------------------------------------------------------------------------
// CoreData functions
//------------------------------------------------------------------------------
    func getSortedValues(_ patient: PatientProfile) -> [PatientProfileValues]{
        let sortByFrequency = NSSortDescriptor(
            key: #keyPath(PatientProfileValues.frequency),
            ascending: true)
        let sortedValues = patient.values?.sortedArray(
            using: [sortByFrequency]) as! [PatientProfileValues]
        
        return sortedValues
    }
    
    func deletePatient(){
        let indexPath = tbPatients.indexPathForSelectedRow
        
        if(indexPath?.section == nil){
            return
        }
        
        let patient = array_patients[indexPath!.section]
        managedContext.delete(patient)
        array_patients.remove(at: indexPath!.section)
        
        patientSectionRows.remove(at: indexPath!.section)
        tbPatients.deleteSections(IndexSet([indexPath!.section]), with: .fade)
    }
    // Plot functions
    func updateGraph(_ values: PatientProfileValues){
        
        // Load dB and result lists
        lbFreq.text = String(values.frequency)
        
        var lineChartEntry_L  = [ChartDataEntry]()
        var lineChartEntry_R  = [ChartDataEntry]()
        
        var i = 0
        for db in values.results_L ?? [] {
            lineChartEntry_L.append(ChartDataEntry(x: Double(i), y: Double(db)))
            i+=1
        }
        
        i = 0
        for db in values.results_R ?? [] {
            lineChartEntry_R.append(ChartDataEntry(x: Double(i), y: Double(db)))
            i+=1
        }
        
        let line_L = LineChartDataSet(values: lineChartEntry_L,
                                     label: "Presentation Lv. (Left) in dB")
        let line_R = LineChartDataSet(values: lineChartEntry_R,
                                     label: "Presentation Lv. (Right) in dB")
        
        line_L.colors = [NSUIColor.blue] //Sets the colour to blue
        line_R.colors = [NSUIColor.red]
        
        // Set y-axis
        let leftAxis = chartView.getAxis(YAxis.AxisDependency.left)
        let rightAxis = chartView.getAxis(YAxis.AxisDependency.right)
        
        let max_L = (values.results_L ?? []).max() ?? _DB_SYSTEM_MAX
        let max_R = (values.results_R ?? []).max() ?? _DB_SYSTEM_MAX
        let min_L = (values.results_L ?? []).min() ?? _DB_SYSTEM_MIN
        let min_R = (values.results_R ?? []).min() ?? _DB_SYSTEM_MIN
        
        leftAxis.granularity =
            ((max(max_L!, max_R!) - min(min_L!, min_R!)) > 30) ? 10 : 5
        
        rightAxis.enabled = false
        rightAxis.drawGridLinesEnabled = false
        
        //
        let data = LineChartData()
        
        data.addDataSet(line_L) //Adds the line to the dataSet
        data.addDataSet(line_R)
        
        chartView.data = data
    }
    
    func initSettings(){
        // fetch global setting
        let settingRequest:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        settingRequest.fetchLimit = 1
        
        do {
            globalSetting = try managedContext.fetch(settingRequest).first
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
        
        // fetch all PatientProfiles
        let patientRequest:NSFetchRequest<PatientProfile> =
            PatientProfile.fetchRequest()
        let sortByTimestamp = NSSortDescriptor(
            key: #keyPath(PatientProfile.timestamp),
            ascending: true)
        patientRequest.sortDescriptors = [sortByTimestamp]
        
        do {
            array_patients = try managedContext.fetch(patientRequest)
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load result
        initSettings()
        let mostRecentPatient = array_patients.first!
        
        for patientProfile in array_patients {
            patientSectionRows.append(0)
        }
        
        let mostRecentValues = getSortedValues(mostRecentPatient)
        patientSectionRows[0] = mostRecentValues.count
        updateGraph(mostRecentValues.first!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
