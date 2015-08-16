//
//  FromTerminalCell.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/15/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import UIKit

class FromTerminalCell: UITableViewCell {
    
    var gate : String! {
        didSet {
            refreshUI()
        }
    }
    
    var title : String! {
        didSet{
            refreshUI()
        }
    }
    
    var subTitle : String! {
        didSet {
            refreshUI()
        }
    }

    @IBOutlet weak var gateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    func refreshUI() {
        gateLabel?.text = gate
        titleLabel?.text = title
        subTitleLabel?.text = subTitle
    }
}
