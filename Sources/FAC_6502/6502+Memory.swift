//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 07/03/2025.
//

import Foundation
import FAC_Common

public extension FAC_6502 {
    func internalMemoryWrite(to: UInt16, value: UInt8) async {
        await ram.poke(location: to, value: value)
    }
    
    func internalMemoryRead(from: UInt16) async -> UInt8 {
        return await ram.peek(location: from)
    }
    
    func memoryRead(from: Int, count: Int) async -> [UInt8] {
        return await ram.peekBlock(location: UInt16(from), count: count)
    }
    
    func memoryWrite(page: UInt8, location: UInt8, value: UInt8) async {
        
        await ram.poke(location: wordFrom(low: location, high: page), value: value)
    }

    func memoryRead(page: UInt8, location: UInt8) async -> UInt8 {
        return await ram.peek(location: wordFrom(low: location, high: page))
    }

    func memoryWriteWord(to: UInt16, value: UInt16) async {
        await memoryWrite(to: to, value: value.lowByte())
        await memoryWrite(to: (to &+ 1), value: value.highByte())
    }

    func memoryReadWord(from: UInt16) async -> UInt16 {
        let low = await memoryRead(from: from)
        let high = await memoryRead(from: (from &+ 1)) //memory[Int(from &+ 1)]
        return wordFrom(low: low, high: high)
    }
    
    func internalMemoryReadWord(from: UInt16) async -> UInt16 {
        let low = await internalMemoryRead(from: from)
        let high = await internalMemoryRead(from: (from &+ 1)) //memory[Int(from &+ 1)]
        return (UInt16(high) * 256) + UInt16(low)
    }
    
    func resetMemory() async {
        await ram.reset()
    }
}
