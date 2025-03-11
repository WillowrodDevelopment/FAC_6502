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
    
}
