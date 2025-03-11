//
//  Test.swift
//  FAC_Common
//
//  Created by Mike Hall on 10/03/2025.
//

import Testing
@testable import FAC_6502

struct Test {

    @Test func testBRK0x00() async throws {
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.S = 0xFF
        cpu.P = 0x00
        cpu.memoryWrite(to: 0x1234, value: 00)
        cpu.memoryWrite(to: 0xFFFE, value: 0x77)
        cpu.memoryWrite(to: 0xFFFF, value: 0x88)
        cpu.fetchAndExecute()
        print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x8877)
        #expect(cpu.S == 0xFD)
        #expect(cpu.memoryRead(from: 0x01FE) == 0x36)
        #expect(cpu.memoryRead(from: 0x01FF) == 0x12)
        #expect(cpu.P == 0x00 | cpu.five | cpu.brk)
    }
    
    @Test func testORAX0x01_0() async throws { // Simple Or
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.S = 0xFF
        cpu.P = 0x00
        cpu.X = 0x06
        cpu.A = 0x01
        cpu.memoryWrite(to: 0x1234, value: 01)
        cpu.memoryWrite(to: 0x1235, value: 06)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.S == 0xFF)
        #expect(cpu.A == 0x0D)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testORAX0x01_1() async throws { // Simple Or - wrapped page
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.X = 0xFF
        cpu.A = 0x01
        cpu.memoryWrite(to: 0x1234, value: 01)
        cpu.memoryWrite(to: 0x1235, value: 06)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x05)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testORAX0x01_2() async throws { // Simple Or - wrapped page negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.X = 0xFF
        cpu.A = 0xF1
        cpu.memoryWrite(to: 0x1234, value: 01)
        cpu.memoryWrite(to: 0x1235, value: 06)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0xF5)
        #expect(cpu.P == 0x80)
    }
    
    @Test func testORAX0x01_3() async throws { // Simple Or - wrapped page zero
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.X = 0xFF
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 01)
        cpu.memoryWrite(to: 0x1235, value: 01)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero)
    }
    
    @Test func testORAzpg0x05_0() async throws { // Simple Or
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.S = 0xFF
        cpu.P = 0x00
        cpu.A = 0x01
        cpu.memoryWrite(to: 0x1234, value: 05)
        cpu.memoryWrite(to: 0x1235, value: 02)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.S == 0xFF)
        #expect(cpu.A == 0x03)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testORAzpg0x05_1() async throws { // Simple Or - negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0xF1
        cpu.memoryWrite(to: 0x1234, value: 05)
        cpu.memoryWrite(to: 0x1235, value: 02)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0xF3)
        #expect(cpu.P == 0x80)
    }
    
    @Test func testORAzpg0x05_2() async throws { // Simple Or - zero
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.X = 0xFF
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 05)
        cpu.memoryWrite(to: 0x1235, value: 00)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero)
    }
    
    @Test func testASLzpg0x06_0() async throws { // Simple ASL
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 06)
        cpu.memoryWrite(to: 0x1235, value: 01)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0001) == 0x02)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testASLzpg0x06_1() async throws { // Simple ASL with carry
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 06)
        cpu.memoryWrite(to: 0x1235, value: 0x81)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0081) == 0x02)
        #expect(cpu.P == 0x00 | cpu.carry)
    }
    
    @Test func testASLzpg0x06_2() async throws { // Simple ASL with zero
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 06)
        cpu.memoryWrite(to: 0x1235, value: 0x00)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0000) == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero)
    }
    
    @Test func testASLzpg0x06_3() async throws { // Simple ASL with zero and carry
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 06)
        cpu.memoryWrite(to: 0x1235, value: 0x80)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0080) == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero | cpu.carry)
    }
    
    @Test func testASLzpg0x06_4() async throws { // Simple ASL with Negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 06)
        cpu.memoryWrite(to: 0x1235, value: 0x41)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0041) == 0x82)
        #expect(cpu.P == 0x00 | cpu.negative)
    }
    
    @Test func testASLzpg0x06_5() async throws { // Simple ASL with FF
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 06)
        cpu.memoryWrite(to: 0x1235, value: 0xFF)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x00FF) == 0xFE)
        #expect(cpu.P == 0x00 | cpu.negative | cpu.carry)
    }

}
