//
//  RunViewController.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/9/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit

class RunViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext?
    var run: Run!
        
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var PaceLabel: UILabel!
    @IBOutlet weak var RemainLabel: UILabel!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var StartBtn: UIButton!
    var seconds = 0.0
    var distance = 0.0
    var currentPace = 0.0;
    var isRunning:Bool = false
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StartBtn.layer.cornerRadius = StartBtn.frame.height/2
        mapView.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func Go2Home() {
        dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }

    @IBAction func TriggerRun(sender: UIButton) {
        if isRunning{
            
            sender.backgroundColor = UIColor(red: 18/255.0, green: 174/255.0, blue: 212/255.0, alpha: 1.0)
            sender.setTitle("Start", forState: UIControlState.Normal)
            isRunning = false
            timer.invalidate()
            locationManager.stopUpdatingLocation()
            let actionSheet = UIActionSheet(title: "Run Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Discard")
            actionSheet.actionSheetStyle = .Default
            actionSheet.showInView(view)
        }else{
            locations.removeAll(keepCapacity: false)
            timer = NSTimer.scheduledTimerWithTimeInterval(1,
                target: self,
                selector: "eachSecond:",
                userInfo: nil,
                repeats: true)
            startLocationUpdates()
            sender.backgroundColor = UIColor.redColor()
            sender.setTitle("Stop", forState: UIControlState.Normal)
            isRunning = true
        }
        
        
    }
    func eachSecond(timer: NSTimer) {
        seconds++
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        TimeLabel.text = "Time: " + secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        DistanceLabel.text = "Distance: " + distanceQuantity.description
        let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: distance/seconds)
        PaceLabel.text = "Pace: " + paceQuantity.description
    }
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    func saveRun() {
        // 1
        let savedRun = NSEntityDescription.insertNewObjectForEntityForName("Run",
            inManagedObjectContext: managedObjectContext!) as! Run
        savedRun.distance = distance
        savedRun.duration = seconds
        savedRun.timestamp = NSDate()
        
        // 2初始化一个Location数据表条目的对象，然后填上数据，然后批量地储存在NSArray中
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location",
                inManagedObjectContext: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        //因为Run数据表中有一个Location数据表的field所以可以将Location数据表当属性一样储存在Run数据表中

        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        // 3
        // 3
        do {
            try managedObjectContext!.save()
        } catch let error as NSError {
            
            NSLog("Unresolved error \(error), \(error.userInfo)")
            // Handle Error
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? ResultViewController {
            detailViewController.run = run
            detailViewController.RunVCDelegat = self
        }
    }


}
// MARK: - CLLocationManagerDelegate对用户返回的更新信息进行处理
extension RunViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    currentPace = location.distanceFromLocation(self.locations.last!)
                    distance += currentPace
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                    
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
    
}
// MARK: - MKMapViewDelegate
extension RunViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        if distance/seconds > 3.4{
            renderer.strokeColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1.0)
        }else{
            renderer.strokeColor = UIColor(red: 255/255.0, green: 127/255.0, blue: 80/255, alpha: 1.0)
        }
        
        renderer.lineWidth = 3
        return renderer
    }
}
// MARK: UIActionSheetDelegate
extension RunViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        //save
        if buttonIndex == 1 {
            saveRun()
            performSegueWithIdentifier("showResult", sender: nil)
        }
            //discard
        else if buttonIndex == 2 {
            dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
    }
}
