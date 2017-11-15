//
//  MenuViewController.swift
//  Audiometry
//
//  Created by Xavier Chan on 7/27/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import UIKit
import Charts

class ThresholdViewController: UIViewController {
    private var array_freqSeq: [Int]!
    private var currentFreqInSeq: Int = 0
    private var dict_thresholdDB: [String: Double]!
    private var dict_result: [String: [Double]]!
    
    @IBOutlet weak var lbThreshold: UILabel!
    @IBOutlet weak var lbFreq: UILabel!
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var pbPrevFreq: UIButton!
    @IBOutlet weak var pbNextFreq: UIButton!
    
    @IBAction func loadPrevFreq(_ sender: UIButton) {
        if(currentFreqInSeq > 0)
        {
            currentFreqInSeq -= 1
            updateGraph(ARRAY_FREQ[array_freqSeq[currentFreqInSeq]])
        }
    }
    
    @IBAction func loadNextFreq(_ sender: UIButton) {
        if(currentFreqInSeq < array_freqSeq.count - 1)
        {
            currentFreqInSeq += 1
            updateGraph(ARRAY_FREQ[array_freqSeq[currentFreqInSeq]])
        }
    }
    
    func updateGraph(_ freq: Double!){
        let thresholdDB: Double! = dict_thresholdDB[String(freq)]
        lbThreshold.text = String(thresholdDB)
        lbFreq.text = String(freq)
        
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
        let array_result: [Double]! = dict_result[String(freq)] ?? nil
        
        print(array_result)
        
        //here is the for loop
        for i in 0..<array_result.count {
            let temp_value = ChartDataEntry(x: Double(i), y: array_result[i]) // here we set the X and Y status in a data chart entry
            lineChartEntry.append(temp_value) // here we add it to the data set
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        
        
        chartView.data = data //finally - it adds the chart data to the chart and causes an update
        chartView.chartDescription?.text = "My awesome chart" // Here we set the description for the graph
    }

    private func loadResult() {
        
        array_freqSeq = UserDefaults.standard.array(
            forKey: "array_freqSeq") as! [Int]
        dict_thresholdDB = UserDefaults.standard.dictionary(
            forKey: "dict_thresholdDB") as! [String: Double]
        dict_result = UserDefaults.standard.dictionary(
            forKey: "dict_result") as! [String: [Double]]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadResult()
        updateGraph(ARRAY_FREQ[array_freqSeq[currentFreqInSeq]])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
