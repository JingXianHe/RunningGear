//
//  SettingPaneViewController.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/30/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit
import HealthKit

class SettingPaneViewController: UIViewController {

    @IBOutlet weak var distanceLength: UISlider!
    
    @IBOutlet weak var timeLength: UISlider!
    
    
    @IBOutlet weak var distanceValue: UILabel!
    
    @IBOutlet weak var timeValue: UILabel!
    
    @IBOutlet weak var enableSetGoalBtn: UIButton!
    
    @IBOutlet weak var workoutBtn: UIButton!
    
    @IBOutlet weak var weightText: UITextField!
    
    @IBOutlet weak var heightText: UITextField!
    
    var isSetGoal:Bool = false
    let healthManager:HealthManager = HealthManager()
    var weight:Double = 0.0
    var height:Double = 0.0
    
    weak var textField4Weight: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let setGoalValue = defaults.stringForKey("isSetGoal"){
            if setGoalValue == "true"{
                distanceLength.userInteractionEnabled = true
                timeLength.userInteractionEnabled = true
                enableSetGoalBtn.setImage(UIImage(named: "setGoal"), forState: .Normal)
                if let distanceValue = defaults.stringForKey("distanceSettingPane"){
                    distanceLength.value = NSNumberFormatter().numberFromString(distanceValue)!.floatValue
                }
                if let timeValue = defaults.stringForKey("timeSettingPane"){
                   timeLength.value = NSNumberFormatter().numberFromString(timeValue)!.floatValue
                }
                isSetGoal = true;

            }
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func go2Workouts(sender: UIButton) {
        if weight == 0.0 {
            let alert = UIAlertController(title: "Weight (kg)", message: "Please input weight for calorie calculation", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler(configurationTextField)
            
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                if let weightIndex = self.textField4Weight?.text
                {
                    if let weightValue = NSNumberFormatter().numberFromString(weightIndex)?.doubleValue{
                        self.weight = weightValue
                        let mystoryboard = UIStoryboard(name: "PastRun", bundle: nil)
                        let nav = mystoryboard.instantiateViewControllerWithIdentifier("pastRun") as! PastRunViewController
                        nav.isPaneSettingMode = true
                        nav.weightValue = self.weight
                        self.presentViewController(nav, animated: true) { () -> Void in
                            
                        }
                    }
                }
                
            }))
            self.presentViewController(alert, animated: true, completion: {
                
            })
        }else{
            let mystoryboard = UIStoryboard(name: "PastRun", bundle: nil)
            let nav = mystoryboard.instantiateViewControllerWithIdentifier("pastRun") as! PastRunViewController
            nav.isPaneSettingMode = true
            nav.weightValue = self.weight
            self.presentViewController(nav, animated: true) { () -> Void in
                
            }
        }
        
        
    }
    func configurationTextField(textField: UITextField!)
    {
        
        self.textField4Weight = textField
    }
    
    
    func handleCancel(alertView: UIAlertAction!)
    {
        
    }

    @IBAction func distanceChange(sender: AnyObject) {
        let receiver:UISlider = sender as! UISlider
        let value = receiver.value
        distanceValue.text = String(format: "%.0f m", value)
    }
    
    @IBAction func timeChange(sender: AnyObject) {
        let receiver:UISlider = sender as! UISlider
        let value = receiver.value
        timeValue.text = String(format: "%.0f m", value)
    }
    
    @IBAction func enableSetGoal(sender: UIButton) {
        isSetGoal = !isSetGoal
        if isSetGoal == true{
            enableSetGoalBtn.setImage(UIImage(named: "setGoal"), forState: .Normal)
            distanceLength.userInteractionEnabled = true
            timeLength.userInteractionEnabled = true
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("true", forKey: "isSetGoal")
        }else{
            enableSetGoalBtn.setImage(UIImage(named: "goal"), forState: .Normal)
            distanceLength.userInteractionEnabled = false
            timeLength.userInteractionEnabled = false
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("false", forKey: "isSetGoal")
        }
    }
    
    @IBAction func go2Home() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let setGoalValue = defaults.stringForKey("isSetGoal")
        if setGoalValue == "true"{
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(distanceLength.value, forKey: "distanceSettingPane")
            defaults.setObject(timeLength.value, forKey: "timeSettingPane")
        }
        dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    @IBAction func ask4HealthKitAuthor() {
        healthManager.authorizeHealthKit {
            (authorized,  error) -> Void in
            if authorized {
                //print("HealthKit authorization received.")
                dispatch_async(dispatch_get_main_queue(),{() -> Void in
                    self.workoutBtn.userInteractionEnabled = true;
                    self.workoutBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    self.updateWeight()
                    self.updateHeight()
                });
                
                
            }
            else
            {
//                print("HealthKit authorization denied!")
//                if error != nil {
//                    print("\(error)")
//                }
            }
        }

    }
    func updateWeight()
    {
        //读取重量
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        // 2. Call the method to read the most recent weight sample
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            var weight4Input:Double = 0.0
            // 3. Format the weight to display it on the screen
            let weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                weight4Input = kilograms
            }
            self.weight = weight4Input
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.weightText.text = String(format:"%.1f",weight4Input)
                
            });
        });
    }
    func updateHeight()
    {
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        
        // 2. Call the method to read the most recent Height sample
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentHeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading height from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            var height4Input:Double = 0.0
            let height = mostRecentHeight as? HKQuantitySample;
            // 3. Format the height to display it on the screen
            if let meters = height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
                height4Input = meters
            }
        
            self.height = height4Input
            // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.heightText.text = String(format:"%.1f", height4Input)

            });
        })
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
