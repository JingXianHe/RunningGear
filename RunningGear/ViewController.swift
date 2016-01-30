//
//  ViewController.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/6/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var sloganView: UIView!
    let transition = ModelAnimator()
    var selectedFrame:CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sloganView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goToZone(sender: UIButton) {
        //let selfFrame:CGRect = sender.frame
        let tag4Btn:Int = sender.tag
        let btnFrame:CGRect = (sender.superview?.convertRect(sender.frame, toView: nil))!
        selectedFrame = btnFrame
        if tag4Btn == 1{
            let mystoryboard = UIStoryboard(name: "RunPane", bundle: nil)
            let nav = mystoryboard.instantiateViewControllerWithIdentifier("RunPane")
            nav.transitioningDelegate = self
            nav.view.backgroundColor = UIColor.grayColor()
            presentViewController(nav, animated: true) { () -> Void in
                
            }
            
        }else if(tag4Btn == 2){
            let mystoryboard = UIStoryboard(name: "RunPane", bundle: nil)
            let nav = mystoryboard.instantiateViewControllerWithIdentifier("RunPane") as! RunViewController
            nav.transitioningDelegate = self
            nav.view.backgroundColor = UIColor.grayColor()
            nav.musicListContainer.hidden = false
            presentViewController(nav, animated: true) { () -> Void in
                nav.playMusicBtn.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        }else if(tag4Btn == 3){
            let mystoryboard = UIStoryboard(name: "PastRun", bundle: nil)
            let nav = mystoryboard.instantiateViewControllerWithIdentifier("pastRun") as! PastRunViewController
            nav.transitioningDelegate = self
            presentViewController(nav, animated: true) { () -> Void in
                
            }
        }else if(tag4Btn == 4){
            let mystoryboard = UIStoryboard(name: "SettingPane", bundle: nil)
            let nav = mystoryboard.instantiateViewControllerWithIdentifier("SettingPane") as! SettingPaneViewController
            nav.transitioningDelegate = self
            presentViewController(nav, animated: true) { () -> Void in
                
            }
        }
        
    }

}
extension ViewController: UIViewControllerTransitioningDelegate{
    func animationControllerForPresentedController( presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.originFrame = selectedFrame!
        transition.presenting = true
        return transition
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }

}
