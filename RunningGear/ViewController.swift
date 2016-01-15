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
        if tag4Btn == 1{
            let mystoryboard = UIStoryboard(name: "RunPane", bundle: nil)
            let nav = mystoryboard.instantiateViewControllerWithIdentifier("RunPane")
            //nav.transitioningDelegate = self
            nav.view.backgroundColor = UIColor.grayColor()

            presentViewController(nav, animated: true) { () -> Void in
                
            }
            
        }
        
    }

}

