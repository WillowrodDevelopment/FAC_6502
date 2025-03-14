//
//  6502+Arithmetic.swift
//  FAC_6502
//
//  Created by Mike Hall on 13/03/2025.
//

public extension FAC_6502 {
    
    public func adc(_ a: UInt8, _ b: UInt8) -> UInt8 {
        let c = bitValue(carry)
        let intValue = Int(a) + Int(b) + Int(c)
        let reg_a_read = UInt16(a)
        let tmp_value = UInt16(b)
        let c16 = UInt16(c)
        var tmp: UInt16 = 0x00
        if bitValue(decimal) > 0 {
            // Taken from VICE source code.......
            /*
             tmp = (reg_a_read & 0xf) + (tmp_value & 0xf) + (reg_p & 0x1);                           \
             if (tmp > 0x9) {                                                                        \
             tmp += 0x6;                                                                         \
             }                                                                                       \
             if (tmp <= 0x0f) {                                                                      \
             tmp = (tmp & 0xf) + (reg_a_read & 0xf0) + (tmp_value & 0xf0);                       \
             } else {                                                                                \
             tmp = (tmp & 0xf) + (reg_a_read & 0xf0) + (tmp_value & 0xf0) + 0x10;                \
             }                                                                                       \
             LOCAL_SET_ZERO(!((reg_a_read + tmp_value + (reg_p & 0x1)) & 0xff));                     \
             LOCAL_SET_SIGN(tmp & 0x80);                                                             \
             LOCAL_SET_OVERFLOW(((reg_a_read ^ tmp) & 0x80)  && !((reg_a_read ^ tmp_value) & 0x80)); \
             if ((tmp & 0x1f0) > 0x90) {                                                             \
             tmp += 0x60;                                                                        \
             }                                                                                       \
             LOCAL_SET_CARRY((tmp & 0xff0) > 0xf0);
             */
            tmp = (reg_a_read & 0xf) + (tmp_value & 0xf) + c16
            if tmp > 0x9 {
                tmp += 0x6
            }
                        if tmp <= 0x0f {
                            tmp = (tmp & 0xf) + (reg_a_read & 0xf0) + (tmp_value & 0xf0)
                        } else {
                            tmp = (tmp & 0xf) + (reg_a_read & 0xf0) + (tmp_value & 0xf0) + 0x10
                        }
            pZero(isSet:((reg_a_read + tmp_value + c16) & 0xff == 0))
            pNegative(isSet: tmp & 0x80 != 0)
            pOverflow(isSet:((reg_a_read ^ tmp) & 0x80) != 0 && ((reg_a_read ^ tmp_value) & 0x80 == 0))
                        if (tmp & 0x1f0) > 0x90 {
                            tmp += 0x60
                        }
            pCarry(isSet:(tmp & 0xff0) > 0xf0)
            return UInt8(tmp & 0xff)
        } else {
         tmp = tmp_value + reg_a_read + c16
                        pZero(isSet: tmp & 0xFF == 0)
            pNegative(isSet: (tmp & 0x80) != 0)
            pOverflow(isSet:((reg_a_read ^ tmp_value) & 0x80 == 0)  && ((reg_a_read ^ tmp) & 0x80 != 0))
            pCarry(isSet: tmp > 0xff)
            return UInt8(tmp & 0xff)
        }
    }
    
    public func sbc(_ a: UInt8, _ b: UInt8) -> UInt8 {
        
        let c = bitValue(carry) > 0 ? 0 : 1
        let intValue = Int(a) - Int(b) - c
        if bitValue(decimal) > 0 {
            // BCD Subtraction.....
            // Following the instructions at http://www.6502.org/tutorials/decimal_mode.html#A
            
            // N & V flags are ignored....
            
            /*
             3a. AL = (A & $0F) - (B & $0F) + C-1
             3b. If AL < 0, then AL = ((AL - $06) & $0F) - $10
             3c. A = (A & $F0) - (B & $F0) + AL
             3d. If A < 0, then A = A - $60
             3e. The accumulator result is the lower 8 bits of A
             */
            
            var lowValue = Int(a & 0x0F) - Int(b & 0x0F) - Int(c)
            if lowValue < 0 {
                lowValue = ((lowValue - 0x06) & 0x0F) - Int(0x10)
            }
            var fullValue = Int(a & 0xF0) - Int(b & 0xF0) + lowValue
            if fullValue < 0 {
                fullValue -= 0x60
            }
            let finalValue = UInt8(fullValue & 0xFF)
            pCarry(isSet: fullValue >= 0)
            pOverflow(isSet: intValue > 127 || intValue < -127)
            pZero(isSet: finalValue == 0)
            pNegative(isSet: intValue < 0)
            return finalValue
        } else {
            let value = a &- b &- UInt8(c)
            pCarry(isSet: value >= 0)
            //pOverflow(isSet: value > 127) // || value.twosCompliment() > 127)
            //pOverflow(isSet: intValue > 127 || intValue < -127)
            //let ov = ((a ^ value) & (b ^ value) & 0x80) > 0
            let ov = Int(a) + b.twosComplimentAsInt() - c //a.twosComplimentAsInt() - b.twosComplimentAsInt() - UInt8(c).twosComplimentAsInt()   //UInt16(a.twosCompliment()) - UInt16(b.twosCompliment())
            //pOverflow(isSet: (ov & 0xFF) > 0x80)
            pOverflow(isSet: (ov & 0xFF) > 127 || (ov & 0xFF) < -127)
            pZero(isSet: value == 0)
            pNegative(isSet: intValue < 0)
            return value
        }
    }
}

