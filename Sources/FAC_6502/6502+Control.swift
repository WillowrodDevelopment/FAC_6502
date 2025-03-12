//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 07/03/2025.
//

import Foundation
import FAC_Common

extension FAC_6502 {
    
    func next() -> UInt8 {
        let opcode = memoryRead(from: PC)
        PC = PC &+ 1
        return opcode
    }
    
    func nextWord() -> UInt16 {
        let word = memoryReadWord(from: PC)
        PC = PC &+ 2
        return word
    }
    
    func next(_ offset: UInt16) -> UInt8 {
        return memoryRead(from: PC &+ offset)
    }
    
    func push(_ value: UInt8) {
        memoryWrite(page: 0x1, location: S, value: value)
        S = S &- 0x1
    }
    
    func push(_ value: UInt16) {
        memoryWrite(page: 0x1, location: S, value: value.highByte())
        S = S &- 0x1
        memoryWrite(page: 0x1, location: S, value: value.lowByte())
        S = S &- 0x1
    }
    
    func pop() -> UInt8 {
        S = S &+ 0x1
        return memoryRead(page: 0x1, location: S)
    }
    
    func popWord() -> UInt16 {
        S = S &+ 0x1
        let low = memoryRead(page: 0x1, location: S)
        S = S &+ 0x1
        let high = memoryRead(page: 0x1, location: S)
        return wordFrom(low: low, high: high)
    }
    
    func jumpToAddressAt(_ location: UInt16) {
        PC = memoryReadWord(from: 0xFFFE)
    }
    
    func relativeJump(twos: UInt8) -> UInt16 {
        return PC &+ UInt16(twos & 0x7f) &- UInt16(twos & 0x80)
    }
    
}
