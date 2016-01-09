//
//  JXHButton.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/8/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit

class JXHButton: UIButton {

    var imgLength:CGFloat = 40.0
    var insetTop:CGFloat = 10.0
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 15.0
        let result:CGSize = UIScreen.mainScreen().bounds.size
        if(result.height == 480)
        {
            //Load 3.5 inch xib
            imgLength = 35.0
            insetTop = 5.0
        }else if(result.height > 735){
            imgLength = 50.0
            insetTop = 10.0
        }
        let btnFrame = self.frame
        self.imageView?.frame = CGRectMake(btnFrame.width/2 - imgLength/2, insetTop, imgLength, imgLength)
        self.titleLabel?.frame = CGRectMake(0, imgLength+insetTop, btnFrame.width, btnFrame.height - imgLength - insetTop)
        self.titleLabel?.textAlignment = NSTextAlignment.Center
    }

}
