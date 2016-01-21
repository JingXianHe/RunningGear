//
//  PastRunViewController.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/20/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit
import CoreData
protocol PastRunCellDelegate {
    func pastRunShare2Public(indexPath: NSIndexPath)
    func pastRunDeleteRecord(indexPath:NSIndexPath)
}
class PastRunViewController: UIViewController {
    
    var runList = [Run]()
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var PastRunList: UITableView!
    @IBAction func pop2Home() {
        dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    let cellReuseIdentifier: String = "RunPastCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        PastRunList.dataSource = self
        PastRunList.delegate = self
        let request = NSFetchRequest(entityName: "Run")
        
        do{
            
            runList = try (managedObjectContext?.executeFetchRequest(request))! as! [Run]
            
        }catch let error as NSError{
            
        }
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
extension PastRunViewController:UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runList.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:PastRunCellTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as? PastRunCellTableViewCell
        if (cell == nil) {
            // 从xib中加载cell
            cell = NSBundle.mainBundle().loadNibNamed("RunningCell", owner: nil, options: nil).last as? PastRunCellTableViewCell
            
        }
        cell?.DistanceLabel.text = String(format: "%.2f m",(runList[indexPath.row].distance?.doubleValue)!)
        cell?.DurationLabel.text = (runList[indexPath.row].duration?.stringValue)! + "s"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        cell?.PaceLabel.text = dateFormatter.stringFromDate(runList[indexPath.row].timestamp!)
        cell?.pastRunDelegate = self
        cell?.cellIndex = indexPath
        cell?.selectionStyle = .None
        return cell!;
    }
    
}
extension PastRunViewController:UITableViewDelegate{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mystoryboard = UIStoryboard(name: "RunPane", bundle: nil)
        let nav = mystoryboard.instantiateViewControllerWithIdentifier("ResultPane") as! ResultViewController

        nav.run = runList[indexPath.row]
        nav.isPastPane = true
        presentViewController(nav, animated: true) { () -> Void in
            
        }
    }
}
extension PastRunViewController:PastRunCellDelegate{
    func pastRunShare2Public(indexPath: NSIndexPath){
        print("\(indexPath.row)")
    }
    func pastRunDeleteRecord(indexPath: NSIndexPath){
        managedObjectContext!.deleteObject(runList[indexPath.row] as NSManagedObject)
        runList.removeAtIndex(indexPath.row)
        PastRunList.reloadData()
        do{
            
            try managedObjectContext?.save()
            
        }catch let error as NSError{
            
        }
        
    }
}