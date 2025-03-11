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
        cpu.memoryWrite(to: 0x1234, value: 00)
        cpu.memoryWrite(to: 0xFFFE, value: 0x77)
        cpu.memoryWrite(to: 0xFFFF, value: 0x88)
        cpu.fetchAndExecute()
        print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x8877)
        #expect(cpu.S == 0xFD)
        #expect(cpu.memoryRead(from: 0x01FE) == 0x36 )
        #expect(cpu.memoryRead(from: 0x01FF) == 0x12)
        
    }

}
