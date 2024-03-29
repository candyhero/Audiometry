
import UIKit
import Charts
import CoreData

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
//------------------------------------------------------------------------------
// Local Variables  
//------------------------------------------------------------------------------
    private let _managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var _globalSetting: GlobalSetting!
    private var _currentPatient: PatientProfile!
    
    private var _patients: [PatientProfile] = []
    private var _patientButtons: [UIButton] = []
    private var _patientSectionRowCount: [Int] = [] 
    
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
    
    @IBAction func deleteCurrentPatient(_ sender: UIButton) {
        if let patientName = _currentPatient?.name {
            let alertMsg = "Are you sure to delete patient: \(patientName)?"
            alertPrompt(alertTitle: "Delete patient profile",
                        alertMsg: alertMsg,
                        confirmFunction: deletePatient,
                        uiCtrl: self)
        }
    }
    
    func deletePatient(){
        let indexPath = tbPatients.indexPathForSelectedRow
        
        if let section = indexPath?.section {
            let patient = _patients[section]
            _managedContext.delete(patient)
            
            _patients.remove(at: section)
            _patientButtons.remove(at: section)
            _patientSectionRowCount.remove(at: section)
            
            for (index, button) in _patientButtons.enumerated() {
                button.tag = index
            }
            
            _currentPatient = nil
            tbPatients.deleteSections(IndexSet([section]), with: .fade)
        }
        
        try? _managedContext.save()
    }
    
    @IBAction func deleteAllPatients(_ sender: UIButton) {
        let alertMsg = "Are you sure to delete all patients?"
        alertPrompt(alertTitle: "Delete patient profile",
                    alertMsg: alertMsg,
                    confirmFunction: deleteAllPatient,
                    uiCtrl: self)
    }
    
    func deleteAllPatient(){
        for patient in _patients {
            _managedContext.delete(patient)
        }
        try? _managedContext.save()
        performSegue(withIdentifier: "segueTitleFromResult", sender: nil)
    }
    
    @IBAction func exportAllPatients(_ sender: UIButton){
        // if no patient data
        if(_patients.count == 0){
            return
        }
        
        do {
            let csvText = exportAllPatientsInRows(_patients)
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
    
    func exportAllPatientsInRows(_ patientProfiles:[PatientProfile])->String{
        
        // Create CSV
        var csvText = ""
        
        // Top Title Bar
        csvText.append("Patient Name,")
        csvText.append("Group,")
        csvText.append("Start Time,")
        csvText.append("End Time,")
        csvText.append("Duration(sec),")
        csvText.append("Ear Test Order,")
        csvText.append("Frequency Test Order,")
        
        csvText.append("LSpam,")
        for FREQ in ARRAY_DEFAULT_FREQ{
            csvText.append("\(FREQ),")
        }
        csvText.append("RSpam,")
        for FREQ in ARRAY_DEFAULT_FREQ{
            csvText.append("\(FREQ),")
        }
        
        csvText.append("Result (L),")
        for FREQ in ARRAY_DEFAULT_FREQ{
            csvText.append("\(FREQ),")
        }
        csvText.append("Result (R),")
        for FREQ in ARRAY_DEFAULT_FREQ{
            csvText.append("\(FREQ),")
        }
        
        csvText.append("\n")
        
        // Each patient row
        for patientProfile in patientProfiles{
            csvText.append(extractPatientValues(patientProfile))
        }
        
        return csvText
    }

    private func extractPatientValues(_ patientProfile: PatientProfile) -> String {
        var csvText = ""
        csvText.append("\(patientProfile.name!),")
        csvText.append("\(patientProfile.group ?? "N/A"),")
        
        csvText.append(
            (patientProfile.timestamp != nil) ?
                "\(patientProfile.timestamp!)," : "N/A,"
        )
        csvText.append(
            (patientProfile.endTime != nil) ?
                "\(patientProfile.endTime!)," : "N/A,"
        )
        csvText.append(
            (patientProfile.durationSeconds > 0) ?
                "\(patientProfile.durationSeconds)," : "N/A,"
        )
        
        csvText.append("\(patientProfile.earOrder ?? "N/A"),")
        let str_freqOrder = patientProfile.frequencyOrder?.map{String($0)}
        csvText.append("\(str_freqOrder?.joined(separator: "->") ?? "N/A"),")
        
        
        // Prepare threshold values
        let patientProfileValues = getSortedPatientProfileValues(patientProfile)
        var dict_threshold_L = [Int:Int]()
        var dict_threshold_R = [Int:Int]()
        var dict_spamCount_L = [Int:Int]()
        var dict_spamCount_R = [Int:Int]()
        
        for values in patientProfileValues{
            dict_spamCount_L[Int(values.frequency)] = Int(values.spamCount_L)
            dict_spamCount_R[Int(values.frequency)] = Int(values.spamCount_R)
            
            dict_threshold_L[Int(values.frequency)] = Int(values.threshold_L)
            dict_threshold_R[Int(values.frequency)] = Int(values.threshold_R)
        }
        
        // Left Ear Spam Count
        csvText.append( ",")
        for FREQ in ARRAY_DEFAULT_FREQ{
            let spamCount_L = dict_spamCount_L[FREQ, default:0]
            csvText.append((spamCount_L > 0) ? "\(spamCount_L)," : " ,")
        }
        
        // Left Ear Spam Count
        csvText.append( ",")
        for FREQ in ARRAY_DEFAULT_FREQ{
            let spamCount_R = dict_spamCount_R[FREQ, default:0]
            csvText.append((spamCount_R > 0) ? "\(spamCount_R)," : " ,")
        }
        
        // Left Ear Frequency Thresholds
        csvText.append( ",")
        for FREQ in ARRAY_DEFAULT_FREQ{
            let threshold_L = dict_threshold_L[FREQ, default:0]
            switch threshold_L{
            case 0:
                csvText.append(",")
                break
            case -1:
                csvText.append("NR,")
                break
            default:
                csvText.append("\(threshold_L),")
            }
        }
        
        // Right Ear Frequency Thresholds
        csvText.append( ",")
        for FREQ in ARRAY_DEFAULT_FREQ{
            let threshold_R = dict_threshold_R[FREQ, default:0]
            switch threshold_R{
            case 0:
                csvText.append(",")
                break
            case -1:
                csvText.append("NR,")
                break
            default:
                csvText.append("\(threshold_R),")
            }
        }
        
        csvText.append("\n")
        return csvText
    }

//------------------------------------------------------------------------------
// TableView Functions
//------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return _patients.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.darkGray
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        
        let patient = _patients[section]
        let title = "[\(patient.group ?? "NO_GROUP")] \(patient.name ?? "NO_NAME")"
            + "\(patient.isAdult ? "(Adult)":"(Child)")"
            + "\(patient.isPractice ? "[Practice]" : "")"
        
        button.setTitle(title, for: .normal)
        button.tag = section
        
        _patientButtons.append(button)
        return button
    }
    
    @objc func handleExpandClose(button: UIButton!){
        _currentPatient = _patients[button.tag]
        
        let patientProfileValues = getSortedPatientProfileValues(_currentPatient)
        let indexPaths = patientProfileValues.indices.map { IndexPath(row: $0, section: button.tag)}
        
        if(_patientSectionRowCount[button.tag] > 0){
            
            _patientSectionRowCount[button.tag] = 0
            tbPatients.deleteRows(at: indexPaths, with: .fade)
        }
        else {
            _patientSectionRowCount[button.tag] = patientProfileValues.count
            tbPatients.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    // Cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _patientSectionRowCount[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve patient brief info
        _currentPatient = _patients[indexPath.section]
        let values = getSortedPatientProfileValues(_currentPatient)[indexPath.row]
        
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
        _currentPatient = _patients[indexPath.section]
        let values = getSortedPatientProfileValues(_currentPatient)
        updateGraph(values[indexPath.row])
    }
    
//------------------------------------------------------------------------------
// Chart functions
//------------------------------------------------------------------------------
    fileprivate func updateCharts(_ values: PatientProfileValues) {
        // Set y-axis
        let max_L = (values.results_L ?? []).max() ?? _DB_SYSTEM_MAX
        let max_R = (values.results_R ?? []).max() ?? _DB_SYSTEM_MAX
        let min_L = (values.results_L ?? []).min() ?? _DB_SYSTEM_MIN
        let min_R = (values.results_R ?? []).min() ?? _DB_SYSTEM_MIN
        
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
    func updateGraph(_ values: PatientProfileValues){
        
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
        if(values.responses_L?.count ?? 0 > 0){
            line_L.circleColors = []
        }
        for response in values.responses_L ?? [] {
            if(response > 0){
                line_L.circleColors.append(NSUIColor.green)
            }
            else if(response < 0){
                line_L.circleColors.append(NSUIColor.magenta)
            }
            else if(response == 0){
                line_L.circleColors.append(NSUIColor.black)
            }
            else {
                print("Response Error: ", response)
            }
        }
        if(values.responses_R?.count ?? 0 > 0){
            line_R.circleColors = []
        }
        for response in values.responses_R ?? [] {
            if(response > 0){
                line_R.circleColors.append(NSUIColor.green)
            }
            else if(response < 0){
                line_R.circleColors.append(NSUIColor.magenta)
            }
            else if(response == 0){
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
            _patients = try _managedContext.fetch(patientRequest)
        } catch let error as NSError{
            print("Could not fetch calibration setting.")
            print("\(error), \(error.userInfo)")
        }
    }
    
    func initSettings(){
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
        
        // Load result
        initSettings()
        let mostRecentPatient = _patients.first!
        
        _patientSectionRowCount = _patients.map{ _ in return 0 }
        
        let mostRecentValues = getSortedPatientProfileValues(mostRecentPatient)
        print(mostRecentPatient)
        _patientSectionRowCount[0] = mostRecentValues.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
