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
    var operandStack = Array<Double>()

    @IBAction func clear() {
        display.text = "0"
        history.text = ""
        userIsInTheMiddleOfTypingANumber = false
        operandStack = []
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
        
        // If user types operation as first entry, 
        // won't display it in history
        if history.text != nil {
            history.text = history.text! + " " + operation
        }
        
        switch operation {
        case "×":   performOperation { $0 * $1 }
        case "÷":   performOperation { $1 / $0 }
        case "+":   performOperation { $0 + $1 }
        case "−":   performOperation { $1 - $0 }
        case "√":   performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "π":   appendConstant( M_PI )
        case "±":   performOperation { -$0 }
        default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    func appendConstant(constant: Double) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        display.text = "\(constant)"
        enter()
    }
    
    func multiply(op1: Double, op2: Double) -> Double {
        return op1 * op2
    }
    
    @IBAction func enter() {
        
        if history.text == nil {
            history.text = display.text!
        } else {
            history.text = history.text! + " " + display.text!
        }
        
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        println("operandStack = \(operandStack)")
    }
    
    var displayValue: Double {
        get {
            // Need to figure out what below does!
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            // magic newValue when displayValue is set
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
            // display value is set when an operation button is pressed
            // so add "==" to end of the history label
            if history.text != nil {
                history.text = history.text! + " ="
            }
        }
    }
    

}

