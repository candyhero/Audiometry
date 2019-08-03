//
//  PauseViewController.swift
//  Audiometry
//
//  Created by Xavier on 31/7/19.
//  Copyright © 2019 TriCounty. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PauseViewController: UIViewController {
    
    private let managedContext = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    private var globalSetting: GlobalSetting! = nil
    
    @IBOutlet weak var lbCaption: UILabel!
    @IBOutlet weak var pbContinue: UIButton!
    
    func initCaption(){
        // fetch global setting
        let request:NSFetchRequest<GlobalSetting> =
            GlobalSetting.fetchRequest()
        request.fetchLimit = 1
        
        do {
            globalSetting = try managedContext.fetch(request).first
            
        } catch let error as NSError{
            print("Could not fetch global setting.")
            print("\(error), \(error.userInfo)")
        }
        
        //print((globalSetting.patientProfile?.isAdult)!)
        
        if((globalSetting.patientProfile?.isAdult)!){
            lbCaption.text = "Great job! Half way done!"
            pbContinue.setTitle("Continue", for: .normal)
        }
        else{
            lbCaption.text = ""
            
            let imgDir = "Shape_Icons/1000Hz"
            let img = UIImage(named:imgDir)?.withRenderingMode(.alwaysOriginal)
            pbContinue.imageView?.contentMode = .center
            
            pbContinue.setTitle("Continue", for: .normal)
            pbContinue.setImage(img, for: .normal)
            pbContinue.adjustsImageWhenHighlighted = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initCaption()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
