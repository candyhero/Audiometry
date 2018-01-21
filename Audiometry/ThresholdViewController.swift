//
//  MenuViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import Charts

class ThresholdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    private var patientProfiles: [String]!
    private var patientThresholds = [String: [String: Double]]()
    private var patientFreqSeq = [String: [Int]]()
    
    private var patientSectionRows = [Int]() // section, row
    
    @IBOutlet weak var lbThreshold: UILabel!
    @IBOutlet weak var lbFreq: UILabel!
    
    @IBOutlet weak var tbPatients: UITableView!
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var pbPrevFreq: UIButton!
    @IBOutlet weak var pbNextFreq: UIButton!
    
    @IBAction func deleteCurrentPatient(_ sender: UIButton) {
        
        let indexPath = tbPatients.indexPathForSelectedRow
        
        let patientName = patientProfiles[indexPath!.section]
        
        let alertMessage = "Are you sure to delete \"" + patientName + "\" ?"
        
        // Prompt for user to input setting name
        let alertController = UIAlertController(
            title: "Delete Patient Profile",
            message: alertMessage, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
            (_) in
            
            UserDefaults.standard.removeObject(forKey: patientName)
            UserDefaults.standard.removeObject(forKey: "db" + patientName)
            UserDefaults.standard.removeObject(forKey: "freqSeq" + patientName)
            
            self.patientSectionRows.remove(at: indexPath!.section)
            self.patientProfiles.remove(at: indexPath!.section)
            self.patientThresholds.removeValue(forKey: patientName)
            self.patientFreqSeq.removeValue(forKey: patientName)
            
            let indexSet = IndexSet([indexPath!.section])
            self.tbPatients.deleteSections(indexSet, with: .fade)
            
            UserDefaults.standard.set(self.patientProfiles, forKey: "patientProfiles")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (_) in }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // Header section
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return patientProfiles.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        
        button.setTitle(patientProfiles[section], for: .normal)
        button.tag = section
        
        return button
    }
    
    @objc func handleExpandClose(button: UIButton!){
//        print("Expanding & Closing", button.tag)
        
        let patientIndex = button.tag
        let patientName = patientProfiles[patientIndex]
        
        var array_indexPath = [IndexPath]()
        
        for freqIndex in patientFreqSeq[patientName]!.indices {
            let indexPath = IndexPath(row: freqIndex, section: button.tag)
            array_indexPath.append(indexPath)
        }
        
        if(patientSectionRows[button.tag] > 0){
            
            patientSectionRows[button.tag] = 0
            
            tbPatients.deleteRows(at: array_indexPath, with: .fade)
        }
        else {
            
            patientSectionRows[button.tag] = patientFreqSeq[patientName]!.count
            
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
        let patientName: String! = patientProfiles[indexPath.section]
        
        let freq = ARRAY_FREQ[patientFreqSeq[patientName]![indexPath.row]]
        let thresholdDB: Double! = patientThresholds[patientName]![String(freq)]
        
        // Configure table cell style
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = String(freq) + " Hz; Threshold (dB): " + String(thresholdDB)
        cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        cell.textLabel?.textAlignment = .center;
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let patientName: String! = patientProfiles[indexPath.section]
        
        let freq = ARRAY_FREQ[patientFreqSeq[patientName]![indexPath.row]]
        
        updateGraph(patientName, freq)
    }
    
    // Plot functions
    func updateGraph(_ patientName: String!, _ freq: Double!){
        
        // Load dB and result lists
        
        let dict_freqSeqArrays = UserDefaults.standard.dictionary(
            forKey: patientName!) as! [String: [Double]]
        
        lbFreq.text = String(freq)
        
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
        let array_freqSeqDB: [Double]! = dict_freqSeqArrays[String(freq)] ?? nil
        
        //here is the for loop
        for i in 0..<array_freqSeqDB.count {
            let temp_value = ChartDataEntry(x: Double(i), y: array_freqSeqDB[i]) // here we set the X and Y status in a data chart entry
            lineChartEntry.append(temp_value) // here we add it to the data set
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        
        chartView.data = data //finally - it adds the chart data to the chart and causes an update
        //chartView.chartDescription?.text = "My awesome chart" // Here we set the description for the graph
    }

    private func loadResult() {
        
        patientProfiles = UserDefaults.standard.array(forKey: "patientProfiles") as? [String]
        
        // Retrieve array of freq
        for patientName in patientProfiles {
            
            let dict_thresholdDB = UserDefaults.standard.dictionary(
                forKey: "db" + patientName) as! [String: Double]
            
            let array_freqSeq = UserDefaults.standard.array(
                    forKey: "freqSeq" + patientName) as! [Int]
            
            patientThresholds[patientName] = dict_thresholdDB
            patientFreqSeq[patientName] = array_freqSeq
            
            patientSectionRows.append(0)
        }
        
        patientSectionRows[0] = patientFreqSeq[patientProfiles.first!]!.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadResult()
        
        updateGraph(patientProfiles.first!,
                ARRAY_FREQ[patientFreqSeq[patientProfiles.first!]![0]])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
