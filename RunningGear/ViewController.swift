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


}

