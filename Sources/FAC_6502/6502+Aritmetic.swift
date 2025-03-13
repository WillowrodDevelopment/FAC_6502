//
//  6502+Aritmetic.swift
//  FAC_6502
//
//  Created by Mike Hall on 13/03/2025.
//

public extension FAC_6502 {
    
    public func adc(_ a: UInt8, _ b: UInt8) -> UInt8 {
        let c = bitValue(carry)
        if bitValue(decimal) > 0 {
            // BCD Addition.....
            // Following the instructions at http://www.6502.org/tutorials/decimal_mode.html#A
            
            // N & V flags are ignored....
            
            /*
             1a. AL = (A & $0F) + (B & $0F) + C
             1b. If AL >= $0A, then AL = ((AL + $06) & $0F) + $10
             1c. A = (A & $F0) + (B & $F0) + AL
             1d. Note that A can be >= $100 at this point
             1e. If (A >= $A0), then A = A + $60
             1f. The accumulator result is the lower 8 bits of A
             1g. The carry result is 1 if A >= $100, and is 0 if A < $100
             */
            
            var lowValue = (a & 0x0F) + (b & 0x0F) + c
            if lowValue >= 0x0A {
                lowValue = ((lowValue + 0x06) & 0x0F) + 0x10
            }
            var fullValue: UInt16 = UInt16(UInt16(a & 0xF0) + UInt16(b & 0xF0) + UInt16(lowValue))
            if fullValue >= 0xA0 {
                fullValue += 0x60
            }
            pCarry(isSet: fullValue >= 0x100)
            return UInt8(fullValue & 0xFF)
            
            
            
//            let aInt = Int(a.hex()) ?? 0
//            let bInt = Int(b.hex()) ?? 0
//            var value = aInt + bInt + Int(c)
//            if (value > 99) {
//                set carry bit!
//                value = value - 100
//            }
//            let hexVal = "\(value)"
//            return UInt8(hexVal, radix: 16) ?? 0x0
        } else {
            return a &+ b &+ c
        }
        return 0x00
    }
}

