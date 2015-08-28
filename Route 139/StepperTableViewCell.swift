//
//  StepperTableViewCell.swift
//  Route 139
//
//  Created by Wolney Mendes on 8/27/15.
//  Copyright (c) 2015 Wolney Mendes. All rights reserved.
//

import UIKit

class StepperTableViewCell: UITableViewCell {

    var values : Array<(intValue:Int, stringValue:String)>? {
        didSet {
            refreshUI()
        }
    }
    
    var value : Int? {
        didSet {
            refreshUI()
        }
    }
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var label: UILabel!

    
    @IBAction func onStepperValueChanged() {
        if let value = valueOf(Int(stepper!.value)) {
            self.value = value
        }
    }
    
    private func refreshUI() {
        if let v = value {
            if let idx = indexOf(v) {
                if let str = stringOf(idx) {
                    stepper.value = Double(idx)
                    stepper.maximumValue = Double(values!.count-1)
                    label.text = str
                }
            }
        }
        
    }
    
    private func indexOf( value: Int ) -> Int? {
        if let pairs = values {
            for var i=0; i<pairs.count; i++ {
                if pairs[i].intValue == value {
                    return i;
                }
            }
        }
        
        return nil
    }
    
    private func valueOf( index: Int ) -> Int? {
        if let pairs = values {
            if index < pairs.count {
                return pairs[index].intValue
            }
        }
        
        return nil
    }
    
    private func stringOf( index: Int ) -> String? {
        if let pairs = values {
            if index < pairs.count {
                return pairs[index].stringValue
            }
        }
        
        return nil
    }

}
