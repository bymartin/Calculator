//
//  ViewController.swift
//  Calculator
//
//  Created by Barry Martin on 2/19/15.
//  Copyright (c) 2015 Barry Martin. All rights reserved.
//

import UIKit

class ViewController: UIViewController
 {
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false


    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        
        
    }

}

