
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
    @IBOutlet weak var lbFreq: UILabel!
    
    @IBOutlet weak var tbPatients: UITableView!
    
    @IBOutlet weak var chartView_L: LineChartView!
    @IBOutlet weak var chartView_R: LineChartView!
    
    @IBOutlet weak var pbPrevFreq: UIButton!
    @IBOutlet weak var pbNextFreq: UIButton!
    @IBOutlet weak var pbDeleteCurrentPatient: UIButton!
    
    @IBAction func deleteCurrentPatient(_ sender: UIButton) {
        let alertMsg = "Are you sure to delete \"" + (currentPatient?.name)! + "\" ?"
        
        alertPrompt(alertTitle: "Delete patient profile",
                    alertMsg: alertMsg,
                    confirmFunction: deletePatient,
                    uiCtrl: self)
    }
    
    @IBAction func exportAllPatients(_ sender: UIButton) {
        
        // if no patient data
        if(array_patients.count == 0){
            return
        }
        
        // Create CSV
        var csvText = ""
        
        for patientProfile in array_patients{
            csvText.append("Patient Name, \(patientProfile.name!)\n")
            csvText.append("Testing Time, \(patientProfile.timestamp!)\n")
            
            let patientProfileValues = getSortedValues(patientProfile)
            for values in patientProfileValues{
                csvText.append(extractPatientProfileValues(values))
            }
        }
        print(csvText)
        
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
        let tag2 = (patient.isPractice) ? "[Practice]" : ""
        let title = (patient.name ?? "NAME_ERROR") + tag + tag2
        button.setTitle(title, for: .normal)
        button.tag = section
        
        // add button to array_buttons
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
        
        if(values.responses_L?.count ?? 0 > 0){
            line_L.colors = []
            line_L.circleColors = []
        }
        for response in values.responses_L ?? [] {
            if(response > 0){
                line_L.circleColors.append(NSUIColor.blue)
                line_L.colors.append(NSUIColor.blue)
            }
            else if(response < 0){
                line_L.circleColors.append(NSUIColor.red)
                line_L.colors.append(NSUIColor.red)
            }
            else if(response == 0){
                line_L.circleColors.append(NSUIColor.black)
                line_L.colors.append(NSUIColor.black)
            }
            else {
                print("Response Error: ", response)
            }
        }
        
        if(values.responses_R?.count ?? 0 > 0){
            line_R.colors = []
            line_R.circleColors = []
        }
        for response in values.responses_R ?? [] {
            if(response > 0){
                line_R.circleColors.append(NSUIColor.blue)
                line_R.colors.append(NSUIColor.blue)
            }
            else if(response < 0){
                line_R.circleColors.append(NSUIColor.red)
                line_R.colors.append(NSUIColor.red)
            }
            else if(response == 0){
                line_R.circleColors.append(NSUIColor.black)
                line_R.colors.append(NSUIColor.black)
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
        
        chartView_L.data = data_L
        chartView_R.data = data_R
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
            array_patients = try managedContext.fetch(patientRequest)
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
            globalSetting = try managedContext.fetch(settingRequest).first
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
        let mostRecentPatient = array_patients.first!
        
        for patientProfile in array_patients {
            patientSectionRows.append(0)
        }
        
        let mostRecentValues = getSortedValues(mostRecentPatient)
        print(mostRecentPatient)
        patientSectionRows[0] = mostRecentValues.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
