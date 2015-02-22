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
            // If user types a . for a floating point number,
            // make sure there isn't already a "." present
            // If so, just return
            if digit == "." && display.text!.rangeOfString(".") != nil {
                return
            }
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        switch operation {
        case "×":   performOperation { $0 * $1 }
        case "÷":   performOperation { $1 / $0 }
        case "+":   performOperation { $0 + $1 }
        case "−":   performOperation { $1 - $0 }
        case "√":   performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "∏":   appendConstant(M_PI)
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
    
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
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
        }
    }
    

}

