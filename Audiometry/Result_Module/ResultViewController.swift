//
//  MenuViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    private let realm = try! Realm()
    private var mainSetting: MainSetting? = nil
    private var array_freqSeq: List<Int>? = nil
    
    private var patientSectionRows = [Int]() // section, row
    
    @IBOutlet weak var lbThreshold: UILabel!
    @IBOutlet weak var lbFreq: UILabel!
    
    @IBOutlet weak var tbPatients: UITableView!
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var pbPrevFreq: UIButton!
    @IBOutlet weak var pbNextFreq: UIButton!
    
    @IBAction func deleteCurrentPatient(_ sender: UIButton) {
        
        let indexPath = tbPatients.indexPathForSelectedRow
        
        let currentPatient = mainSetting?.array_patientProfiles[indexPath!.section]
        
        let alertMsg = "Are you sure to delete \"" + (currentPatient?.name)! + "\" ?"
        
        alertPrompt(alertTitle: "Delete patient profile",
                    alertMsg: alertMsg,
                    confirmFunction: deletePatient,
                    uiCtrl: self)
    }
    
    func deletePatient(){
        let indexPath = tbPatients.indexPathForSelectedRow
        self.patientSectionRows.remove(at: indexPath!.section)
        
        try! realm.write {
            mainSetting?.array_patientProfiles.remove(at: indexPath!.section)
        }
        
        self.tbPatients.deleteSections(IndexSet([indexPath!.section]), with: .fade)
    }
    
    // Header section
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return (mainSetting?.array_patientProfiles.count)!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        
        let patientName = mainSetting?.array_patientProfiles[section].name
        
        button.setTitle(patientName, for: .normal)
        button.tag = section
        
        return button
    }
    
    @objc func handleExpandClose(button: UIButton!){
        
        let currentPatient = mainSetting?.array_patientProfiles[button.tag]
        
        var array_indexPath = [IndexPath]()
        
        for freqIndex in (currentPatient?.array_testResults.indices)! {
            let indexPath = IndexPath(row: freqIndex, section: button.tag)
            array_indexPath.append(indexPath)
        }
        
        if(patientSectionRows[button.tag] > 0){
            
            patientSectionRows[button.tag] = 0
            tbPatients.deleteRows(at: array_indexPath, with: .fade)
        }
        else {
            patientSectionRows[button.tag] = (currentPatient?.array_testResults.count)!
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
        let currentPatient = mainSetting?.array_patientProfiles[indexPath.section]
        let currentTestResult = currentPatient?.array_testResults[indexPath.row]
        
        // Configure table cell style
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let label_L = ((currentTestResult?.thresholdDB_L)! >= 0) ?
            String(describing: (currentTestResult?.thresholdDB_L)!): "NR"
        
        let label_R = ((currentTestResult?.thresholdDB_R)! >= 0) ?
            String(describing: (currentTestResult?.thresholdDB_R)!): "NR"
        
        cell.textLabel?.text = String(describing: (currentTestResult?.freq)!)
            + " Hz; Threshold (dB): " + label_L + " / " + label_R
        
        cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        cell.textLabel?.textAlignment = .center;
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentPatient = mainSetting?.array_patientProfiles[indexPath.section]
        let currentTestResult = currentPatient?.array_testResults[indexPath.row]
        
        updateGraph(currentTestResult!)
    }
    
    // Plot functions
    func updateGraph(_ testResult: TestResult){
        
        // Load dB and result lists
        lbFreq.text = String(testResult.freq)
        
        var lineChartEntry_L  = [ChartDataEntry]()
        var lineChartEntry_R  = [ChartDataEntry]()
        
        //here is the for loop
        for i in 0..<(testResult.array_trackingDB_L.count) {
            let temp_value = ChartDataEntry(x: Double(i),
                                            y: testResult.array_trackingDB_L[i])
            lineChartEntry_L.append(temp_value)
        }
        
        for i in 0..<(testResult.array_trackingDB_R.count) {
            let temp_value = ChartDataEntry(x: Double(i),
                                            y: testResult.array_trackingDB_R[i])
            lineChartEntry_R.append(temp_value) // here we add it to the data set
        }
        
        let line_L = LineChartDataSet(values: lineChartEntry_L,
                                     label: "Presentation Level in dB")
        line_L.colors = [NSUIColor.red] //Sets the colour to blue
        
        let line_R = LineChartDataSet(values: lineChartEntry_R,
                                     label: "Presentation Level in dB")
        line_R.colors = [NSUIColor.blue]
        
        // Set y-axis
        let leftAxis = chartView.getAxis(YAxis.AxisDependency.left)
        let rightAxis = chartView.getAxis(YAxis.AxisDependency.right)
        
        let max_L = testResult.array_trackingDB_L.max() ?? _DB_SYSTEM_MAX
        let max_R = testResult.array_trackingDB_R.max() ?? _DB_SYSTEM_MAX
        let min_L = testResult.array_trackingDB_L.min() ?? _DB_SYSTEM_MIN
        let min_R = testResult.array_trackingDB_R.min() ?? _DB_SYSTEM_MIN
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainSetting = realm.objects(MainSetting.self).first
        
        // Load result
        let mostCurrentPatient = mainSetting?.array_patientProfiles.first
        
        for patientProfile in (mainSetting?.array_patientProfiles)! {
            patientSectionRows.append(0)
        }
        
//        print(mostCurrentPatient!.array_testResults.count)
        
        patientSectionRows[0] = (mostCurrentPatient!.array_testResults.count)
        updateGraph((mostCurrentPatient?.array_testResults.first)!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
