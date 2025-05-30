//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 07/03/2025.
//

import Foundation
import FAC_Common

public extension FAC_6502 {
    
    func fetchAndExecute() async {
        oldPC = PC
        opCode = await next()
      //  var ts = 2
        var mCycles = 2
        switch opCode {
            //     logProcessor(oldPC, "")
            
        case 0x00:  // BRK impl
            // Current understanding - BRK forces an IRQ interupt
            // PC+2 is added to the stack for return and then PC jumps to the address found at WORD 0xFFFE
            // See https://en.wikipedia.org/wiki/Interrupts_in_65xx_processors
            // Sets five and brk flags
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            await push(PC &+ 0x1)
            await jumpToAddressAt(0xFFFE)
            pBreak(isSet: true)
            await push(P)
            pBreak(isSet: false)
            pInterupt(isSet: true)
            mCycles = 7
            logProcessor(oldPC, "BRK")
            
        case 0x01:  // ORA X,ind
            // Current understanding - ORA X,ind Or's 'A' with the page 0 contents of location ((X + Byte 2 + 1 (high)) (X + Byte 2 (low)))
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = await fetchValue(mode: .indirectX)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "ORA (\(value.byte2.hex()), X)")
            
        case 0x05:  // ORA zpg
            // Current understanding - ORA ZPG Or's 'A' with the page 0 contents of byte 2
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = await fetchValue(mode: .zeroPage)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "ORA $\(value.byte2.hex())")
            
        case 0x06:  // ASL zpg
            // Current understanding - ASL zpg shifts the bits of the page 0 contents of byte 2 1 place left
            // A is unaffected
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ASL
            // Updates Negative, Zero and Carry flags
            let addressedValue = await fetchValue(mode: .zeroPage)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            let shiftedValue = value << 1
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            logProcessor(oldPC, "ASL $\(addressedValue.byte2.hex())")
            
        case 0x08:  // PHP impl
            // Current understanding - PHP simple pushes the status flag (P) to the stack
            // A is unaffected
            // See https://www.pagetable.com/c64ref/6502/?tab=2#PHP
            // Flags are not affected
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            pBreak(isSet: true)
            await push(P)
            pBreak(isSet: false)
            mCycles = 3
            logProcessor(oldPC, "PHP")
            
        case 0x09:  // ORA #
            // Current understanding - ORA # Or's 'A' with byte 2
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = await next()
            A = A | value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "ORA #\(value.hex())")
            
        case 0x0A:  // ASL A
            // Current understanding - ASL A shifts the bits of the Accumulator 1 place left
            // A contains bit shifted value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ASL
            // Updates Negative, Zero and Carry flags
            let carryOut = (A & 0x80) != 0
            logProcessor(oldPC, "ASL A (#\(A.hex()))")
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
            let value = await fetchValue(mode: .absolute)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "ORA $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x0E:  // ASL abs
            // Current understanding - ASL abs shifts the bits of the word at (byte 3 (high) byte 2 (low)) 1 place left
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let addressedValue = await fetchValue(mode: .absolute)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            let shiftedValue = value << 1
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "ASL (\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()))")
            
        case 0x10:  // BPL rel
            // Current understanding - BPL branches to PC + (byte 2(2s compliment)) if the status flag 'Negative' is not set
            // See https://www.pagetable.com/c64ref/6502/?tab=2#BPL
            // Flags are not affected
            let value = await fetchValue(mode: .relative, condition: !P.isSet(bit: negative))
            mCycles = value.cycles
            logProcessor(oldPC, "BPL \(value.byte2.hex())(\(await relativeJump(from: oldPC, twos: value.byte3).hex()))")
            
        case 0x11:  // ORA ind,Y
            // Current understanding - ORA ind,Y Or's 'A' with the page 0 contents of location ((Y + Byte 2 + 1 + carry (high)) (Y + Byte 2) (low))
            // A contains the Or'd value
            // See https://www.pagetable.com/c64ref/6502/?tab=2#ORA
            // Updates Negative and Zero flags
            let value = await fetchValue(mode: .indirectY)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            logProcessor(oldPC, "ORA (\(value.byte2.hex())), Y")
            
        case 0x15:  // ORA zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "ORA $\(value.byte2.hex()), X")
            
        case 0x16:  // ASL zpg,X
            let addressedValue = await fetchValue(mode: .zeroPageX)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            let shiftedValue = value << 1
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "ASL $\(addressedValue.byte2.hex()), X")
            
        case 0x18:  // CLC impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            reset(carry)
            mCycles = 2
            logProcessor(oldPC, "CLC")
            
        case 0x19:  // ORA abs,Y
            let value = await fetchValue(mode: .absoluteY)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "ORA $\(value.byte3.hex())\(value.byte2.hex()), Y")
            
        case 0x1D:  // ORA abs,X
            let value = await fetchValue(mode: .absoluteX)
            A = A | value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "ORA $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        case 0x1E:  // ASL abs,X
            let addressedValue = await fetchValue(mode: .absoluteX)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            let shiftedValue = value << 1
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 7
            logProcessor(oldPC, "ASL $\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()), X")
            
        case 0x20:  // JSR abs
            let byte2 = await next()
            await push(PC)
            let byte3 = await next()
            // logAsPrint("\(oldPC.hex()): \(opCode.hex()) \(byte2.hex()) \(byte3.hex())")
            PC = wordFrom(low: byte2, high: byte3)
            mCycles = 6
            logProcessor(oldPC, "JSR $\(byte3.hex())\(byte2.hex())")
            
        case 0x21:  // AND X,ind
            let value = await fetchValue(mode: .indirectX)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "AND (\(value.byte2.hex()), X)")
            
        case 0x24:  // BIT zpg
            let value = await fetchValue(mode: .zeroPage)
            let result = A & value.value
            pZero(isSet: result == 0)
            pNegative(isSet: (value.value & 0x80) != 0)
            pOverflow(isSet: (value.value & 0x40) != 0)
            mCycles = 3
            logProcessor(oldPC, "BIT $\(value.byte2.hex())")
            
        case 0x25:  // AND zpg
            let value = await fetchValue(mode: .zeroPage)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "AND $\(value.byte2.hex())")
            
        case 0x26:  // ROL zpg
            let addressedValue = await fetchValue(mode: .zeroPage)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            var shiftedValue = value << 1
            shiftedValue = shiftedValue.set(bit: 0, value: P.isSet(bit: carry))
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            logProcessor(oldPC, "ROL $\(addressedValue.byte2.hex())")
            
        case 0x28:  // PLP impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            P = await pop()
            pBreak(isSet: false)
            pFive(isSet: true)
            mCycles = 4
            logProcessor(oldPC, "PLP")
            
        case 0x29:  // AND #
            let value = await fetchValue(mode: .immediate)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "AND #\(value.byte2.hex())")
            
        case 0x2A:  // ROL A
            let carryOut = (A & 0x80) != 0
            logProcessor(oldPC, "ROL A (#\(A.hex()))")
            var newA = A << 1
            newA = newA.set(bit: 0, value: P.isSet(bit: carry))
            A = newA
            pCarry(isSet: carryOut)
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x2C:  // BIT abs
            let value = await fetchValue(mode: .absolute)
            let result = A & value.value
            pZero(isSet: result == 0)
            pNegative(isSet: (value.value & 0x80) != 0)
            pOverflow(isSet: (value.value & 0x40) != 0)
            mCycles = 4
            logProcessor(oldPC, "BIT $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x2D:  // AND abs
            let value = await fetchValue(mode: .absolute)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "AND $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x2E:  // ROL abs
            let addressedValue = await fetchValue(mode: .absolute)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            var shiftedValue = value << 1
            shiftedValue = shiftedValue.set(bit: 0, value: P.isSet(bit: carry))
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "ROL (\(addressedValue.byte3.hex())\(addressedValue.byte2.hex())) - \(shiftedValue.hex())")
            
        case 0x30:  // BMI rel
            let value = await fetchValue(mode: .relative, condition: P.isSet(bit: negative))
            mCycles = value.cycles
            logProcessor(oldPC, "BMI \(value.byte2.hex())(\(await relativeJump(from: oldPC, twos: value.byte3).hex()))")
            
        case 0x31:  // AND ind,Y
            let value = await fetchValue(mode: .indirectY)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            logProcessor(oldPC, "AND (\(value.byte2.hex())), Y")
            
        case 0x35:  // AND zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            logProcessor(oldPC, "AND $\(value.byte2.hex()), X")
            
        case 0x36:  // ROL zpg,X
            let addressedValue = await fetchValue(mode: .zeroPageX)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            var shiftedValue = value << 1
            shiftedValue = shiftedValue.set(bit: 0, value: P.isSet(bit: carry))
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            logProcessor(oldPC, "ROL $\(addressedValue.byte2.hex()), X")
            
        case 0x38:  // SEC impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            set(carry)
            mCycles = 2
            logProcessor(oldPC, "SEC")
            
        case 0x39:  // AND abs,Y
            let value = await fetchValue(mode: .absoluteY)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "AND $\(value.byte3.hex())\(value.byte2.hex()), Y")
            
        case 0x3D:  // AND abs,X
            let value = await fetchValue(mode: .absoluteX)
            A = A & value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "AND $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        case 0x3E:  // ROL abs,X
            let addressedValue = await fetchValue(mode: .absoluteX)
            let value = addressedValue.value
            let carryOut = (value & 0x80) != 0
            var shiftedValue = value << 1
            shiftedValue = shiftedValue.set(bit: 0, value: P.isSet(bit: carry))
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 7
            logProcessor(oldPC, "ROL $\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()), X")
            
        case 0x40:  // RTI impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            P = await pop()
            PC = await popWord()
            pBreak(isSet: false)
            pFive(isSet: true)
            mCycles = 6
            logProcessor(oldPC, "RTI")
            
        case 0x41:  // EOR X,ind
            let value = await fetchValue(mode: .indirectX)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "EOR (\(value.byte2.hex()), X)")
            
        case 0x45:  // EOR zpg
            let value = await fetchValue(mode: .zeroPage)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "EOR $\(value.byte2.hex())")
            
        case 0x46:  // LSR zpg
            let addressedValue = await fetchValue(mode: .zeroPage)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            let shiftedValue = value >> 1
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            logProcessor(oldPC, "LSR $\(addressedValue.byte2.hex())")
            
        case 0x48:  // PHA impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            await push(A)
            mCycles = 3
            logProcessor(oldPC, "PHA")
            
        case 0x49:  // EOR #
            let value = await fetchValue(mode: .immediate)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "EOR #\(value.byte2.hex())")
            
        case 0x4A:  // LSR A
            let carryOut = (A & 0x01) != 0
            logProcessor(oldPC, "LSR A (#\(A.hex()))")
            A = A >> 1
            pCarry(isSet: carryOut)
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            
        case 0x4C:  // JMP abs
            let value = await fetchValue(mode: .absolute)
            PC = value.location
            mCycles = 3
            logProcessor(oldPC, "JMP $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x4D:  // EOR abs
            let value = await fetchValue(mode: .absolute)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "EOR $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x4E:  // LSR abs
            let addressedValue = await fetchValue(mode: .absolute)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            let shiftedValue = value >> 1
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "LSR (\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()))")
            
        case 0x50:  // BVC rel
            let value = await fetchValue(mode: .relative, condition: !P.isSet(bit: overflow))
            mCycles = value.cycles
            logProcessor(oldPC, "BVC \(value.byte2.hex())(\(await relativeJump(from: oldPC, twos: value.byte3).hex()))")
            
        case 0x51:  // EOR ind,Y
            let value = await fetchValue(mode: .indirectY)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            logProcessor(oldPC, "EOR (\(value.byte2.hex())), Y")
            
        case 0x55:  // EOR zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "EOR $\(value.byte2.hex()), X")
            
        case 0x56:  // LSR zpg,X
            let addressedValue = await fetchValue(mode: .zeroPageX)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            let shiftedValue = value >> 1
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "LSR $\(addressedValue.byte2.hex()), X")
            
        case 0x58:  // CLI impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            reset(interupt)
            mCycles = 2
            logProcessor(oldPC, "CLI")
            
        case 0x59:  // EOR abs,Y
            let value = await fetchValue(mode: .absoluteY)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "EOR $\(value.byte3.hex())\(value.byte2.hex()), Y")
            
        case 0x5D:  // EOR abs,X
            let value = await fetchValue(mode: .absoluteX)
            A = A ^ value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "EOR $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        case 0x5E:  // LSR abs,X
            let addressedValue = await fetchValue(mode: .absoluteX)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            let shiftedValue = value >> 1
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            logProcessor(oldPC, "LSR $\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()), X")
            
        case 0x60:  // RTS impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            let stackWord = await popWord()
            PC = stackWord &+ 1
            logProcessor(oldPC, "RTS")
            
        case 0x61:  // ADC X,ind
            let value = await fetchValue(mode: .indirectX)
            A = adc(A, value.value)
            mCycles = 6
            logProcessor(oldPC, "ADC (\(value.byte2.hex()), X)")
            
        case 0x65:  // ADC zpg
            let value = await fetchValue(mode: .zeroPage)
            A = adc(A, value.value)
            mCycles = 3
            logProcessor(oldPC, "ADC $\(value.byte2.hex())")
            
        case 0x66:  // ROR zpg
            let addressedValue = await fetchValue(mode: .zeroPage)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 5
            logProcessor(oldPC, "ROR $\(addressedValue.byte2.hex())")
            
        case 0x68:  // PLA impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            A = await pop()
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "PLA")
            
        case 0x69:  // ADC #
            let value = await fetchValue(mode: .immediate)
            A = adc(A, value.value)
            mCycles = 2
            logProcessor(oldPC, "ADC #\(value.byte2.hex())")
            
        case 0x6A:  // ROR A
            logProcessor(oldPC, "ROR A (#\(A.hex()))")
            let addressedValue = await fetchValue(mode: .accumilator)
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
            let value = await fetchValue(mode: .absoluteIndirect)
            PC = value.location
            mCycles = 5
            logProcessor(oldPC, "JMP ($\(value.byte3.hex())\(value.byte2.hex())) - ($\(value.location.hex()))")
            
        case 0x6D:  // ADC abs
            let value = await fetchValue(mode: .absolute)
            A = adc(A, value.value)
            mCycles = 4
            logProcessor(oldPC, "ADC $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x6E:  // ROR abs
            let addressedValue = await fetchValue(mode: .absolute)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "ROR (\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()))")
            
        case 0x70:  // BVS rel
            let value = await fetchValue(mode: .relative, condition: P.isSet(bit: overflow))
            mCycles = value.cycles
            logProcessor(oldPC, "BVS \(value.byte2.hex())(\(await relativeJump(from: oldPC, twos: value.byte3).hex()))")
            
        case 0x71:  // ADC ind,Y
            let value = await fetchValue(mode: .indirectY)
            A = adc(A, value.value)
            mCycles = 5 + value.cycles
            logProcessor(oldPC, "ADC (\(value.byte2.hex())), Y")
            
        case 0x75:  // ADC zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            A = adc(A, value.value)
            mCycles = 4
            logProcessor(oldPC, "ADC $\(value.byte2.hex()), X")
            
        case 0x76:  // ROR zpg,X
            let addressedValue = await fetchValue(mode: .zeroPageX)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "ROR $\(addressedValue.byte2.hex()), X")
            
        case 0x78:  // SEI impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            set(interupt)
            mCycles = 2
            logProcessor(oldPC, "SEI")
            
        case 0x79:  // ADC abs,Y
            let value = await fetchValue(mode: .absoluteY)
            A = adc(A, value.value)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "ADC $\(value.byte3.hex())\(value.byte2.hex()), Y")
            
        case 0x7D:  // ADC abs,X
            let value = await fetchValue(mode: .absoluteX)
            A = adc(A, value.value)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "ADC $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        case 0x7E:  // ROR abs,X
            let addressedValue = await fetchValue(mode: .absoluteX)
            let value = addressedValue.value
            let carryOut = (value & 0x01) != 0
            var shiftedValue = value >> 1
            shiftedValue = shiftedValue.set(bit: 7, value: bitValue(carry))
            await memoryWrite(to: addressedValue.location, value: shiftedValue)
            pCarry(isSet: carryOut)
            pZero(isSet: shiftedValue == 0)
            pNegative(isSet: (shiftedValue & 0x80) != 0)
            mCycles = 7
            logProcessor(oldPC, "ROR $\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()), X")
            
        case 0x81:  // STA X,ind
            let value = await fetchValue(mode: .indirectX)
            await memoryWrite(to: value.location, value: A)
            mCycles = 6
            logProcessor(oldPC, "STA (\(value.byte2.hex()), X)")
            
        case 0x84:  // STY zpg
            let value = await fetchValue(mode: .zeroPage)
            await memoryWrite(to: value.location, value: Y)
            mCycles = 3
            logProcessor(oldPC, "STY $\(value.byte2.hex())")
            
        case 0x85:  // STA zpg
            let value = await fetchValue(mode: .zeroPage)
            await memoryWrite(to: value.location, value: A)
            mCycles = 3
            logProcessor(oldPC, "STA $\(value.byte2.hex())")
            
        case 0x86:  // STX zpg
            let value = await fetchValue(mode: .zeroPage)
            await memoryWrite(to: value.location, value: X)
            mCycles = 3
            logProcessor(oldPC, "STX $\(value.byte2.hex())")
            
        case 0x88:  // DEY impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            Y = Y &- 1
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "DEY")
            
        case 0x8A:  // TXA impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            A = X
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "TXA")
            
        case 0x8C:  // STY abs
            let value = await fetchValue(mode: .absolute)
            await memoryWrite(to: value.location, value: Y)
            mCycles = 4
            logProcessor(oldPC, "STY $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x8D:  // STA abs
            let value = await fetchValue(mode: .absolute)
            await memoryWrite(to: value.location, value: A)
            mCycles = 4
            logProcessor(oldPC, "STA $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x8E:  // STX abs
            let value = await fetchValue(mode: .absolute)
            await memoryWrite(to: value.location, value: X)
            mCycles = 4
            logProcessor(oldPC, "STX $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0x90:  // BCC rel
            let value = await fetchValue(mode: .relative, condition: !P.isSet(bit: carry))
            mCycles = value.cycles
            logProcessor(oldPC, "BCC \(value.byte2.hex())(\(await relativeJump(from: oldPC, twos: value.byte3).hex()))")
            
        case 0x91:  // STA ind,Y
            let value = await fetchValue(mode: .indirectY)
            await memoryWrite(to: value.location, value: A)
            mCycles = 6
            logProcessor(oldPC, "STA (\(value.byte2.hex())), Y")
            
        case 0x94:  // STY zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            await memoryWrite(to: value.location, value: Y)
            mCycles = 4
            logProcessor(oldPC, "STY $\(value.byte2.hex()), X")
            
        case 0x95:  // STA zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            await memoryWrite(to: value.location, value: A)
            mCycles = 4
            logProcessor(oldPC, "STA $\(value.byte2.hex()), X")
            
        case 0x96:  // STX zpg,Y
            let value = await fetchValue(mode: .zeroPageY)
            await memoryWrite(to: value.location, value: X)
            mCycles = 4
            logProcessor(oldPC, "STX $\(value.byte2.hex()), Y")
            
        case 0x98:  // TYA impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            A = Y
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "TYA")
            
        case 0x99:  // STA abs,Y
            let value = await fetchValue(mode: .absoluteY)
            await memoryWrite(to: value.location, value: A)
            mCycles = 5
            logProcessor(oldPC, "STA $\(value.byte3.hex())\(value.byte2.hex()), Y")
            
        case 0x9A:  // TXS impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            S = X
            mCycles = 2
            logProcessor(oldPC, "TXS")
            
        case 0x9D:  // STA abs,X
            let value = await fetchValue(mode: .absoluteX)
            await memoryWrite(to: value.location, value: A)
            mCycles = 5
            logProcessor(oldPC, "STA $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        case 0xA0:  // LDY #
            let value = await fetchValue(mode: .immediate)
            Y = value.value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "LDY #\(value.byte2.hex())")
            
        case 0xA1:  // LDA X,ind
            let value = await fetchValue(mode: .indirectX)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "LDA (\(value.byte2.hex()), X)")
            
        case 0xA2:  // LDX #
            let value = await fetchValue(mode: .immediate)
            X = value.value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "LDX #\(value.byte2.hex())")
            
        case 0xA4:  // LDY zpg
            let value = await fetchValue(mode: .zeroPage)
            Y = value.value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "LDY $\(value.byte2.hex())")
            
        case 0xA5:  // LDA zpg
            let value = await fetchValue(mode: .zeroPage)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "LDA $\(value.byte2.hex())")
            
        case 0xA6:  // LDX zpg
            let value = await fetchValue(mode: .zeroPage)
            X = value.value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "LDX $\(value.byte2.hex())")
            
        case 0xA8:  // TAY impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            Y = A
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "TAY")
            
        case 0xA9:  // LDA #
            let value = await fetchValue(mode: .immediate)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "LDA #\(value.byte2.hex())")
            
        case 0xAA:  // TAX impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            X = A
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 3
            logProcessor(oldPC, "TAX")
            
        case 0xAC:  // LDY abs
            let value = await fetchValue(mode: .absolute)
            Y = value.value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "LDY $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0xAD:  // LDA abs
            let value = await fetchValue(mode: .absolute)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "LDA $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0xAE:  // LDX abs
            let value = await fetchValue(mode: .absolute)
            X = value.value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "LDX $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0xB0:  // BCS rel
            let value = await fetchValue(mode: .relative, condition: P.isSet(bit: carry))
            mCycles = value.cycles
            logProcessor(oldPC, "BCS \(value.byte2.hex())(\(await relativeJump(from: oldPC, twos: value.byte3).hex()))")
            
        case 0xB1:  // LDA ind,Y
            let value = await fetchValue(mode: .indirectY)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 5 + value.cycles
            logProcessor(oldPC, "LDA (\(value.byte2.hex())), Y")
            
        case 0xB4:  // LDY zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            Y = value.value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "LDY $\(value.byte2.hex()), X")
            
        case 0xB5:  // LDA zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "LDA $\(value.byte2.hex()), X")
            
        case 0xB6:  // LDX zpg,Y
            let value = await fetchValue(mode: .zeroPageY)
            X = value.value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 4
            logProcessor(oldPC, "LDX $\(value.byte2.hex()), Y")
            
        case 0xB8:  // CLV impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            reset(overflow)
            mCycles = 2
            logProcessor(oldPC, "CLV")
            
        case 0xB9:  // LDA abs,Y
            let value = await fetchValue(mode: .absoluteY)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "LDA $\(value.byte3.hex())\(value.byte2.hex()), Y")
            
        case 0xBA:  // TSX impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            X = S
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "TSX")
            
        case 0xBC:  // LDY abs,X
            let value = await fetchValue(mode: .absoluteX)
            Y = value.value
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "LDY $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        case 0xBD:  // LDA abs,X
            let value = await fetchValue(mode: .absoluteX)
            A = value.value
            pZero(isSet: A == 0)
            pNegative(isSet: (A & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "LDA $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        case 0xBE:  // LDX abs,Y
            let value = await fetchValue(mode: .absoluteY)
            X = value.value
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "LDX $\(value.byte3.hex())\(value.byte2.hex()), Y")
            
        case 0xC0:  // CPY #
            let value = await fetchValue(mode: .immediate)
            cmp(Y, value.value)
            mCycles = 2
            logProcessor(oldPC, "CPY #\(value.byte2.hex())")
            
            
        case 0xC1:  // CMP X,ind
            let value = await fetchValue(mode: .indirectX)
            cmp(A, value.value)
            mCycles = 6
            logProcessor(oldPC, "CMP (\(value.byte2.hex()), X)")
            
        case 0xC4:  // CPY zpg
            let value = await fetchValue(mode: .zeroPage)
            cmp(Y, value.value)
            mCycles = 3
            logProcessor(oldPC, "CPY $\(value.byte2.hex())")
            
        case 0xC5:  // CMP zpg
            let value = await fetchValue(mode: .zeroPage)
            cmp(A, value.value)
            mCycles = 3
            logProcessor(oldPC, "CMP $\(value.byte2.hex())")
            
        case 0xC6:  // DEC zpg
            let addressedValue = await fetchValue(mode: .zeroPage)
            let value = addressedValue.value &- 1
            await memoryWrite(to: addressedValue.location, value: value)
            pZero(isSet: value == 0)
            pNegative(isSet: (value & 0x80) != 0)
            mCycles = 5
            logProcessor(oldPC, "DEC $\(addressedValue.byte2.hex())")
            
        case 0xC8:  // INY impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            Y = Y &+ 1
            pZero(isSet: Y == 0)
            pNegative(isSet: (Y & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "INY")
            
        case 0xC9:  // CMP #
            let value = await fetchValue(mode: .immediate)
            cmp(A, value.value)
            mCycles = 2
            logProcessor(oldPC, "CMP #\(value.byte2.hex())")
            
        case 0xCA:  // DEX impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            X = X &- 1
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "DEX")
            
        case 0xCC:  // CPY abs
            let value = await fetchValue(mode: .absolute)
            cmp(Y, value.value)
            mCycles = 4
            logProcessor(oldPC, "CPY $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0xCD:  // CMP abs
            let value = await fetchValue(mode: .absolute)
            cmp(A, value.value)
            mCycles = 4
            logProcessor(oldPC, "CMP $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0xCE:  // DEC abs
            let addressedValue = await fetchValue(mode: .absolute)
            let value = addressedValue.value &- 1
            await memoryWrite(to: addressedValue.location, value: value)
            pZero(isSet: value == 0)
            pNegative(isSet: (value & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "DEC (\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()))")
            
        case 0xD0:  // BNE rel
            let value = await fetchValue(mode: .relative, condition: !P.isSet(bit: zero))
            mCycles = value.cycles
            logProcessor(oldPC, "BNE \(value.byte2.hex())(\(await relativeJump(from: oldPC, twos: value.byte3).hex()))")
            
        case 0xD1:  // CMP ind,Y
            let addressingValue = await fetchValue(mode: .indirectY)
            let value = addressingValue.value
            cmp(A, value)
            mCycles = 5 + addressingValue.cycles
            logProcessor(oldPC, "CMP (\(addressingValue.byte2.hex())), Y")
            
        case 0xD5:  // CMP zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            cmp(A, value.value)
            mCycles = 4
            logProcessor(oldPC, "CMP $\(value.byte2.hex()), X")
            
        case 0xD6:  // DEC zpg,X
            let addressedValue = await fetchValue(mode: .zeroPageX)
            let value = addressedValue.value &- 1
            await memoryWrite(to: addressedValue.location, value: value)
            pZero(isSet: value == 0)
            pNegative(isSet: (value & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "DEC $\(addressedValue.byte2.hex()), X")
            
        case 0xD8:  // CLD impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            reset(decimal)
            mCycles = 2
            logProcessor(oldPC, "CLD")
            
        case 0xD9:  // CMP abs,Y
            let addressingValue = await fetchValue(mode: .absoluteY)
            let value = addressingValue.value
            cmp(A, value)
            mCycles = 4 + addressingValue.cycles
            logProcessor(oldPC, "CMP \(addressingValue.byte3.hex())\(addressingValue.byte2.hex()), Y")
            
        case 0xDD:  // CMP abs,X
            let addressingValue = await fetchValue(mode: .absoluteX)
            let value = addressingValue.value
            cmp(A, value)
            mCycles = 4 + addressingValue.cycles
            logProcessor(oldPC, "CMP $\(addressingValue.byte3.hex())\(addressingValue.byte2.hex()), X")
            
        case 0xDE:  // DEC abs,X
            let addressedValue = await fetchValue(mode: .absoluteX)
            let value = addressedValue.value &- 1
            await memoryWrite(to: addressedValue.location, value: value)
            pZero(isSet: value == 0)
            pNegative(isSet: (value & 0x80) != 0)
            mCycles = 7
            logProcessor(oldPC, "DEC $\(addressedValue.byte3.hex())\(addressedValue.byte2.hex()), X")
            
        case 0xE0:  // CPX #
            let value = await fetchValue(mode: .immediate)
            cmp(X, value.value)
            mCycles = 2
            logProcessor(oldPC, "CPX #\(value.byte2.hex())")
            
        case 0xE1:  // SBC X,ind
            let value = await fetchValue(mode: .indirectX)
            A = sbc(A, value.value)
            mCycles = 6
            logProcessor(oldPC, "SBC (\(value.byte2.hex()), X)")
            
            
        case 0xE4:  // CPX zpg
            let value = await fetchValue(mode: .zeroPage)
            cmp(X, value.value)
            mCycles = 3
            logProcessor(oldPC, "CPX $\(value.byte2.hex())")
            
        case 0xE5:  // SBC zpg
            let value = await fetchValue(mode: .zeroPage)
            A = sbc(A, value.value)
            mCycles = 3
            logProcessor(oldPC, "SBC $\(value.byte2.hex())")
            
        case 0xE6:  // INC zpg
            let value = await fetchValue(mode: .zeroPage)
            let m = value.value &+ 1
            await memoryWrite(to: value.location, value: m)
            pZero(isSet: m == 0)
            pNegative(isSet: (m & 0x80) != 0)
            mCycles = 5
            logProcessor(oldPC, "INC $\(value.byte2.hex())")
            
        case 0xE8:  // INX impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            X = X &+ 1
            pZero(isSet: X == 0)
            pNegative(isSet: (X & 0x80) != 0)
            mCycles = 2
            logProcessor(oldPC, "INX")
            
        case 0xE9:  // SBC #
            let value = await fetchValue(mode: .immediate)
            A = sbc(A, value.value)
            mCycles = 2
            logProcessor(oldPC, "SBC #\(value.byte2.hex())")
            
        case 0xEA:  // NOP impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            mCycles = 2
            logProcessor(oldPC, "NOP")
            
        case 0xEC:  // CPX abs
            let value = await fetchValue(mode: .absolute)
            cmp(X, value.value)
            mCycles = 4
            logProcessor(oldPC, "CPX $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0xED:  // SBC abs
            let value = await fetchValue(mode: .absolute)
            A = sbc(A, value.value)
            mCycles = 4
            logProcessor(oldPC, "SBC $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0xEE:  // INC abs
            let value = await fetchValue(mode: .absolute)
            let m = value.value &+ 1
            await memoryWrite(to: value.location, value: m)
            pZero(isSet: m == 0)
            pNegative(isSet: (m & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "INC $\(value.byte3.hex())\(value.byte2.hex())")
            
        case 0xF0:  // BEQ rel
            let value = await fetchValue(mode: .relative, condition: P.isSet(bit: zero))
            mCycles = value.cycles
            logProcessor(oldPC, "BEQ \(value.byte2.hex())(\(await relativeJump(from: oldPC, twos: value.byte3).hex())")
            
        case 0xF1:  // SBC ind,Y
            let value = await fetchValue(mode: .indirectY)
            A = sbc(A, value.value)
            mCycles = 5 + value.cycles
            logProcessor(oldPC, "SBC (\(value.byte2.hex())), Y")
            
        case 0xF5:  // SBC zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            A = sbc(A, value.value)
            mCycles = 4
            logProcessor(oldPC, "SBC $\(value.byte2.hex()), X")
            
        case 0xF6:  // INC zpg,X
            let value = await fetchValue(mode: .zeroPageX)
            let m = value.value &+ 1
            await memoryWrite(to: value.location, value: m)
            pZero(isSet: m == 0)
            pNegative(isSet: (m & 0x80) != 0)
            mCycles = 6
            logProcessor(oldPC, "INC $\(value.byte2.hex()), X")
            
        case 0xF8:  // SED impl
            // logAsPrint("\(oldPC.hex()): \(opCode.hex())")
            set(decimal)
            mCycles = 2
            logProcessor(oldPC, "SED")
            
        case 0xF9:  // SBC abs,Y
            let value = await fetchValue(mode: .absoluteY)
            A = sbc(A, value.value)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "SBC $\(value.byte3.hex())\(value.byte2.hex()), Y")
            
        case 0xFD:  // SBC abs,X
            let value = await fetchValue(mode: .absoluteX)
            A = sbc(A, value.value)
            mCycles = 4 + value.cycles
            logProcessor(oldPC, "SBC $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        case 0xFE:  // INC abs,X
            let value = await fetchValue(mode: .absoluteX)
            let m = value.value &+ 1
            await memoryWrite(to: value.location, value: m)
            pZero(isSet: m == 0)
            pNegative(isSet: (m & 0x80) != 0)
            mCycles = 7
            logProcessor(oldPC, "INC $\(value.byte3.hex())\(value.byte2.hex()), X")
            
        default:
            print("Unknown opcode at \(oldPC.hex()) - \(opCode.hex())")
            break
        }
        
        cycleCount += mCycles
        
        if cycleCount >= clockCyclesPerFrame {
            cycleCount = 0
            await render()
        }

    }

}
