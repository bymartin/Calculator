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

    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()

    @IBAction func clear() {
        brain = CalculatorBrain()
        displayValue = nil
        history.text = ""
        userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
            let currentDisplay = display.text!
            if countElements(currentDisplay) > 1 {
                display.text = dropLast(currentDisplay)
             } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber && display.text != "0" {
            // If user types a . for a floating point number,
            // make sure there isn't already a "." present
            // If so, just return
            if digit == "." && display.text!.rangeOfString(".") != nil {
                return
            }
            if digit == "0" && display.text! == "-0" { return }
        display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
            if brain.description != "?" {
                history.text = brain.description
            } else {
                history.text = ""
            }
        }
        
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            
            // Handle special case of +/- when user is in the middle
            // of typing a number, in this case we don't want to 
            // enter(), we must change the sign and allow the user
            // to continue typing the number.
            if operation == "±" {
                let displayText = display.text!
                // If there is already a "-", take it off (now +)
                if displayText.rangeOfString("-") != nil {
                    display.text = dropFirst(displayText)
                } else {
                    display.text = "-" + displayText
                }
                return
            }
            enter()
        }
        
        if let result = brain.performOperation(operation) {
            displayValue = result
        } else {
            displayValue = nil
        }
        
        // If user types operation as first entry, 
        // won't display it in history
//        if history.text != nil {
//            history.text = history.text! + " " + operation
//        }

    }
    
    
    @IBAction func enter() {
        
//        if history.text == nil {
//            history.text = display.text!
//        } else {
//            history.text = history.text! + " " + display.text!
//        }
        

        
        userIsInTheMiddleOfTypingANumber = false
        // ok to unwrap displayValue below?
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    var displayValue: Double? {
        get {
//            if let displayText = display.text {
//                // we have valid text, now check if it is a number
//                if let displayNumber = NSNumberFormatter().numberFromString(displayText) {
//                    return displayNumber.doubleValue
//                }
//            }
//            return nil
            
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            
        }
        set {
            // magic newValue when displayValue is set
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                display.text = "0"
            }
            userIsInTheMiddleOfTypingANumber = false
            history.text = brain.description + " ="
        }
    }
    
    @IBAction func saveMemory(sender: UIButton) {
        // get variable from the button title
        if let variable = last(sender.currentTitle!) {
            // Make sure there is a value on the display to set
            if displayValue != nil {
                brain.variableValues["\(variable)"] = displayValue
                if let result = brain.evaluate() {
                    displayValue = result
                } else {
                    displayValue = nil
                }
            }
        }
        userIsInTheMiddleOfTypingANumber = false
    }

    @IBAction func loadMemory(sender: UIButton) {
        // first check if user was typing a number and hit enter
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let result = brain.pushOperand(sender.currentTitle!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
}

