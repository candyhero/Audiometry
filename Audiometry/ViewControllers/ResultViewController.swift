
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
    
    @IBAction func deleteCurrentPatient(_ sender: UIButton) {
//        print("Count: ", _array_buttons.count)
//        for button in _array_buttons{
//            print(button.tag)
//        }
        let alertMsg = "Are you sure to delete \"" + (_currentPatient?.name)! + "\" ?"
        
        alertPrompt(alertTitle: "Delete patient profile",
                    alertMsg: alertMsg,
                    confirmFunction: deletePatient,
                    uiCtrl: self)
    }
    
    func extractPatientProfileValues(_ values: PatientProfileValues) -> String{
        var csvText = ""
        
        if(values.results_L != nil){
            csvText.append(" , Frequency, \(values.frequency), Left\n")
            // Print left values
            csvText.append(" , , Threshold Level, \(values.threshold_L)\n")
            // Arrays
            csvText.append(" , , Sound Levels")
            for level in values.results_L!{
                csvText.append(", \(level)")
            }
            csvText.append("\n")
            csvText.append(" , , Response Correctness")
            for response in values.responses_L ?? [] {
                csvText.append(", \(response)")
            }
            csvText.append("\n")
            //
            csvText.append(" , , # of No Sound Responses, \(values.no_sound_count_L)\n")
            csvText.append(" , , # of Correct No Sound Responses, \(values.no_sound_correct_L)\n")
            csvText.append("\n")
        }
        
        if(values.results_R != nil){
            csvText.append(" , Frequency, \(values.frequency), Right\n")
            // Print left values
            csvText.append(" , , Threshold Level, \(values.threshold_R)\n")
            // Arrays
            csvText.append(" , , Sound Levels")
            for level in values.results_R!{
                csvText.append(", \(level)")
            }
            csvText.append("\n")
            csvText.append(" , , Response Correctness")
            for response in values.responses_R ?? [] {
                csvText.append(", \(response)")
            }
            csvText.append("\n")
            //
            csvText.append(" , , # of No Sound Responses, \(values.no_sound_count_R)\n")
            csvText.append(" , , # of Correct No Sound Responses, \(values.no_sound_correct_R)\n")
            csvText.append("\n")
        }
        
        return csvText
    }
    
    @IBAction func exportAllPatients(_ sender: UIButton) {
        
        // if no patient data
        if(_array_patients.count == 0){
            return
        }
        
        // Create CSV
        var csvText = ""
        var tempText = ""
        
        for patientProfile in _array_patients{
            csvText.append("Patient Name, \(patientProfile.name!)\n")
            
            tempText = (patientProfile.timestamp != nil) ?
                ("Start Time, \(patientProfile.timestamp!)\n") :
                ("Start Time, N/A\n")
            csvText.append(tempText)
            
            tempText = (patientProfile.endTime != nil) ?
                ("End Time, \(patientProfile.endTime!)\n") :
                ("End Time, N/A\n")
            csvText.append(tempText)
            
            tempText = (patientProfile.durationSeconds > 0) ?
                ("Duration(sec), \(patientProfile.durationSeconds)\n") :
                ("Duration(sec), N/A\n")
            csvText.append(tempText)
            
            let patientProfileValues = getSortedValues(patientProfile)
            for values in patientProfileValues{
                csvText.append(extractPatientProfileValues(values))
            }
        }
        //print(csvText)
        
        // Create .csv file
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            
            let fileName = "AudiometryPatientExport_\(dateFormatter.string(from: Date())).csv"
            print("FileName: \(fileName)")
            
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            
            let activityVC = UIActivityViewController(activityItems: [path!], applicationActivities: [])
//            activityVC.excludedActivityTypes = [
//                UIActivity.ActivityType.assignToContact,
//                UIActivity.ActivityType.saveToCameraRoll,
//                UIActivity.ActivityType.postToFlickr,
//                UIActivity.ActivityType.postToVimeo,
//                UIActivity.ActivityType.postToTencentWeibo,
//                UIActivity.ActivityType.postToTwitter,
//                UIActivity.ActivityType.postToFacebook,
//                UIActivity.ActivityType.openInIBooks
//            ]
            present(activityVC, animated: true, completion: nil)
            
            if let popOver = activityVC.popoverPresentationController {
                popOver.sourceView = self.view
                //popOver.sourceRect =
                //popOver.barButtonItem
            }
            
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    @IBAction func exportAllPatientsInRows(_ sender: UIButton){
        // if no patient data
        if(_array_patients.count == 0){
            return
        }
        
        // Create CSV
        var csvText = ""
        
        csvText.append("Patient Name,")
        csvText.append("Start Time,")
        csvText.append("End Time,")
        csvText.append("Duration(sec),")
        
        csvText.append("Result(L),")
        for FREQ in ARRAY_DEFAULT_FREQ{
            csvText.append("\(FREQ),")
        }
        csvText.append("Result(R),")
        for FREQ in ARRAY_DEFAULT_FREQ{
            csvText.append("\(FREQ),")
        }
        csvText.append("\n")
        
        for patientProfile in _array_patients{
            csvText.append( "\(patientProfile.name!),")
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
            
            let patientProfileValues = getSortedValues(patientProfile)
            var dict_threshold_L = [Int:Int]()
            var dict_threshold_R = [Int:Int]()
            
            for values in patientProfileValues{
                dict_threshold_L[Int(values.frequency)] = Int(values.threshold_L)
                dict_threshold_R[Int(values.frequency)] = Int(values.threshold_R)
            }
            
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
        }
        //print(csvText)
        
        // Create .csv file
        do {
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
        let tag = (patient.isAdult) ? "(Adult)":"(Child)"
        let tag2 = (patient.isPractice) ? "[Practice]" : ""
        let title = (patient.name ?? "NAME_ERROR") + tag + tag2
        button.setTitle(title, for: .normal)
        button.tag = section
        
        _array_buttons.append(button)
        // add button to array_buttons
        return button
    }
    
    @objc func handleExpandClose(button: UIButton!){
        
        _currentPatient = _array_patients[button.tag]
        
        let values = getSortedValues(_currentPatient)
        var array_indexPath = [IndexPath]()
        
        for freqIndex in values.indices {
            let indexPath = IndexPath(row: freqIndex, section: button.tag)
            array_indexPath.append(indexPath)
        }
        
        if(_patientSectionRows[button.tag] > 0){
            
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
        
//        if(values.durationSeconds_L > 0){
//            print("L:")
//            print(values.startTime_L!)
//            print(values.endTime_L!)
//            print(values.durationSeconds_L)
//        }
//
//        if(values.durationSeconds_R > 0){
//            print("R:")
//            print(values.startTime_R!)
//            print(values.endTime_R!)
//            print(values.durationSeconds_R)
//        }

        // Configure table cell style
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let label_L = (values.threshold_L >= 0) ?
            String(values.threshold_L): "NR"
        
        let label_R = (values.threshold_R >= 0) ?
            String(values.threshold_R): "NR"
        
        var labelText = String(values.frequency) + " Hz ; "
        labelText += "dB Threshold: (L) " + label_L + " (R) " + label_R + " ; "
        labelText += "Reliability:"
            + " (L) " + String(values.no_sound_correct_L) + "/" + String(values.no_sound_count_L)
            + " (R) " + String(values.no_sound_correct_R) + "/" + String(values.no_sound_count_R)
        
        cell.textLabel?.text = labelText
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
        
        let patient = _array_patients[indexPath!.section]
        _managedContext.delete(patient)
        _array_patients.remove(at: indexPath!.section)
        
        _patientSectionRows.remove(at: indexPath!.section)
        tbPatients.deleteSections(IndexSet([indexPath!.section]), with: .fade)
        
        //update button tags
        //for button in
    }
    // Plot functions
    func updateGraph(_ values: PatientProfileValues){
        
        // Load dB and result lists
        let label_L = (values.threshold_L >= 0) ?
            String(values.threshold_L): "NR"
        
        let label_R = (values.threshold_R >= 0) ?
            String(values.threshold_R): "NR"
        
        var labelText = String(values.frequency) + " Hz ; "
        labelText += "dB Threshold: (L) " + label_L + " (R) " + label_R + " ; "
        
        labelText += "Reliability:"
            + " (L) " + String(values.no_sound_correct_L) + "/" + String(values.no_sound_count_L)
            + " (R) " + String(values.no_sound_correct_R) + "/" + String(values.no_sound_count_R)
        
        lbFreq.text = labelText
        
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
        
        //
        let data_L = LineChartData()
        let data_R = LineChartData()
        
        data_L.addDataSet(line_L) //Adds the line to the dataSet
        data_R.addDataSet(line_R)
        
        data_L.setValueFont(NSUIFont.systemFont(ofSize: 12.0))
        data_R.setValueFont(NSUIFont.systemFont(ofSize: 12.0))
        
        chartView_L.data = data_L
        chartView_R.data = data_R
        
        chartView_L.drawGridBackgroundEnabled = true
        chartView_R.drawGridBackgroundEnabled = true
        
        chartView_L.gridBackgroundColor =
            NSUIColor(red: 0.5, green: 0.8, blue: 0.95, alpha: 0.6)
        chartView_R.gridBackgroundColor =
            NSUIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 0.6)
        
        chartView_L.legend.font = NSUIFont.systemFont(ofSize: 16.0)
        chartView_R.legend.font = NSUIFont.systemFont(ofSize: 16.0)
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
