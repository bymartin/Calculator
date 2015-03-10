//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Barry Martin on 2/28/15.
//  Copyright (c) 2015 Barry Martin. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case NullaryOperation(String, () -> Double)
        case Variable(String)
        
        // Add computed property to allow to print as string
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .NullaryOperation(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
        
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.NullaryOperation("π", { M_PI }))
        learnOp(Op.UnaryOperation("±") { -$0 })
        
    }
    
    var program: AnyObject { // guaranteed to be a PropertyList
        get {
            return opStack.map{$0.description}
//            alternative way below
//            var returnValue = Array<String>()
//            for op in opStack {
//                returnValue.append(op.description)
//            }
//            return returnValue
            
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    func popOperand() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
    // Describe the contents of the brain as a String
    // While there is some stack left that has not been described, call the method
    // description to process the remaining stack
    var description: String {
        get {
            var (result, ops) = ("", opStack)
            while ops.count > 0 {
                var current: String?
                (current, ops) = description(ops)
                result = result == "" ? current! : "\(current!), \(result)"
            }
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            // start with last element
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                // %g removes trailing zeroes
                return (String(format: "%g", operand) , remainingOps)
            case .NullaryOperation(let symbol, _):
                return (symbol, remainingOps);
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = description(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = description(remainingOps)
                if var operand1 = op1Evaluation.result {
                    if remainingOps.count - op1Evaluation.remainingOps.count > 2 {
                        operand1 = "(\(operand1))"
                    }
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                return (symbol, remainingOps)
            }
        }
        return ("?", ops)
    }


    
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .NullaryOperation(_ , let operation):
                return (operation(), remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
        
    }
    
    func showStack() -> String? {
        return " ".join(opStack.map{ "\($0)" })
    }
}
