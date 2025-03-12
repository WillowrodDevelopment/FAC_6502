//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 11/03/2025.
//

import Testing
@testable import FAC_6502

struct TestOpcode101FTest {
    
    @Test func testBPL0x10_0() async throws {
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00 | cpu.negative
        cpu.memoryWrite(to: 0x1234, value: 0x10)
        cpu.memoryWrite(to: 0x1235, value: 0x01)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1236)
        #expect(cpu.P == 0x00 | cpu.negative)
        #expect(cpu.cycleCount == 2)
    }
    
    @Test func testBPL0x10_1() async throws { // branch forward
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x10)
        cpu.memoryWrite(to: 0x1235, value: 0b11110110)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1240)
        #expect(cpu.P == 0x00)
        #expect(cpu.cycleCount == 3)
    }
    
    @Test func testBPL0x10_2() async throws { // branch backwards
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x10)
        cpu.memoryWrite(to: 0x1235, value: 0x0A)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x122C)
        #expect(cpu.P == 0x00)
        #expect(cpu.cycleCount == 3)
    }
    
    @Test func testBPL0x10_3() async throws { // branch forward over page
        let cpu = FAC_6502()
        cpu.PC = 0x12FA
        cpu.P = 0x00
        cpu.memoryWrite(to: 0x12FA, value: 0x10)
        cpu.memoryWrite(to: 0x12FB, value: 0b11110110)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1306)
        #expect(cpu.P == 0x00)
        #expect(cpu.cycleCount == 4)
    }
    
    @Test func testBPL0x10_4() async throws { // branch backwards over page
        let cpu = FAC_6502()
        cpu.PC = 0x1200
        cpu.P = 0x00
        cpu.memoryWrite(to: 0x1200, value: 0x10)
        cpu.memoryWrite(to: 0x1201, value: 0x0A)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x11F8)
        #expect(cpu.P == 0x00)
        #expect(cpu.cycleCount == 4)
    }
    
    @Test func testORAindY0x11_0() async throws { // Simple Or
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.S = 0xFF
        cpu.P = 0x00
        cpu.Y = 0x03
        cpu.A = 0x02
        cpu.memoryWrite(to: 0x1234, value: 0x11)
        cpu.memoryWrite(to: 0x1235, value: 0x07)
        cpu.memoryWrite(to: 0x0807, value: 0x01)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.memoryWrite(to: 0x080A, value: 0x08)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.S == 0xFF)
        #expect(cpu.A == 0x0A)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testORAindY0x11_1() async throws { // Simple Or
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.S = 0xFF
        cpu.P = 0x00
        cpu.Y = 0xFF
        cpu.A = 0x02
        cpu.memoryWrite(to: 0x1234, value: 0x11)
        cpu.memoryWrite(to: 0x1235, value: 0x07)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.memoryWrite(to: 0x0906, value: 0x08)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1236)
        #expect(cpu.S == 0xFF)
        #expect(cpu.A == 0x0A)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testORAindY0x11_2() async throws { // Simple Or wrapped zero
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.S = 0xFF
        cpu.P = 0x00
        cpu.Y = 0xFF
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x11)
        cpu.memoryWrite(to: 0x1235, value: 0x07)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.memoryWrite(to: 0x0906, value: 0x00)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1236)
        #expect(cpu.S == 0xFF)
        #expect(cpu.A == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero)
    }
    
    @Test func testORAindY0x11_3() async throws { // Simple Or negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.S = 0xFF
        cpu.P = 0x00
        cpu.Y = 0xFF
        cpu.A = 0x02
        cpu.memoryWrite(to: 0x1234, value: 0x11)
        cpu.memoryWrite(to: 0x1235, value: 0x07)
        cpu.memoryWrite(to: 0x0906, value: 0x81)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1236)
        #expect(cpu.S == 0xFF)
        #expect(cpu.A == 0x83)
        #expect(cpu.P == 0x00 | cpu.negative)
    }
    
}
