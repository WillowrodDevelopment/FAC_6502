//
//  6502+Addressing.swift
//  FAC_6502
//
//  Created by Mike Hall on 12/03/2025.
//

import FAC_Common

extension FAC_6502 {
    func fetchValue(mode: AddressingMode) -> AddressingValue {
        let byte2 = next(0x00)
        let byte3 = next(0x01)
        switch mode {
        case .accumilator:
            return AddressingValue(value: A, location: 0x00, cycles: 0)
        case .absolute:
            PC += 2
            let location = wordFrom(low: byte2, high: byte3)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .absoluteX:
            PC += 2
            let location = wordFrom(low: byte2, high: byte3) &+ UInt16(X)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .absoluteY:
            PC += 2
            let location = wordFrom(low: byte2, high: byte3) &+ UInt16(Y)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .immediate:
            PC += 1
            return AddressingValue(value: byte2, location: 0x00, cycles: 0)
        case .indirectX:
            PC += 1
            let byte2Value = byte2 &+ X
            let valueLow = memoryRead(page: 0, location: byte2Value)
            let valueHigh = memoryRead(page: 0, location: byte2Value &+ 1)
            let location = wordFrom(low: valueLow, high: valueHigh)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .indirectY:
            PC += 1
            let byte2Value = memoryRead(page: 0, location: byte2)
            let valueLow = byte2Value &+ Y
            let carry = valueLow < byte2Value ? 1 : 0
            let byte2Value2 = memoryRead(page: 0, location: byte2 &+ 1)
            let valueHigh = byte2Value2 &+ UInt8(carry)
            let location = wordFrom(low: valueLow, high: valueHigh)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .relative:
            PC += 1
            if (!P.isSet(bit: 7)){
                let page = PC.highByte()
                let twos = byte2.twosCompliment()
                PC = relativeJump(twos: twos)
                let pg = page != PC.highByte() ? 1 : 0
                return AddressingValue(value: 0x00, location: PC, cycles: 3 + pg)
            } else {
                return AddressingValue(value: 0x00, location: PC, cycles: 2)
            }
        case .zeroPage:
            PC += 1
            let location = UInt16(byte2)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .zeroPageX:
            PC += 1
            let location = UInt16(byte2 &+ X)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        case .zeroPageY:
            PC += 1
            let location = UInt16(byte2 &+ Y)
            return AddressingValue(value: memoryRead(from: location), location: location, cycles: 0)
        }
    }
}

public enum AddressingMode {
    case absolute, absoluteX, absoluteY, accumilator, immediate, indirectX, indirectY, relative, zeroPage, zeroPageX, zeroPageY
}

struct AddressingValue {
    let value: UInt8
    let location: UInt16
    let cycles: Int
}
