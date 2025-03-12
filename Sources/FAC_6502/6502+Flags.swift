//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 11/03/2025.
//

import Foundation

extension FAC_6502 {

    func resetAll() {
        P = 0x00
    }
    
    func setAll() {
        P = 0xD0
    }
    
    func set(_ masks: Int...) {
        var mask: UInt8 = 0x00
        for m in masks {
            mask = mask | 1 << m
        }
        P = P | mask
    }
    
    func reset(_ masks: Int...) {
        var mask: UInt8 = 0x00
        for m in masks {
            mask = mask | 1 << m
        }
        P = P & ~mask
    }
    
    func pCarry(isSet: Bool) {
        P = P.set(bit: 0, value: isSet)
    }
    
    func pZero(isSet: Bool) {
        P = P.set(bit: 1, value: isSet)
    }
    
    func pInterupt(isSet: Bool) {
        P = P.set(bit: 2, value: isSet)
    }
    
    func pDecimal(isSet: Bool) {
        P = P.set(bit: 3, value: isSet)
    }
    
    func pBreak(isSet: Bool) {
        P = P.set(bit: 4, value: isSet)
    }
    
    func pFive(isSet: Bool) {
        P = P.set(bit: 5, value: isSet)
    }
    
    func pOverflow(isSet: Bool) {
        P = P.set(bit: 6, value: isSet)
    }
    
    func pNegative(isSet: Bool) {
        P = P.set(bit: 7, value: isSet)
    }
    
    func bitValue(_ bit: Int) -> UInt8 {
        let mask = UInt8(1 << bit)
        return (P & mask) >> bit
    }
    
    func pMask(_ mask: Int) -> UInt8 {
        return P & UInt8(1 << mask)
    }
    
}
