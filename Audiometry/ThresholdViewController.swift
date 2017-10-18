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

    var array_result: [Double]!
    
    @IBOutlet weak var lbThreshold: UILabel!
    @IBOutlet weak var lbResult: UILabel!
    
    @IBOutlet weak var chartView: LineChartView!
    
    func updateGraph(){
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let thresholdDB: Double! = UserDefaults.standard.double(forKey: "thresholdValue")
        
        array_result = UserDefaults.standard.array(forKey: "result") as! [Double]
        
        lbThreshold.text = "Threshold DB: " + String(thresholdDB)
        
        updateGraph()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
