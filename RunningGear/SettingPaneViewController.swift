//
//  SettingPaneViewController.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/30/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit

class SettingPaneViewController: UIViewController {

    @IBOutlet weak var distanceLength: UISlider!
    
    @IBOutlet weak var timeLength: UISlider!
    
    
    @IBOutlet weak var distanceValue: UILabel!
    
    @IBOutlet weak var timeValue: UILabel!
    
    @IBOutlet weak var enableSetGoalBtn: UIButton!
    
    var isSetGoal:Bool = false
    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
