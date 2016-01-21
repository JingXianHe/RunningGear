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
import MediaPlayer

class RunViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext?
    var run: Run!
        
    @IBOutlet weak var songLists: UITableView!
    @IBOutlet weak var musicListContainer: UIView!
    
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var PaceLabel: UILabel!
    @IBOutlet weak var RemainLabel: UILabel!

    @IBOutlet weak var playMusicBtn: UIButton!
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
    //for music player
    var	userMediaItemCollection:MPMediaItemCollection?
    weak var musicPlayer:MPMusicPlayerController?
     var songsTitle = [String]()
    var isPlayingMusic :Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestAlwaysAuthorization()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        songLists.dataSource = self
        
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
            isPlayingMusic = false
            musicPlayer?.pause()
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
            if isPlayingMusic == false{
                self.musicPlayer?.play()
                isPlayingMusic = true
            }
            
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
        
        // 2
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location",
                inManagedObjectContext: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        // 3
        if managedObjectContext!.hasChanges {
            do {
                try managedObjectContext!.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? ResultViewController {
            detailViewController.run = run
            detailViewController.RunVCDelegat = self
            detailViewController.managedObjectContext = managedObjectContext
        }
    }
    @IBAction func playMusicItem() {
        let picker = MPMediaPickerController(mediaTypes: MPMediaType.AnyAudio)
        
        picker.delegate	= self;
        picker.allowsPickingMultipleItems = true;
        picker.prompt	= "Add songs to play Prompt in media item picker";
        
        presentViewController(picker, animated: false) { () -> Void in
            
        }
    }
    func updatePlayerQueueWithMediaCollection(mediaItemCollection:MPMediaItemCollection){
        
        // Configure the music player, but only if the user chose at least one song to play
        
        // apply the new media item collection as a playback queue for the music player
        
        if((self.userMediaItemCollection) != nil){
            var wasPlaying:Bool = false;
            if (self.musicPlayer!.playbackState == MPMusicPlaybackState.Playing) {
                wasPlaying = true;
            }
            
            // Save the now-playing item and its current playback time.
            let nowPlayingItem:MPMediaItem	= musicPlayer!.nowPlayingItem!
            let currentPlaybackTime:NSTimeInterval	= musicPlayer!.currentPlaybackTime
            
            // Combine the previously-existing media item collection with the new one
            var combinedMediaItems:NSMutableArray	= NSMutableArray(array:userMediaItemCollection!.items)
            var newMediaItems:NSArray			= mediaItemCollection.items
            combinedMediaItems.addObjectsFromArray(newMediaItems as [AnyObject])
            
            userMediaItemCollection = MPMediaItemCollection(items: combinedMediaItems as NSArray! as! [MPMediaItem])
            
            // Apply the new media item collection as a playback queue for the music player.
            musicPlayer?.setQueueWithItemCollection(userMediaItemCollection!)
            
            // Restore the now-playing item and its current playback time.
            musicPlayer?.nowPlayingItem			= nowPlayingItem
            musicPlayer?.currentPlaybackTime		= currentPlaybackTime;
            let collection = userMediaItemCollection!.items
            for var item:MPMediaItem? in collection{
                
                songsTitle.append(item!.title!)
                
            }
            
            // If the music player was playing, get it playing again.
            if (wasPlaying) {
                self.musicPlayer?.play()
            }
        }else{
            self.userMediaItemCollection = mediaItemCollection
            let musicPlayer = MPMusicPlayerController()
            musicPlayer.setQueueWithItemCollection(mediaItemCollection)
            self.musicPlayer = musicPlayer
            
            let collection = mediaItemCollection.items 
            if(isRunning){
                musicPlayer.play()
                isPlayingMusic = true
            }
            
            for var item:MPMediaItem? in collection{
                
                songsTitle.append(item!.title!)
                
            }
        }
        self.songLists.reloadData()
        
    }
    func cleanMusicPlayer(){
        userMediaItemCollection = nil
        
        musicPlayer?.nowPlayingItem = nil;
        musicPlayer?.stop()
    }
    @IBAction func addMusics(sender: AnyObject) {
        playMusicBtn.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
    }
    @IBAction func dismissMusicList() {
        musicListContainer.hidden = true

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
            cleanMusicPlayer()
            performSegueWithIdentifier("showResult", sender: nil)
        }
            //discard
        else if buttonIndex == 2 {
            cleanMusicPlayer()
            dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
    }
}
extension RunViewController:MPMediaPickerControllerDelegate{
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        updatePlayerQueueWithMediaCollection(mediaItemCollection)
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
}
extension RunViewController:UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var counts : Int = 0
        if songsTitle.count > 0 {
            counts = songsTitle.count
        }
        
        return counts
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = UITableViewCell()
        if songsTitle.count > 0{
            
            cell.textLabel?.text =  songsTitle[indexPath.row]
        }
        
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

}
