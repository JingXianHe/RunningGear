//
//  AddData2BMIController.swift
//  RunningGear
//
//  Created by beihaiSellshou on 2/1/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit
import HealthKit
class AddData2BMIController: UIViewController {

    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var energyLabel: UILabel!
    
    let healthManager:HealthManager = HealthManager()
    var weight:Double = 0.0
    var run:Run?
    var timeLine:NSDate?
    var date:NSDate?
    var durationInMinutes:Double = 0.0
    var distance:Double = 0.0
    var energyBurned:Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        date = (run?.timestamp)!
        durationInMinutes = (run?.duration?.doubleValue)!
        distance = (run?.distance?.doubleValue)!
        energyBurned = weight * distance*1.036 / 1000
        let date1 = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        startTimeLabel.text = formatter.stringFromDate(date1)
        timeLine = formatter.dateFromString(startTimeLabel.text!)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateLabel.text = dateFormatter.stringFromDate(date!)
        durationLabel.text = String(format: "%.2f", durationInMinutes)
        distanceLabel.text = String(format: "%.2f", distance)
        energyLabel.text = String(format: "%.3f", energyBurned)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addData2BMI() {
        let hkUnit = HKUnit.meterUnit()
        self.healthManager.saveRunningWorkout(startDate!, endDate: endDate!, distance: distance , distanceUnit:hkUnit, kiloCalories: energyBurned, completion: { (success, error ) -> Void in
            if( success )
            {
                dispatch_async(dispatch_get_main_queue(),{() -> Void in
                    let alert = UIAlertController(title: "Success", message: "Workout saved!", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:nil))
                    self.presentViewController(alert, animated: true, completion: {
                        
                    })
                });
                
            }
            else if( error != nil ) {
                dispatch_async(dispatch_get_main_queue(),{() -> Void in
                    let alert = UIAlertController(title: "Error", message: String(format: "%@", error), preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:nil))
                    self.presentViewController(alert, animated: true, completion: {
                        
                    })
                });
                
            }
        })
    }

    @IBAction func exitSuper(sender: UIButton) {
        dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    func datetimeWithDate(date:NSDate , time:NSDate) -> NSDate? {
        let date = NSDate()
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        
        let unitFlags1: NSCalendarUnit = [.Hour, .Minute]
        let components1 = NSCalendar.currentCalendar().components(unitFlags1, fromDate: time)

        let currentCalendar = NSCalendar.currentCalendar()
        
        let dateWithTime = currentCalendar.dateByAddingComponents(components1, toDate:currentCalendar.dateFromComponents(components)!, options:NSCalendarOptions(rawValue: 0))
        
        return dateWithTime;
        
    }
    var startDate:NSDate? {
        get {
            
            return datetimeWithDate(date!, time: self.timeLine! )
        }
    }
    
    var endDate:NSDate? {
        get {
            let endDate = startDate?.dateByAddingTimeInterval(durationInMinutes*60.0)
            return endDate
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
