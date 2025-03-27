//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 07/03/2025.
//

import Foundation
import FAC_Common

public extension FAC_6502 {
    
    func next() async -> UInt8 {
        let opcode = await internalMemoryRead(from: PC)
        PC = PC &+ 1
        return opcode
    }
    
    func nextWord() async -> UInt16 {
        let word = await internalMemoryReadWord(from: PC)
        PC = PC &+ 2
        return word
    }
    
    func next(_ offset: UInt16) async -> UInt8 {
        return await internalMemoryRead(from: PC &+ offset)
    }
    
    func push(_ value: UInt8) async {
        await memoryWrite(page: 0x1, location: S, value: value)
        S = S &- 0x1
    }
    
    func push(_ value: UInt16) async {
        await push(value.highByte())
        await push(value.lowByte())
    }
    
    func pop() async -> UInt8 {
        S = S &+ 0x1
        return await memoryRead(page: 0x1, location: S)
    }
    
    func popWord() async -> UInt16 {
        return await wordFrom(low: pop(), high: pop())
    }
    
    func jumpToAddressAt(_ location: UInt16) async {
        PC = await memoryReadWord(from: location)
    }
    
    func relativeJump(twos: UInt8) async -> UInt16 {
        if twos == 0x80 {
            return PC &- 0x80
        }
        return PC &- UInt16(twos & 0x7f) &+ UInt16(twos & 0x80)
    }
    
    func relativeJump(from: UInt16, twos: UInt8) async -> UInt16 {
        if twos == 0x80 {
            return from &- 0x80
        }
        return from &- UInt16(twos & 0x7f) &+ UInt16(twos & 0x80)
    }
    
}
