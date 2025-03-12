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
            push(P)
            push(PC &+ 0x1)
            jumpToAddressAt(0xFFFE)
            set(brk, five)
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
            PC = popWord()
            P = pop()
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
            print(opCode)
            
        case 0x4D:  // EOR abs
            print(opCode)
            
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
            print(opCode)
            
        case 0x51:  // EOR ind,Y
            print(opCode)
            
        case 0x55:  // EOR zpg,X
            print(opCode)
            
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
            print(opCode)
            
        case 0x59:  // EOR abs,Y
            print(opCode)
            
        case 0x5D:  // EOR abs,X
            print(opCode)
            
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
            print(opCode)
            
        case 0x65:  // ADC zpg
            print(opCode)
            
        case 0x66:  // ROR zpg
            print(opCode)
            
        case 0x68:  // PLA impl
            print(opCode)
            
        case 0x69:  // ADC #
            print(opCode)
            
        case 0x6A:  // ROR A
            print(opCode)
            
        case 0x6C:  // JMP ind
            print(opCode)
            
        case 0x6D:  // ADC abs
            print(opCode)
            
        case 0x6E:  // ROR abs
            print(opCode)
            
        case 0x70:  // BVS rel
            print(opCode)
            
        case 0x71:  // ADC ind,Y
            print(opCode)
            
        case 0x75:  // ADC zpg,X
            print(opCode)
            
        case 0x76:  // ROR zpg,X
            print(opCode)
            
        case 0x78:  // SEI impl
            print(opCode)
            
        case 0x79:  // ADC abs,Y
            print(opCode)
            
        case 0x7D:  // ADC abs,X
            print(opCode)
            
        case 0x7E:  // ROR abs,X
            print(opCode)
            
        case 0x81:  // STA X,ind
            print(opCode)
            
        case 0x84:  // STY zpg
            print(opCode)
            
        case 0x85:  // STA zpg
            print(opCode)
            
        case 0x86:  // STX zpg
            print(opCode)
            
        case 0x88:  // DEY impl
            print(opCode)
            
        case 0x8A:  // TXA impl
            print(opCode)
            
        case 0x8C:  // STY abs
            print(opCode)
            
        case 0x8D:  // STA abs
            print(opCode)
            
        case 0x8E:  // STX abs
            print(opCode)
            
        case 0x90:  // BCC rel
            print(opCode)
            
        case 0x91:  // STA ind,Y
            print(opCode)
            
        case 0x94:  // STY zpg,X
            print(opCode)
            
        case 0x95:  // STA zpg,X
            print(opCode)
            
        case 0x96:  // STX zpg,Y
            print(opCode)
            
        case 0x98:  // TYA impl
            print(opCode)
            
        case 0x99:  // STA abs,Y
            print(opCode)
            
        case 0x9A:  // TXS impl
            print(opCode)
            
        case 0x9D:  // STA abs,X
            print(opCode)
            
        case 0xA0:  // LDY #
            print(opCode)
            
        case 0xA1:  // LDA X,ind
            print(opCode)
            
        case 0xA2:  // LDX #
            print(opCode)
            
        case 0xA4:  // LDY zpg
            print(opCode)
            
        case 0xA5:  // LDA zpg
            print(opCode)
            
        case 0xA6:  // LDX zpg
            print(opCode)
            
        case 0xA8:  // TAY impl
            print(opCode)
            
        case 0xA9:  // LDA #
            print(opCode)
            
        case 0xAA:  // TAX impl
            print(opCode)
            
        case 0xAC:  // LDY abs
            print(opCode)
            
        case 0xAD:  // LDA abs
            print(opCode)
            
        case 0xAE:  // LDX abs
            print(opCode)
            
        case 0xB0:  // BCS rel
            print(opCode)
            
        case 0xB1:  // LDA ind,Y
            print(opCode)
            
        case 0xB4:  // LDY zpg,X
            print(opCode)
            
        case 0xB5:  // LDA zpg,X
            print(opCode)
            
        case 0xB6:  // LDX zpg,Y
            print(opCode)
            
        case 0xB8:  // CLV impl
            print(opCode)
            
        case 0xB9:  // LDA abs,Y
            print(opCode)
            
        case 0xBA:  // TSX impl
            print(opCode)
            
        case 0xBC:  // LDY abs,X
            print(opCode)
            
        case 0xBD:  // LDA abs,X
            print(opCode)
            
        case 0xBE:  // LDX abs,Y
            print(opCode)
            
        case 0xC0:  // CPY #
            print(opCode)
            
        case 0xC1:  // CMP X,ind
            print(opCode)
            
        case 0xC4:  // CPY zpg
            print(opCode)
            
        case 0xC5:  // CMP zpg
            print(opCode)
            
        case 0xC6:  // DEC zpg
            print(opCode)
            
        case 0xC8:  // INY impl
            print(opCode)
            
        case 0xC9:  // CMP #
            print(opCode)
            
        case 0xCA:  // DEX impl
            print(opCode)
            
        case 0xCC:  // CPY abs
            print(opCode)
            
        case 0xCD:  // CMP abs
            print(opCode)
            
        case 0xCE:  // DEC abs
            print(opCode)
            
        case 0xD0:  // BNE rel
            print(opCode)
            
        case 0xD1:  // CMP ind,Y
            print(opCode)
            
        case 0xD5:  // CMP zpg,X
            print(opCode)
            
        case 0xD6:  // DEC zpg,X
            print(opCode)
            
        case 0xD8:  // CLD impl
            print(opCode)
            
        case 0xD9:  // CMP abs,Y
            print(opCode)
            
        case 0xDD:  // CMP abs,X
            print(opCode)
            
        case 0xDE:  // DEC abs,X
            print(opCode)
            
        case 0xE0:  // CPX #
            print(opCode)
            
        case 0xE1:  // SBC X,ind
            print(opCode)
            
        case 0xE4:  // CPX zpg
            print(opCode)
            
        case 0xE5:  // SBC zpg
            print(opCode)
            
        case 0xE6:  // INC zpg
            print(opCode)
            
        case 0xE8:  // INX impl
            print(opCode)
            
        case 0xE9:  // SBC #
            print(opCode)
            
        case 0xEA:  // NOP impl
            print(opCode)
            
        case 0xEC:  // CPX abs
            print(opCode)
            
        case 0xED:  // SBC abs
            print(opCode)
            
        case 0xEE:  // INC abs
            print(opCode)
            
        case 0xF0:  // BEQ rel
            print(opCode)
            
        case 0xF1:  // SBC ind,Y
            print(opCode)
            
        case 0xF5:  // SBC zpg,X
            print(opCode)
            
        case 0xF6:  // INC zpg,X
            print(opCode)
            
        case 0xF8:  // SED impl
            print(opCode)
            
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
