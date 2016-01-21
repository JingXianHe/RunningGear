//
//  ResultViewController.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/14/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit
import MapKit
import HealthKit
import CoreData

class ResultViewController: UIViewController {

    @IBOutlet weak var ResultMapView: MKMapView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    weak var RunVCDelegat:RunViewController?
    var managedObjectContext: NSManagedObjectContext?
    var isPastPane:Bool = false
    
    @IBAction func dismiss2Home() {

        
        if isPastPane{
            dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }else{
            let image:UIImage = getScreenShotOfMapView(ResultMapView.frame)
            // Convert UIImage to JPEG
            let imgData:NSData = UIImageJPEGRepresentation(image, 1); // 1 is compression quality
            
            // Identify the home directory and file name
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
            
            // Write the file.  Choose YES atomically to enforce an all or none write. Use the NO flag if partially written files are okay which can occur in cases of corruption
            [imgData writeToFile:jpgPath atomically:YES];
            
            
            dismissViewControllerAnimated(false) { () -> Void in
                self.RunVCDelegat?.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            }
        }
        isPastPane = false
    }

    
    var run: Run!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        ResultMapView.delegate = self
        // Do any additional setup after loading the view.
    }
    func configureView() {
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: NSString(format: "%.02f", run.distance!.doubleValue).doubleValue)
        distanceLabel.text = "Distance: " +  distanceQuantity.description
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateLabel.text = dateFormatter.stringFromDate(run.timestamp!)
        
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: run.duration!.doubleValue)
        timeLabel.text = "Time: " + secondsQuantity.description
        
        let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: NSString(format: "%.02f", run.distance!.doubleValue / run.duration!.doubleValue).doubleValue)
        paceLabel.text = "Pace: " + paceQuantity.description
        loadMap()
    }
    func loadMap() {
        if run.locations?.count > 0 {
            
            ResultMapView.hidden = false
            
            // Set the map bounds
            ResultMapView.region = mapRegion()
            
            
            // Make the line(s!) on the map
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: run.locations!.array as! [Location])
            ResultMapView.addOverlays(colorSegments)
        } else {
            // No locations were found!
            ResultMapView.hidden = true
            
            UIAlertView(title: "Error",
                message: "Sorry, this run has no locations saved",
                delegate:nil,
                cancelButtonTitle: "OK").show()
        }
    }
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = run.locations!.firstObject as! Location
        
        var minLat = initialLoc.latitude!.doubleValue
        var minLng = initialLoc.longitude!.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations!.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude!.doubleValue)
            minLng = min(minLng, location.longitude!.doubleValue)
            maxLat = max(maxLat, location.latitude!.doubleValue)
            maxLng = max(maxLng, location.longitude!.doubleValue)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run.locations!.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude!.doubleValue,
                longitude: location.longitude!.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: run.locations!.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getScreenShotOfMapView(targetFrame:CGRect) -> UIImage{
        let frameSize:CGSize = targetFrame.size
        UIGraphicsBeginImageContextWithOptions(frameSize, false, UIScreen.mainScreen().scale)
        ResultMapView.drawViewHierarchyInRect(CGRectMake(0, 0, frameSize.width, frameSize.height), afterScreenUpdates: true)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }

}
// MARK: - MKMapViewDelegate
extension ResultViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MulticolorPolylineSegment) {
            return nil
        }
        
        let polyline = overlay as! MulticolorPolylineSegment
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
}
