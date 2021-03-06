
import UIKit
import Charts
import CoreData

class ResultViewController: UIViewController, Storyboarded, UITableViewDelegate, UITableViewDataSource  {
    // MARK:
    let coordinator = AppDelegate.resultCoordinator

    private var _currentPatientTag: Int = 0
    private var _patientRows: [UIButton] = []
    private var _patientSectionRows: [Int] = []

    // MARK:
    @IBOutlet weak var lbFreq: UILabel!
    
    @IBOutlet weak var tbPatients: UITableView!
    
    @IBOutlet weak var chartView_L: LineChartView!
    @IBOutlet weak var chartView_R: LineChartView!
    
    @IBOutlet weak var pbPrevFreq: UIButton!
    @IBOutlet weak var pbNextFreq: UIButton!
    @IBOutlet weak var pbDeleteCurrentPatient: UIButton!

    // MARK:

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load result
        let patientProfiles = coordinator.getAllPatientProfiles()
        _patientSectionRows = patientProfiles.map { _ in return 0 }
        _patientSectionRows[0] = coordinator.getPatientProfileValues(0).count
        _currentPatientTag = 0
    }

    @IBAction func back(_ sender: Any) {
        coordinator.back()
    }
    
    @IBAction func deleteCurrentPatient(_ sender: UIButton) {
        if(coordinator.getAllPatientProfiles().isEmpty) {
            return
        }
        let tag = self._currentPatientTag
        let patient = coordinator.getPatientProfile(tag)
        if let patientName = patient.name {
            alertPrompt(
                alertTitle: "Delete",
                alertMsg: "Are you sure to delete \(patientName)?",
                confirmFunction: delete
            )
        }
    }
    
    private func delete() {
        if !coordinator.deletePatientProfile(_currentPatientTag) {
            return
        }
        
        let indexSet = IndexSet(integer: _currentPatientTag)
        tbPatients.deleteSections(indexSet, with: .fade)
        
        if(tbPatients.numberOfSections == 0){
            coordinator.back()
        }
        
        _patientRows.remove(at: _currentPatientTag)
        _patientSectionRows.remove(at: _currentPatientTag)

        for (index, patientRow) in _patientRows.enumerated() {
            patientRow.tag = index
        }
        _currentPatientTag = 0
    }
    
    @IBAction func deleteAllPatient() {
        if(coordinator.getAllPatientProfiles().isEmpty) {
            return
        }
        alertPrompt(
            alertTitle: "Delete All",
            alertMsg: "Are you sure to delete all patient data?",
            confirmFunction: deleteAll
        )
    }
    
    private func deleteAll() {
        if !coordinator.deleteAllPatientProfiles() {
            return
        }
        coordinator.back()
    }
    
    @IBAction func exportAllPatients(_ sender: UIButton) {
        let csvPath = coordinator.exportAllPatients()
        let activityVC = UIActivityViewController(activityItems: [csvPath!], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)

        if let popOver = activityVC.popoverPresentationController {
            popOver.sourceView = self.view
        }
    }

    // Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return coordinator.getAllPatientProfiles().count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self,
                         action: #selector(handleExpandClose),
                         for: .touchUpInside)
        
        let patient = coordinator.getPatientProfile(section)
        let title = "[\(patient.group ?? "NO_GROUP")] \(patient.name ?? "NO_NAME")"
            + "\(patient.isAdult ? "(Adult)":"(Child)")"
            + "\(patient.isPractice ? "[Practice]" : "")"
        
        button.setTitle(title, for: .normal)
        button.tag = section
        
        _patientRows.append(button)
        return button
    }
    
    @objc func handleExpandClose(button: UIButton!) {
        let allValues = coordinator.getPatientProfileValues(button.tag)
        var array_indexPath = [IndexPath]()
        
        for freqIndex in allValues.indices {
            let indexPath = IndexPath(row: freqIndex, section: button.tag)
            array_indexPath.append(indexPath)
        }
        
        if(_patientSectionRows[button.tag] > 0) {
            _patientSectionRows[button.tag] = 0
            tbPatients.deleteRows(at: array_indexPath, with: .fade)
        }
        else {
            _patientSectionRows[button.tag] = allValues.count
            tbPatients.insertRows(at: array_indexPath, with: .fade)
        }
        _currentPatientTag = button.tag
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    // Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _patientSectionRows[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let values = coordinator.getPatientProfileValues(indexPath.section)[indexPath.row]

        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let label_L = (values.threshold_L >= 0) ? String(values.threshold_L): "NR"
        let label_R = (values.threshold_R >= 0) ? String(values.threshold_R): "NR"
        
        cell.textLabel?.text = "\(String(values.frequency)) Hz ; "
            + "dB Threshold: (L) \(label_L) (R) \(label_R) ; "
            + "Reliability:"
            + " (L) \(String(values.no_sound_correct_L))/\(String(values.no_sound_count_L))"
            + " (R) \(String(values.no_sound_correct_R))/\(String(values.no_sound_count_R))"
        
        cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        cell.textLabel?.textAlignment = .center;
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let values = coordinator.getPatientProfileValues(indexPath.section)[indexPath.row]
        updateGraph(values)
        _currentPatientTag = indexPath.section
    }
    
    // Plot functions
    func updateGraph(_ values: PatientProfileValues) {
        
        // Load dB and result lists
        let label_L = (values.threshold_L >= 0) ? String(values.threshold_L): "NR"
        let label_R = (values.threshold_R >= 0) ? String(values.threshold_R): "NR"
        
        lbFreq.text = "\(String(values.frequency)) Hz ; "
            + "dB Threshold: (L) \(label_L) (R) \(label_R) ; "
            + "Reliability:"
            + " (L) \(String(values.no_sound_correct_L))/\(String(values.no_sound_count_L))"
            + " (R) \(String(values.no_sound_correct_R))/\(String(values.no_sound_count_R))"
        
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
        
        let line_L = LineChartDataSet(entries: lineChartEntry_L, label: "Presentation Lv. (Left) in dB")
        let line_R = LineChartDataSet(entries: lineChartEntry_R, label: "Presentation Lv. (Right) in dB")
        
        line_L.colors=[NSUIColor.blue]
        line_R.colors=[NSUIColor.red]

        if(values.responses_L?.count ?? 0 > 0) { line_L.circleColors = [] }
        for response in values.responses_L ?? [] {
            if(response > 0) {
                line_L.circleColors.append(NSUIColor.green)
            }
            else if(response < 0) {
                line_L.circleColors.append(NSUIColor.magenta)
            }
            else if(response == 0) {
                line_L.circleColors.append(NSUIColor.black)
            }
            else {
                print("Response Error: ", response)
            }
        }

        if(values.responses_R?.count ?? 0 > 0) { line_R.circleColors = [] }
        for response in values.responses_R ?? [] {
            if(response > 0) {
                line_R.circleColors.append(NSUIColor.green)
            }
            else if(response < 0) {
                line_R.circleColors.append(NSUIColor.magenta)
            }
            else if(response == 0) {
                line_R.circleColors.append(NSUIColor.black)
            }
            else {
                print("Response Error: ", response)
            }
        }

        let data_L = LineChartData()
        let data_R = LineChartData()
        
        data_L.addDataSet(line_L) //Adds the line to the dataSet
        data_R.addDataSet(line_R)
        
        data_L.setValueFont(NSUIFont.systemFont(ofSize: 12.0))
        data_R.setValueFont(NSUIFont.systemFont(ofSize: 12.0))
        
        chartView_L.data = data_L
        chartView_R.data = data_R
        
        updateCharts(values)
    }
    
    // Mark: Charts
    func updateCharts(_ values: PatientProfileValues) {
        // Set y-axis
        let max_L = (values.results_L ?? []).max() ?? SYSTEM_MAX_DB
        let max_R = (values.results_R ?? []).max() ?? SYSTEM_MAX_DB
        let min_L = (values.results_L ?? []).min() ?? SYSTEM_MIN_DB
        let min_R = (values.results_R ?? []).min() ?? SYSTEM_MIN_DB
        
        let leftAxis_L = chartView_L.getAxis(YAxis.AxisDependency.left)
        let leftAxis_R = chartView_R.getAxis(YAxis.AxisDependency.left)
        
        leftAxis_L.granularity = ((max_L! - min_L!) > 30) ? 10 : 5
        leftAxis_R.granularity = ((max_R! - min_R!) > 30) ? 10 : 5
        
        let rightAxis_L = chartView_L.getAxis(YAxis.AxisDependency.right)
        let rightAxis_R = chartView_R.getAxis(YAxis.AxisDependency.right)
        
        rightAxis_L.enabled = false
        rightAxis_R.enabled = false
        rightAxis_L.drawGridLinesEnabled = false
        rightAxis_R.drawGridLinesEnabled = false
        
        chartView_L.drawGridBackgroundEnabled = true
        chartView_R.drawGridBackgroundEnabled = true
        
        chartView_L.gridBackgroundColor = NSUIColor(red: 0.5, green: 0.8, blue: 0.95, alpha: 0.6)
        chartView_R.gridBackgroundColor = NSUIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 0.6)
        
        chartView_L.legend.font = NSUIFont.systemFont(ofSize: 16.0)
        chartView_R.legend.font = NSUIFont.systemFont(ofSize: 16.0)
    }
}
