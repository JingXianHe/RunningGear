//
//  PastRunCellTableViewCell.swift
//  RunningGear
//
//  Created by beihaiSellshou on 1/20/16.
//  Copyright © 2016 JXHDev. All rights reserved.
//

import UIKit

class PastRunCellTableViewCell: UITableViewCell {

    @IBOutlet weak var tempView: UIView!
    var pastRunDelegate:PastRunCellDelegate?
    var cellIndex:NSIndexPath?
    var index4Img:Int = 0
    @IBOutlet weak var RunTracksImgView: UIImageView!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var PaceLabel: UILabel!
    @IBOutlet weak var DurationLabel: UILabel!
    @IBOutlet weak var BadgeImgView: UIImageView!
    
    @IBOutlet weak var ShareBtn: UIButton!
    
 
    @IBAction func share2Public() {
        pastRunDelegate?.pastRunShare2Public(cellIndex!)
    }
    
    @IBAction func deleteRunData() {
        pastRunDelegate?.pastRunDeleteRecord(cellIndex!, InputIndex: index4Img)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
