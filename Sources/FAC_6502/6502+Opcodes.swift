//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 07/03/2025.
//

import Foundation
import FAC_Common

extension FAC_6502 {
    
    public func fetchAndExecute() {
        let oldPC = PC
        let opCode = next()
        var ts = 2
        var mCycles = 2
        switch opCode {
            
            
        case 0x00:  // BRK impl
            // Current understanding - BRK forces an IRQ interupt
            // PC+2 is added to the stack for return and then PC jumps to the address found at WORD 0xFFFE
            // See https://en.wikipedia.org/wiki/Interrupts_in_65xx_processors
            // Sets five and brk flags
            push(PC &+ 0x1)
            jumpToAddressAt(0xFFFE)
            set(brk, five)
            push(P)
            mCycles = 7
            
        case 0x01:  // ORA X,ind
            // Current understanding - ORA X,ind Or's 'A' with the page 0 contents of location ((X + Byte 2 + 1 (high)) (X + Byte 2 (low)))
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = fetchValue(mode: .indirectX).value
            A = A | value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            
        case 0x05:  // ORA zpg
            // Current understanding - ORA ZPG Or's 'A' with the page 0 contents of byte 2
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = fetchValue(mode: .zeroPage).value
            A = A | value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            
        case 0x06:  // ASL zpg
            // Current understanding - ASL zpg shifts the bits of the page 0 contents of byte 2 1 place left
            // A is unaffected
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ASL
            // Updates Negative, Zero and Carry flags
            let addressedValue = fetchValue(mode: .zeroPage)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            let shiftedValue = value << 1
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            
        case 0x08:  // PHP impl
            // Current understanding - PHP simple pushes the status flag (P) to the stack
            // A is unaffected
            // See https://www.pagetable.com/c64ref/6502/?tab=2#PHP
            // Flags are not affected
            pBreak(isSet: true)
            push(P)
            mCycles = 3
            
        case 0x09:  // ORA #
            // Current understanding - ORA # Or's 'A' with byte 2
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = next()
            A = A | value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            
        case 0x0A:  // ASL A
            // Current understanding - ASL A shifts the bits of the Accumulator 1 place left
            // A contains bit shifted value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ASL
            // Updates Negative, Zero and Carry flags
            let carryOut = (A & 0x80) != 0
            A = A << 1
            pCarry(isSet: carryOut)
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x0D:  // ORA abs
            // Current understanding - ORA abs Or's 'A' with the location of the word at (byte 3 (high) byte 2 (low)
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = fetchValue(mode: .absolute).value
            A = A | value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0x0E:  // ASL abs
            // Current understanding - ASL abs shifts the bits of the word at (byte 3 (high) byte 2 (low)) 1 place left
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let addressedValue = fetchValue(mode: .absolute)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            let shiftedValue = value << 1
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            
        case 0x10:  // BPL rel
            // Current understanding - BPL branches to PC + (byte 2(2s compliment)) if the status flag 'Negative' is not set
            // See https://www.pagetable.com/c64ref/6502/?tab=2#BPL
            // Flags are not affected
            print("Flag: \(P.bin())")
            let value = fetchValue(mode: .relative, condition: !P.isSet(bit: negative))
            mCycles = value.cycles
            
        case 0x11:  // ORA ind,Y
            // Current understanding - ORA ind,Y Or's 'A' with the page 0 contents of location ((Y + Byte 2 + 1 + carry (high)) (Y + Byte 2) (low))
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = fetchValue(mode: .indirectY)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            
        case 0x15:  // ORA zpg,X
            let value = fetchValue(mode: .zeroPageX).value
            A = A | value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0x16:  // ASL zpg,X
            let addressedValue = fetchValue(mode: .zeroPageX)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            let shiftedValue = value << 1
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 4
            
        case 0x18:  // CLC impl
            reset(carry)
            mCycles = 2
            
        case 0x19:  // ORA abs,Y
            let value = fetchValue(mode: .absoluteY)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0x1D:  // ORA abs,X
            let value = fetchValue(mode: .absoluteX)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0x1E:  // ASL abs,X
            let addressedValue = fetchValue(mode: .absoluteX)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            let shiftedValue = value << 1
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 7
            
        case 0x20:  // JSR abs
            push(PC + 1)
            let value = fetchValue(mode: .absolute)
            PC = value.location
            
        case 0x21:  // AND X,ind
            let value = fetchValue(mode: .indirectX).value
            A = A & value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            
        case 0x24:  // BIT zpg
            let value = fetchValue(mode: .zeroPage).value
            let result = A & value
            pZero(isSet: result == 0)
            pNegative(isSet: (value & 0x80) != 0)
            pOverflow(isSet: (value & 0x40) != 0)
            mCycles = 3
            
        case 0x25:  // AND zpg
            let value = fetchValue(mode: .zeroPage).value
            A = A & value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            
        case 0x26:  // ROL zpg
            let addressedValue = fetchValue(mode: .zeroPage)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            var shiftedValue = value << 1
            shiftedValue = shiftedValue.set(bit: 0, value: P.isSet(bit: carry))
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            
        case 0x28:  // PLP impl
            P = pop()
            mCycles = 4
            
        case 0x29:  // AND #
            let value = fetchValue(mode: .immediate).value
            A = A & value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x2A:  // ROL A
            let carryOut = (A & 0x80) != 0
            var newA = A << 1
            newA = newA.set(bit: 0, value: P.isSet(bit: carry))
            A = newA
            pCarry(isSet: carryOut)
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x2C:  // BIT abs
            let value = fetchValue(mode: .absolute).value
            let result = A & value
            pZero(isSet: result == 0)
            pNegative(isSet: (value & 0x80) != 0)
            pOverflow(isSet: (value & 0x40) != 0)
            mCycles = 4
            
        case 0x2D:  // AND abs
            let value = fetchValue(mode: .absolute).value
            A = A & value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0x2E:  // ROL abs
            let addressedValue = fetchValue(mode: .absolute)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            var shiftedValue = value << 1
            shiftedValue = shiftedValue.set(bit: 0, value: P.isSet(bit: carry))
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            
        case 0x30:  // BMI rel
            let value = fetchValue(mode: .relative, condition: P.isSet(bit: negative))
            mCycles = value.cycles
            
        case 0x31:  // AND ind,Y
            let value = fetchValue(mode: .indirectY)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            
        case 0x35:  // AND zpg,X
            let value = fetchValue(mode: .zeroPageX)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            
        case 0x36:  // ROL zpg,X
            let addressedValue = fetchValue(mode: .zeroPageX)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            var shiftedValue = value << 1
            shiftedValue = shiftedValue.set(bit: 0, value: P.isSet(bit: carry))
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            
        case 0x38:  // SEC impl
            set(carry)
            mCycles = 2
            
        case 0x39:  // AND abs,Y
            print(opCode)
            
        case 0x3D:  // AND abs,X
            print(opCode)
            
        case 0x3E:  // ROL abs,X
            let addressedValue = fetchValue(mode: .absoluteX)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            var shiftedValue = value << 1
            shiftedValue = shiftedValue.set(bit: 0, value: P.isSet(bit: carry))
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 7
            
        case 0x40:  // RTI impl
            P = pop()
            PC = popWord()
            mCycles = 6
            
        case 0x41:  // EOR X,ind
            let value = fetchValue(mode: .indirectX).value
            A = A ^ value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            
        case 0x45:  // EOR zpg
            let value = fetchValue(mode: .zeroPage).value
            A = A ^ value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            
        case 0x46:  // LSR zpg
            let addressedValue = fetchValue(mode: .zeroPage)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            let shiftedValue = value >> 1
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            
        case 0x48:  // PHA impl
            push(A)
            mCycles = 3
            
        case 0x49:  // EOR #
            let value = fetchValue(mode: .immediate).value
            A = A ^ value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x4A:  // LSR A
            let carryOut = (A & 0x01) != 0
            A = A >> 1
            pCarry(isSet: carryOut)
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x4C:  // JMP abs
            PC = fetchValue(mode: .absolute).location
            mCycles = 3
            
        case 0x4D:  // EOR abs
            let value = fetchValue(mode: .absolute).value
            A = A ^ value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0x4E:  // LSR abs
            let addressedValue = fetchValue(mode: .absolute)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            let shiftedValue = value >> 1
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            
        case 0x50:  // BVC rel
            let value = fetchValue(mode: .relative, condition: !P.isSet(bit: overflow))
            mCycles = value.cycles
            
        case 0x51:  // EOR ind,Y
            let value = fetchValue(mode: .indirectY)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            
        case 0x55:  // EOR zpg,X
            let value = fetchValue(mode: .zeroPageX)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0x56:  // LSR zpg,X
            let addressedValue = fetchValue(mode: .zeroPageX)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            let shiftedValue = value >> 1
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            
        case 0x58:  // CLI impl
            reset(interupt)
            mCycles = 2
            
        case 0x59:  // EOR abs,Y
            let value = fetchValue(mode: .absoluteY)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0x5D:  // EOR abs,X
            let value = fetchValue(mode: .absoluteX)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0x5E:  // LSR abs,X
            let addressedValue = fetchValue(mode: .absoluteX)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            let shiftedValue = value >> 1
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            
        case 0x60:  // RTS impl
            var stackWord = popWord()
            PC = stackWord &+ 1
            
        case 0x61:  // ADC X,ind
            let value = fetchValue(mode: .indirectX)
            let carryBit = bitValue(carry)
            let changeValue = value.value &+ carryBit
            let newA = A &+ changeValue
            let carryValue = (newA < A || (newA == A && carryBit > 0))
            pCarry(isSet: carryValue)
            let overflowValue = changeValue.isSet(bit: 7) != newA.isSet(bit: 7)
            pOverflow(isSet: overflowValue)
            A = newA
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            
        case 0x65:  // ADC zpg
            let value = fetchValue(mode: .zeroPage)
            let carryBit = bitValue(carry)
            let changeValue = value.value &+ carryBit
            let newA = A &+ changeValue
            let carryValue = (newA < A || (newA == A && carryBit > 0))
            pCarry(isSet: carryValue)
            let overflowValue = changeValue.isSet(bit: 7) != newA.isSet(bit: 7)
            pOverflow(isSet: overflowValue)
            A = newA
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            
        case 0x66:  // ROR zpg
            let addressedValue = fetchValue(mode: .zeroPage)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            
        case 0x68:  // PLA impl
            print(opCode)
            
        case 0x69:  // ADC #
            let value = fetchValue(mode: .immediate)
            let carryBit = bitValue(carry)
            let changeValue = value.value &+ carryBit
            let newA = A &+ changeValue
            let carryValue = (newA < A || (newA == A && carryBit > 0))
            pCarry(isSet: carryValue)
            let overflowValue = changeValue.isSet(bit: 7) != newA.isSet(bit: 7)
            pOverflow(isSet: overflowValue)
            A = newA
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x6A:  // ROR A
            let addressedValue = fetchValue(mode: .accumilator)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            A = shiftedValue
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 2
            
        case 0x6C:  // JMP ind
            PC = fetchValue(mode: .absoluteIndirect).location
            mCycles = 5
            
        case 0x6D:  // ADC abs
            let value = fetchValue(mode: .absolute)
            let carryBit = bitValue(carry)
            let changeValue = value.value &+ carryBit
            let newA = A &+ changeValue
            let carryValue = (newA < A || (newA == A && carryBit > 0))
            pCarry(isSet: carryValue)
            let overflowValue = changeValue.isSet(bit: 7) != newA.isSet(bit: 7)
            pOverflow(isSet: overflowValue)
            A = newA
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0x6E:  // ROR abs
            let addressedValue = fetchValue(mode: .absolute)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            
        case 0x70:  // BVS rel
            let value = fetchValue(mode: .relative, condition: P.isSet(bit: overflow))
            mCycles = value.cycles
            
        case 0x71:  // ADC ind,Y
            let value = fetchValue(mode: .indirectY)
            let carryBit = bitValue(carry)
            let changeValue = value.value &+ carryBit
            let newA = A &+ changeValue
            let carryValue = (newA < A || (newA == A && carryBit > 0))
            pCarry(isSet: carryValue)
            let overflowValue = changeValue.isSet(bit: 7) != newA.isSet(bit: 7)
            pOverflow(isSet: overflowValue)
            A = newA
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            
        case 0x75:  // ADC zpg,X
            let value = fetchValue(mode: .zeroPageX)
            let carryBit = bitValue(carry)
            let changeValue = value.value &+ carryBit
            let newA = A &+ changeValue
            let carryValue = (newA < A || (newA == A && carryBit > 0))
            pCarry(isSet: carryValue)
            let overflowValue = changeValue.isSet(bit: 7) != newA.isSet(bit: 7)
            pOverflow(isSet: overflowValue)
            A = newA
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0x76:  // ROR zpg,X
            let addressedValue = fetchValue(mode: .zeroPageX)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            
        case 0x78:  // SEI impl
            set(interupt)
            mCycles = 2
            
        case 0x79:  // ADC abs,Y
            let value = fetchValue(mode: .absoluteY)
            let carryBit = bitValue(carry)
            let changeValue = value.value &+ carryBit
            let newA = A &+ changeValue
            let carryValue = (newA < A || (newA == A && carryBit > 0))
            pCarry(isSet: carryValue)
            let overflowValue = changeValue.isSet(bit: 7) != newA.isSet(bit: 7)
            pOverflow(isSet: overflowValue)
            A = newA
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0x7D:  // ADC abs,X
            let value = fetchValue(mode: .absoluteX)
            let carryBit = bitValue(carry)
            let changeValue = value.value &+ carryBit
            let newA = A &+ changeValue
            let carryValue = (newA < A || (newA == A && carryBit > 0))
            pCarry(isSet: carryValue)
            let overflowValue = changeValue.isSet(bit: 7) != newA.isSet(bit: 7)
            pOverflow(isSet: overflowValue)
            A = newA
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0x7E:  // ROR abs,X
            let addressedValue = fetchValue(mode: .absoluteX)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 7
            
        case 0x81:  // STA X,ind
            let value = fetchValue(mode: .indirectX)
            memoryWrite(to: value.location, value: A)
            mCycles = 6
            
        case 0x84:  // STY zpg
            let value = fetchValue(mode: .zeroPage)
            memoryWrite(to: value.location, value: Y)
            mCycles = 3
            
        case 0x85:  // STA zpg
            let value = fetchValue(mode: .zeroPage)
            memoryWrite(to: value.location, value: A)
            mCycles = 3
            
        case 0x86:  // STX zpg
            let value = fetchValue(mode: .zeroPage)
            memoryWrite(to: value.location, value: X)
            mCycles = 3
            
        case 0x88:  // DEY impl
            Y = Y &- 1
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 2
            
        case 0x8A:  // TXA impl
            A = X
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x8C:  // STY abs
            let value = fetchValue(mode: .absolute)
            memoryWrite(to: value.location, value: Y)
            mCycles = 4
            
        case 0x8D:  // STA abs
            let value = fetchValue(mode: .absolute)
            memoryWrite(to: value.location, value: A)
            mCycles = 4
            
        case 0x8E:  // STX abs
            let value = fetchValue(mode: .absolute)
            memoryWrite(to: value.location, value: X)
            mCycles = 4
            
        case 0x90:  // BCC rel
            let value = fetchValue(mode: .relative, condition: !P.isSet(bit: carry))
            mCycles = value.cycles
            
        case 0x91:  // STA ind,Y
            let value = fetchValue(mode: .indirectY)
            memoryWrite(to: value.location, value: A)
            mCycles = 6
            
        case 0x94:  // STY zpg,X
            let value = fetchValue(mode: .zeroPageX)
            memoryWrite(to: value.location, value: Y)
            mCycles = 4
            
        case 0x95:  // STA zpg,X
            let value = fetchValue(mode: .zeroPageX)
            memoryWrite(to: value.location, value: A)
            mCycles = 4
            
        case 0x96:  // STX zpg,Y
            let value = fetchValue(mode: .zeroPageY)
            memoryWrite(to: value.location, value: X)
            mCycles = 4
            
        case 0x98:  // TYA impl
            A = Y
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x99:  // STA abs,Y
            let value = fetchValue(mode: .absoluteY)
            memoryWrite(to: value.location, value: A)
            mCycles = 5
            
        case 0x9A:  // TXS impl
            push(X)
            mCycles = 2
            
        case 0x9D:  // STA abs,X
            let value = fetchValue(mode: .absoluteX)
            memoryWrite(to: value.location, value: A)
            mCycles = 5
            
        case 0xA0:  // LDY #
            Y = fetchValue(mode: .immediate).value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 2
            
        case 0xA1:  // LDA X,ind
            A = fetchValue(mode: .indirectX).value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            
        case 0xA2:  // LDX #
            X = fetchValue(mode: .immediate).value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 2
            
        case 0xA4:  // LDY zpg
            Y = fetchValue(mode: .zeroPage).value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 3
            
        case 0xA5:  // LDA zpg
            A = fetchValue(mode: .zeroPage).value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            
        case 0xA6:  // LDX zpg
            X = fetchValue(mode: .zeroPage).value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 3
            
        case 0xA8:  // TAY impl
            print(opCode)
            
        case 0xA9:  // LDA #
            A = fetchValue(mode: .immediate).value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0xAA:  // TAX impl
            print(opCode)
            
        case 0xAC:  // LDY abs
            Y = fetchValue(mode: .absolute).value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 4
            
        case 0xAD:  // LDA abs
            A = fetchValue(mode: .absolute).value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0xAE:  // LDX abs
            X = fetchValue(mode: .absolute).value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 4
            
        case 0xB0:  // BCS rel
            let value = fetchValue(mode: .relative, condition: P.isSet(bit: carry))
            mCycles = value.cycles
            
        case 0xB1:  // LDA ind,Y
            let value = fetchValue(mode: .indirectY)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            
        case 0xB4:  // LDY zpg,X
            Y = fetchValue(mode: .zeroPageX).value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 4
            
        case 0xB5:  // LDA zpg,X
            A = fetchValue(mode: .zeroPageX).value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            
        case 0xB6:  // LDX zpg,Y
            X = fetchValue(mode: .zeroPageY).value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 4
            
        case 0xB8:  // CLV impl
            reset(overflow)
            mCycles = 2
            
        case 0xB9:  // LDA abs,Y
            let value = fetchValue(mode: .absoluteY)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0xBA:  // TSX impl
            X = P
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 2
            
        case 0xBC:  // LDY abs,X
            let value = fetchValue(mode: .absoluteX)
            Y = value.value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0xBD:  // LDA abs,X
            let value = fetchValue(mode: .absoluteX)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0xBE:  // LDX abs,Y
            let value = fetchValue(mode: .absoluteY)
            X = value.value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 4 + value.cycles
            
        case 0xC0:  // CPY #
            let value = fetchValue(mode: .immediate).value
            pCarry(isSet: Y >= value)
            pZero(isSet: Y == value)
            pNegative(isSet: Y < value)
            mCycles = 2
            
            
        case 0xC1:  // CMP X,ind
            let value = fetchValue(mode: .indirectX).value
            pCarry(isSet: A >= value)
            pZero(isSet: A == value)
            pNegative(isSet: A < value)
            mCycles = 6
            
        case 0xC4:  // CPY zpg
            let value = fetchValue(mode: .zeroPage).value
            pCarry(isSet: Y >= value)
            pZero(isSet: Y == value)
            pNegative(isSet: Y < value)
            mCycles = 3
            
        case 0xC5:  // CMP zpg
            let value = fetchValue(mode: .zeroPage).value
            pCarry(isSet: A >= value)
            pZero(isSet: A == value)
            pNegative(isSet: A < value)
            mCycles = 3
            
        case 0xC6:  // DEC zpg
            let addressedValue = fetchValue(mode: .zeroPage)
            let value = addressedValue.value &- 1
            memoryWrite(to: addressedValue.location, value: value)
            pZero(isSet: value == 0)
            pNegative(isSet: (value & 0x80) != 0)
            mCycles = 5
            
        case 0xC8:  // INY impl
            Y = Y &+ 1
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 2
            
        case 0xC9:  // CMP #
            let value = fetchValue(mode: .immediate).value
            pCarry(isSet: A >= value)
            pZero(isSet: A == value)
            pNegative(isSet: A < value)
            mCycles = 2
            
        case 0xCA:  // DEX impl
            X = X &- 1
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 2
            
        case 0xCC:  // CPY abs
            let value = fetchValue(mode: .absolute).value
            pCarry(isSet: Y >= value)
            pZero(isSet: Y == value)
            pNegative(isSet: Y < value)
            mCycles = 4
            
        case 0xCD:  // CMP abs
            let value = fetchValue(mode: .absolute).value
            pCarry(isSet: A >= value)
            pZero(isSet: A == value)
            pNegative(isSet: A < value)
            mCycles = 4
            
        case 0xCE:  // DEC abs
            let addressedValue = fetchValue(mode: .absolute)
            let value = addressedValue.value &- 1
            memoryWrite(to: addressedValue.location, value: value)
            pZero(isSet: value == 0)
            pNegative(isSet: (value & 0x80) != 0)
            mCycles = 6
            
        case 0xD0:  // BNE rel
            let value = fetchValue(mode: .relative, condition: !P.isSet(bit: zero))
            mCycles = value.cycles
            
        case 0xD1:  // CMP ind,Y
            let addressingValue = fetchValue(mode: .indirectY)
            let value = addressingValue.value
            pCarry(isSet: A >= value)
            pZero(isSet: A == value)
            pNegative(isSet: A < value)
            mCycles = 5 + addressingValue.cycles
            
        case 0xD5:  // CMP zpg,X
            let value = fetchValue(mode: .zeroPageX).value
            pCarry(isSet: A >= value)
            pZero(isSet: A == value)
            pNegative(isSet: A < value)
            mCycles = 4
            
        case 0xD6:  // DEC zpg,X
            let addressedValue = fetchValue(mode: .zeroPageX)
            let value = addressedValue.value &- 1
            memoryWrite(to: addressedValue.location, value: value)
            pZero(isSet: value == 0)
            pNegative(isSet: (value & 0x80) != 0)
            mCycles = 6
            
        case 0xD8:  // CLD impl
            reset(decimal)
            mCycles = 2
            
        case 0xD9:  // CMP abs,Y
            let addressingValue = fetchValue(mode: .absoluteY)
            let value = addressingValue.value
            pCarry(isSet: A >= value)
            pZero(isSet: A == value)
            pNegative(isSet: A < value)
            mCycles = 4 + addressingValue.cycles
            
        case 0xDD:  // CMP abs,X
            let addressingValue = fetchValue(mode: .absoluteX)
            let value = addressingValue.value
            pCarry(isSet: A >= value)
            pZero(isSet: A == value)
            pNegative(isSet: A < value)
            mCycles = 4 + addressingValue.cycles
            
        case 0xDE:  // DEC abs,X
            let addressedValue = fetchValue(mode: .absoluteX)
            let value = addressedValue.value &- 1
            memoryWrite(to: addressedValue.location, value: value)
            pZero(isSet: value == 0)
            pNegative(isSet: (value & 0x80) != 0)
            mCycles = 7
            
        case 0xE0:  // CPX #
            let value = fetchValue(mode: .immediate).value
            pCarry(isSet: X >= value)
            pZero(isSet: X == value)
            pNegative(isSet: X < value)
            mCycles = 2
            
        case 0xE1:  // SBC X,ind
            let borrow = 1 - bitValue(carry)
            let value = fetchValue(mode: .immediate).value &+ borrow
            let twos = value.twosCompliment()
            
            pCarry(isSet: X >= value)
            pZero(isSet: X == value)
            pNegative(isSet: X < value)
            mCycles = 2
            
            
        case 0xE4:  // CPX zpg
            let value = fetchValue(mode: .zeroPage).value
            pCarry(isSet: X >= value)
            pZero(isSet: X == value)
            pNegative(isSet: X < value)
            mCycles = 3
            
        case 0xE5:  // SBC zpg
            print(opCode)
            
        case 0xE6:  // INC zpg
            print(opCode)
            
        case 0xE8:  // INX impl
            X = X &+ 1
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 2
            
        case 0xE9:  // SBC #
            print(opCode)
            
        case 0xEA:  // NOP impl
            print(opCode)
            
        case 0xEC:  // CPX abs
            let value = fetchValue(mode: .absolute).value
            pCarry(isSet: X >= value)
            pZero(isSet: X == value)
            pNegative(isSet: X < value)
            mCycles = 4
            
        case 0xED:  // SBC abs
            print(opCode)
            
        case 0xEE:  // INC abs
            print(opCode)
            
        case 0xF0:  // BEQ rel
            let value = fetchValue(mode: .relative, condition: P.isSet(bit: zero))
            mCycles = value.cycles
            
        case 0xF1:  // SBC ind,Y
            print(opCode)
            
        case 0xF5:  // SBC zpg,X
            print(opCode)
            
        case 0xF6:  // INC zpg,X
            print(opCode)
            
        case 0xF8:  // SED impl
            set(decimal)
            mCycles = 2
            
        case 0xF9:  // SBC abs,Y
            print(opCode)
            
        case 0xFD:  // SBC abs,X
            print(opCode)
            
        case 0xFE:  // INC abs,X
            print(opCode)
            
        default:
            break
        }
        
        cycleCount += mCycles
        //  mCyclesAndTStates(m: mCycles, t: ts)
        // Task {
        //     LoggingService.shared.logProcessor(oldPC, opCode: opCode.hex(), message: nil)
        //  }
    }
}
