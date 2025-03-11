//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 07/03/2025.
//

import Foundation
import FAC_Common

extension FAC_6502 {
    public func memoryWrite(to: UInt16, value: UInt8) {
        // Should protect ROM for Sinclair computers
//        switch to {
//        case ...0x3FFF:
//            // Write to ROM
//            // We don't REALLY want to do this......
//           // print("Cannot write to ROM!")
//            break
//        case ...0x7FFF:
//            // Write to screen
//            ram[5][Int(to - 0x4000)] = value
//        case ...0xBFFF:
//            // Write to fixed bank
//            ram[2][Int(to - 0x8000)] = value
//        default:
//            // Write to switchable bank
//            ram[ramSelected][Int(to - 0xC000)] = value
//        }
        ram[0][Int(to)] = value
    }
    
    func memoryRead(from: UInt16) -> UInt8 {
//        switch from {
//        case ...0x3FFF:
//            return rom[romSelected][Int(from)]
//        case ...0x7FFF:
//            // Read from screen
//            return ram[5][Int(from - 0x4000)]
//        case ...0xBFFF:
//            // Read from screen
//            return ram[2][Int(from - 0x8000)]
//        default:
//            // Read from screen
//            return ram[ramSelected][Int(from - 0xC000)]
//        }
        return ram[0][Int(from)]
    }
    
    public func memoryWrite(page: UInt8, location: UInt8, value: UInt8) {
        ram[0][Int(wordFrom(low: location, high: page))] = value
    }

    func memoryRead(page: UInt8, location: UInt8) -> UInt8 {
        return ram[0][Int(wordFrom(low: location, high: page))]
    }

    func memoryWriteWord(to: UInt16, value: UInt16) {
        memoryWrite(to: to, value: value.lowByte())
        memoryWrite(to: (to &+ 1), value: value.highByte())
    }

    func memoryReadWord(from: UInt16) -> UInt16 {
        let low = memoryRead(from: from)  //memory[Int(from)]
        let high = memoryRead(from: (from &+ 1)) //memory[Int(from &+ 1)]
        return (UInt16(high) * 256) + UInt16(low)
    }
    
    func resetMemory() {
        ram[0] = Array(repeating: 0, count: 0xFFFF)
    }
}
