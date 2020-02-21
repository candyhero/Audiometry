
import UIKit
import Charts
import CoreData

class ResultViewController: UIViewController, Storyboarded,
    UITableViewDelegate, UITableViewDataSource  {
    // MARK:
    private let _coordinator = AppDelegate.mainCoordinator
    
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var _globalSetting: GlobalSetting!
    private var _currentPatient: PatientProfile!
    
    private var _array_patients: [PatientProfile] = []
    private var _array_freqSeq: [Int] = []
    private var _array_buttons: [UIButton] = []
    
    private var _patientSectionRows: [Int] = [] // section, row
    
//------------------------------------------------------------------------------
// UI Components
//------------------------------------------------------------------------------
    @IBOutlet weak var lbFreq: UILabel!
    
    @IBOutlet weak var tbPatients: UITableView!
    
    @IBOutlet weak var chartView_L: LineChartView!
    @IBOutlet weak var chartView_R: LineChartView!
    
    @IBOutlet weak var pbPrevFreq: UIButton!
    @IBOutlet weak var pbNextFreq: UIButton!
    @IBOutlet weak var pbDeleteCurrentPatient: UIButton!
    
    @IBAction func back(_ sender: Any) {
        _coordinator.back()
    }
    
    @IBAction func deleteCurrentPatient(_ sender: UIButton) {
//        print("Count: ", _array_buttons.count)
//        for button in _array_buttons{
//            print(button.tag)
//        }
        let alertMsg = "Are you sure to delete \"" + (_currentPatient?.name)! + "\" ?"
        
        alertPrompt(alertTitle: "Delete patient profile", alertMsg: alertMsg, confirmFunction: deletePatient)
    }
    
    @IBAction func exportAllPatients(_ sender: UIButton) {
        // if no patient data
        if(_array_patients.count == 0) {
            return
        }
        
        do {
            let csvText = Audiometry.exportAllPatientsInRows(_array_patients)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            
            let fileName = "AudiometryPatientExport_\(dateFormatter.string(from: Date())).csv"
            print("FileName: \(fileName)")
            
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            
            let activityVC = UIActivityViewController(activityItems: [path!], applicationActivities: [])
            
            present(activityVC, animated: true, completion: nil)
            
            if let popOver = activityVC.popoverPresentationController {
                popOver.sourceView = self.view
            }
            
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }
    }
//------------------------------------------------------------------------------
// TableView Functions
//------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return _array_patients.count
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let button = UIButton(type: .system)
        
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self,
                         action: #selector(handleExpandClose),
                         for: .touchUpInside)
        
        let patient = _array_patients[section]
        let title = "[\(patient.group ?? "NO_GROUP")] \(patient.name ?? "NO_NAME")"
            + "\(patient.isAdult ? "(Adult)":"(Child)")"
            + "\(patient.isPractice ? "[Practice]" : "")"
        
        button.setTitle(title, for: .normal)
        button.tag = section
        
        _array_buttons.append(button)
        // add button to array_buttons
        return button
    }
    
    @objc func handleExpandClose(button: UIButton!) {
        
        _currentPatient = _array_patients[button.tag]
        
        let values = getSortedValues(_currentPatient)
        var array_indexPath = [IndexPath]()
        
        for freqIndex in values.indices {
            let indexPath = IndexPath(row: freqIndex, section: button.tag)
            array_indexPath.append(indexPath)
        }
        
        if(_patientSectionRows[button.tag] > 0) {
            
            _patientSectionRows[button.tag] = 0
            tbPatients.deleteRows(at: array_indexPath, with: .fade)
        }
        else {
            _patientSectionRows[button.tag] = values.count
            tbPatients.insertRows(at: array_indexPath, with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    // Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _patientSectionRows[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve patient brief info
        _currentPatient = _array_patients[indexPath.section]
        let values = getSortedValues(_currentPatient)[indexPath.row]
        
        print(_currentPatient)

        // Configure table cell style
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let label_L = (values.threshold_L >= 0) ?
            String(values.threshold_L): "NR"
        
        let label_R = (values.threshold_R >= 0) ?
            String(values.threshold_R): "NR"
        
        cell.textLabel?.text = "\(String(values.frequency)) Hz ; "
            + "dB Threshold: (L) \(label_L) (R) \(label_R) ; "
            + "Reliability:"
            + " (L) \(String(values.no_sound_correct_L))"
            + "/\(String(values.no_sound_count_L))"
            + " (R) \(String(values.no_sound_correct_R))"
            + "/\(String(values.no_sound_count_R))"
        
        cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        cell.textLabel?.textAlignment = .center;
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        _currentPatient = _array_patients[indexPath.section]
        let values = getSortedValues(_currentPatient)
        updateGraph(values[indexPath.row])
    }
    
//------------------------------------------------------------------------------
// CoreData functions
//------------------------------------------------------------------------------
    func deletePatient() {
        let indexPath = tbPatients.indexPathForSelectedRow
        
        if(indexPath?.section == nil) {
            return
        }
        
        let patient = _array_patients[indexPath!.section]
        _managedContext.delete(patient)
        _array_patients.remove(at: indexPath!.section)
        
        _patientSectionRows.remove(at: indexPath!.section)
        tbPatients.deleteSections(IndexSet([indexPath!.section]), with: .fade)
        
        //update button tags
        //for button in
    }
    
    fileprivate func updateCharts(_ values: PatientProfileValues) {
        // Set y-axis
        let max_L = (values.results_L ?? []).max() ?? TEST_MAX_DB
        let max_R = (values.results_R ?? []).max() ?? TEST_MAX_DB
        let min_L = (values.results_L ?? []).min() ?? TEST_MIN_DB
        let min_R = (values.results_R ?? []).min() ?? TEST_MIN_DB
        
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
        
        chartView_L.gridBackgroundColor =
            NSUIColor(red: 0.5, green: 0.8, blue: 0.95, alpha: 0.6)
        chartView_R.gridBackgroundColor =
            NSUIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 0.6)
        
        chartView_L.legend.font = NSUIFont.systemFont(ofSize: 16.0)
        chartView_R.legend.font = NSUIFont.systemFont(ofSize: 16.0)
    }
    
    // Plot functions
    func updateGraph(_ values: PatientProfileValues) {
        
        // Load dB and result lists
        let label_L = (values.threshold_L >= 0) ?
            String(values.threshold_L): "NR"
        
        let label_R = (values.threshold_R >= 0) ?
            String(values.threshold_R): "NR"
        
        lbFreq.text = "\(String(values.frequency)) Hz ; "
            + "dB Threshold: (L) \(label_L) (R) \(label_R) ; "
            + "Reliability:"
            + " (L) \(String(values.no_sound_correct_L))"
            + "/\(String(values.no_sound_count_L))"
            + " (R) \(String(values.no_sound_correct_R))"
            + "/\(String(values.no_sound_count_R))"
        
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
        
        let line_L = LineChartDataSet(entries: lineChartEntry_L,
                                     label: "Presentation Lv. (Left) in dB")
        let line_R = LineChartDataSet(entries: lineChartEntry_R,
                                     label: "Presentation Lv. (Right) in dB")
        
        line_L.colors=[NSUIColor.blue]
        line_R.colors=[NSUIColor.red]
        if(values.responses_L?.count ?? 0 > 0) {
            line_L.circleColors = []
        }
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
        if(values.responses_R?.count ?? 0 > 0) {
            line_R.circleColors = []
        }
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
        
        //
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
    
    func fetchAllPatientProfiles() {
        // fetch all PatientProfiles
        let patientRequest:NSFetchRequest<PatientProfile> =
            PatientProfile.fetchRequest()
        let sortByTimestamp = NSSortDescriptor(
            key: #keyPath(PatientProfile.timestamp),
            ascending: false)
        patientRequest.sortDescriptors = [sortByTimestamp]
        
        do {
            _array_patients = try _managedContext.fetch(patientRequest)
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func initSettings() {
        // fetch global setting
        let settingRequest:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        settingRequest.fetchLimit = 1
        
        do {
            _globalSetting = try _managedContext.fetch(settingRequest).first
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
        
        fetchAllPatientProfiles()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pbDeleteCurrentPatient.isEnabled = false
        // Load result
        initSettings()
        let mostRecentPatient = _array_patients.first!
        
        for patientProfile in _array_patients {
            _patientSectionRows.append(0)
        }
        
        let mostRecentValues = getSortedValues(mostRecentPatient)
        print(mostRecentPatient)
        _patientSectionRows[0] = mostRecentValues.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
