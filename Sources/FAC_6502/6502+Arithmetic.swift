//
//  6502+Arithmetic.swift
//  FAC_6502
//
//  Created by Mike Hall on 13/03/2025.
//

public extension FAC_6502 {
    
    public func adc(_ a: UInt8, _ b: UInt8) -> UInt8 {
        let c = bitValue(carry)
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
        let reg_a_read = Int(a)
        let src = Int(b)
        let c16 = Int(c)
        var tmp_a: Int = 0x00
        var tmp = reg_a_read - src - c16
        if bitValue(decimal) > 0 {
            tmp_a = Int(reg_a_read & 0xf) - Int(src & 0xf) - Int(c16)
            if (tmp_a & 0x10 != 0) {
                tmp_a = ((tmp_a - 6) & 0xf) | ((reg_a_read & 0xf0) - (src & 0xf0) - 0x10)
            } else {
                tmp_a = (tmp_a & 0xf) | ((reg_a_read & 0xf0) - (src & 0xf0))
            }
            if (tmp_a & 0x100 != 0) {
                tmp_a -= 0x60
            }
        } else {
            tmp_a = tmp
        }
        pCarry(isSet: tmp >= 0x00)
        pZero(isSet: tmp & 0xff == 0)
        pNegative(isSet: (tmp & 0x80) != 0)
        pOverflow(isSet:((reg_a_read ^ tmp) & 0x80 != 0) && ((reg_a_read ^ src) & 0x80 != 0))
        return UInt8(tmp_a & 0xff)
    }
    
    public func cmp(_ a: UInt8, _ b: UInt8) {
        let reg_a_read = Int(a)
        let src = Int(b)
        var tmp_a: Int = 0x00
        var tmp = reg_a_read - src
        if bitValue(decimal) > 0 {
            tmp_a = Int(reg_a_read & 0xf) - Int(src & 0xf)
            if (tmp_a & 0x10 != 0) {
                tmp_a = ((tmp_a - 6) & 0xf) | ((reg_a_read & 0xf0) - (src & 0xf0) - 0x10)
            } else {
                tmp_a = (tmp_a & 0xf) | ((reg_a_read & 0xf0) - (src & 0xf0))
            }
            if (tmp_a & 0x100 != 0) {
                tmp_a -= 0x60
            }
        } else {
            tmp_a = tmp
        }
        pCarry(isSet: tmp >= 0x00)
        pZero(isSet: tmp & 0xff == 0)
        pNegative(isSet: (tmp & 0x80) != 0)
    }
}


