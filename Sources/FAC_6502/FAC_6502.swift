//
//  650x.swift
//  FAC_650x
//
//  Created by Mike Hall on 06/03/2025.
//

import Foundation

public class FAC_6502 {
    
    public var rom:[[UInt8]] = []
    public var ram:[[UInt8]] = [Array(repeating: 0x00, count: 0x10000)]
    
    // Accumilator
    public var A: UInt8 = 0x00
    // Flags
    public var P: UInt8 = 0x00     //   NV-BDIZC
    // Control Registers
    public var PC: UInt16 = 0x00
    public var S: UInt8 = 0xFF
    // Index Registers
    public var X: UInt8 = 0x00
    public var Y: UInt8 = 0x00
    
    public init() {
    }
    
    public func test() {
        print("6502 CPU")
    }
    
    public func test1() -> Int {
        return 6502
    }
}
