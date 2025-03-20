//
//  6502+Addressing.swift
//  FAC_6502
//
//  Created by Mike Hall on 12/03/2025.
//

import FAC_Common

public extension FAC_6502 {
    func fetchValue(mode: AddressingMode, condition: Bool = false) -> AddressingValue {
        let byte2 = next(0x00)
        let byte3 = next(0x01)
        switch mode {
        case .accumilator:
            //print("\(oldPC.hex()): \(opCode.hex()) \(A.hex())")
            return AddressingValue(value: A, location: 0x00, cycles: 0)
        case .absolute:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex()) \(byte3.hex())")
            PC = PC &+ 2
            let location = wordFrom(low: byte2, high: byte3)
            let value = memoryRead(from: location)
            return AddressingValue(value: value, location: location, cycles: 0)
        case .absoluteIndirect:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex()) \(byte3.hex())")
            PC = PC &+ 2
            let locationLow = memoryRead(page: byte3, location: byte2)
            let locationHigh = memoryRead(page: byte3, location: byte2 &+ 1)
            return AddressingValue(value: 0x0, location: wordFrom(low: locationLow, high: locationHigh), cycles: 0)
        case .absoluteX:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex()) \(byte3.hex())")
            PC = PC &+ 2
            let address = wordFrom(low: byte2, high: byte3)
            let location = address &+ UInt16(X)
            let cycles = address.highByte() > location.highByte() ? 1 : 0
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: cycles)
        case .absoluteY:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex()) \(byte3.hex())")
            PC = PC &+ 2
            let address = wordFrom(low: byte2, high: byte3)
            let location = address &+ UInt16(Y)
            let cycles = address.highByte() > location.highByte() ? 1 : 0
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: cycles)
        case .immediate:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex())")
            PC = PC &+ 1
            return AddressingValue(value: byte2, location: 0x00, cycles: 0)
        case .indirectX:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex())")
            PC = PC &+ 1
            let byte2Value = byte2 &+ X
            let valueLow = memoryRead(page: 0, location: byte2Value)
            let valueHigh = memoryRead(page: 0, location: byte2Value &+ 1)
            let location = wordFrom(low: valueLow, high: valueHigh)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .indirectY:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex())")
            PC = PC &+ 1
            let byte2Value = memoryRead(page: 0, location: byte2)
            let valueLow = byte2Value &+ Y
            let carry = valueLow < byte2Value ? 1 : 0
            let byte2Value2 = memoryRead(page: 0, location: byte2 &+ 1)
            let valueHigh = byte2Value2 &+ UInt8(carry)
            let location = wordFrom(low: valueLow, high: valueHigh)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: carry)
        case .relative:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex())")
            PC = PC &+ 1
            if (condition){
                let page = PC.highByte()
                let twos = byte2.twosCompliment()
                PC = relativeJump(twos: twos)
                let pg = page != PC.highByte() ? 1 : 0
                return AddressingValue(value: 0x00, location: PC, cycles: 3 + pg)
            } else {
                return AddressingValue(value: 0x00, location: PC, cycles: 2)
            }
        case .zeroPage:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex())")
            PC = PC &+ 1
            let location = UInt16(byte2)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .zeroPageX:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex())")
            PC = PC &+ 1
            let location = UInt16(byte2 &+ X)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .zeroPageY:
            //print("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex())")
            PC = PC &+ 1
            let location = UInt16(byte2 &+ Y)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        }
    }
}

public enum AddressingMode {
    case absolute, absoluteIndirect, absoluteX, absoluteY, accumilator, immediate, indirectX, indirectY, relative, zeroPage, zeroPageX, zeroPageY
}

public struct AddressingValue {
    let value: UInt8
    let location: UInt16
    let cycles: Int
}
