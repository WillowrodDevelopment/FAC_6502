//
//  Test.swift
//  FAC_Common
//
//  Created by Mike Hall on 10/03/2025.
//

import Testing
@testable import FAC_6502

struct TestOpcode000FTest {

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
        cpu.X = 0x01
        cpu.A = 0x01
        cpu.memoryWrite(to: 0x1234, value: 01)
        cpu.memoryWrite(to: 0x1235, value: 06)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.memoryWrite(to: 0x0807, value: 0x0C)
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
        cpu.memoryWrite(to: 0x1235, value: 08)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.memoryWrite(to: 0x0807, value: 0x0C)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x0D)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testORAX0x01_2() async throws { // Simple Or - wrapped page negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.X = 0xFF
        cpu.A = 0xF1
        cpu.memoryWrite(to: 0x1234, value: 01)
        cpu.memoryWrite(to: 0x1235, value: 08)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.memoryWrite(to: 0x0807, value: 0x04)
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
        cpu.memoryWrite(to: 0x1235, value: 08)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.memoryWrite(to: 0x0807, value: 0x00)
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
    
    @Test func testPHP0x08() async throws { // Simple PHP
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.S = 0xFF
        cpu.P = 0x00 | cpu.zero | cpu.negative
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 08)
        for i in 0x00...0xff {
            cpu.memoryWrite(to: UInt16(i), value: UInt8(i))
        }
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1235)
        #expect(cpu.A == 0x00)
        #expect(cpu.S == 0xFE)
        #expect(cpu.memoryRead(page: 1, location: 0xFF) == 0x00 | cpu.zero | cpu.negative)
        #expect(cpu.P == 0x00 | cpu.zero | cpu.negative)
    }
    
    @Test func testORAImm0x09_0() async throws { // Simple Or
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x01
        cpu.memoryWrite(to: 0x1234, value: 0x09)
        cpu.memoryWrite(to: 0x1235, value: 02)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x03)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testORAImm0x09_1() async throws { // Simple Or - negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0xF1
        cpu.memoryWrite(to: 0x1234, value: 0x09)
        cpu.memoryWrite(to: 0x1235, value: 02)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0xF3)
        #expect(cpu.P == 0x80)
    }
    
    @Test func testORAImm0x09_2() async throws { // Simple Or - zero
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.X = 0xFF
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x09)
        cpu.memoryWrite(to: 0x1235, value: 00)
        cpu.fetchAndExecute()
        #expect(cpu.PC == 0x1236)
        #expect(cpu.A == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero)
    }
    
    @Test func testASLA0x0A_0() async throws { // Simple ASL
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x01
        cpu.memoryWrite(to: 0x1234, value: 0x0A)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1235)
        #expect(cpu.A == 0x02)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testASLA0x0A_1() async throws { // Simple ASL with carry
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x81
        cpu.memoryWrite(to: 0x1234, value: 0x0A)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1235)
        #expect(cpu.A == 0x02)
        #expect(cpu.P == 0x00 | cpu.carry)
    }
    
    @Test func testASLA0x0A_2() async throws { // Simple ASL with zero
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x0A)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1235)
        #expect(cpu.A == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero)
    }
    
    @Test func testASLA0x0A_3() async throws { // Simple ASL with zero and carry
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x80
        cpu.memoryWrite(to: 0x1234, value: 0x0A)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1235)
        #expect(cpu.A == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero | cpu.carry)
    }
    
    @Test func testASLA0x0A_4() async throws { // Simple ASL with Negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x41
        cpu.memoryWrite(to: 0x1234, value: 0x0A)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1235)
        #expect(cpu.A == 0x82)
        #expect(cpu.P == 0x00 | cpu.negative)
    }
    
    @Test func testASLA0x0A_5() async throws { // Simple ASL with FF
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0xFF
        cpu.memoryWrite(to: 0x1234, value: 0x0A)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1235)
        #expect(cpu.A == 0xFE)
        #expect(cpu.P == 0x00 | cpu.negative | cpu.carry)
    }
    
    @Test func testORAAbs0x0D_0() async throws { // Simple Or
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x01
        cpu.memoryWrite(to: 0x1234, value: 0x0D)
        cpu.memoryWrite(to: 0x1235, value: 00)
        cpu.memoryWrite(to: 0x1236, value: 02)
        cpu.memoryWrite(to: 0x0200, value: 02)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x03)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testORAAbs0x0D_1() async throws { // Simple Or - negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x81
        cpu.memoryWrite(to: 0x1234, value: 0x0D)
        cpu.memoryWrite(to: 0x1235, value: 00)
        cpu.memoryWrite(to: 0x1236, value: 02)
        cpu.memoryWrite(to: 0x0200, value: 02)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x83)
        #expect(cpu.P == 0x80)
    }
    
    @Test func testORAAbs0x0D_2() async throws { // Simple Or - zero
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x0D)
        cpu.memoryWrite(to: 0x1235, value: 00)
        cpu.memoryWrite(to: 0x1236, value: 02)
        cpu.memoryWrite(to: 0x0200, value: 00)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero)
    }
    
    @Test func testASLAbs0x0E_0() async throws { // Simple ASL
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x0E)
        cpu.memoryWrite(to: 0x1235, value: 0x00)
        cpu.memoryWrite(to: 0x1236, value: 0x02)
        cpu.memoryWrite(to: 0x0200, value: 0x01)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0200) == 0x02)
        #expect(cpu.P == 0x00)
    }
    
    @Test func testASLAbs0x0E_1() async throws { // Simple ASL with carry
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x0E)
        cpu.memoryWrite(to: 0x1235, value: 0x00)
        cpu.memoryWrite(to: 0x1236, value: 0x02)
        cpu.memoryWrite(to: 0x0200, value: 0x81)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0200) == 0x02)
        #expect(cpu.P == 0x00 | cpu.carry)
    }
    
    @Test func testASLAbs0x0E_2() async throws { // Simple ASL with zero
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x0E)
        cpu.memoryWrite(to: 0x1235, value: 0x00)
        cpu.memoryWrite(to: 0x1236, value: 0x02)
        cpu.memoryWrite(to: 0x0200, value: 0x00)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0200) == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero)
    }
    
    @Test func testASLAbs0x0E_3() async throws { // Simple ASL with zero and carry
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x0E)
        cpu.memoryWrite(to: 0x1235, value: 0x00)
        cpu.memoryWrite(to: 0x1236, value: 0x02)
        cpu.memoryWrite(to: 0x0200, value: 0x80)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0200) == 0x00)
        #expect(cpu.P == 0x00 | cpu.zero | cpu.carry)
    }
    
    @Test func testASLAbs0x0E_4() async throws { // Simple ASL with Negative
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x0E)
        cpu.memoryWrite(to: 0x1235, value: 0x00)
        cpu.memoryWrite(to: 0x1236, value: 0x02)
        cpu.memoryWrite(to: 0x0200, value: 0x41)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0200) == 0x82)
        #expect(cpu.P == 0x00 | cpu.negative)
    }
    
    @Test func testASLAbs0x0E_5() async throws { // Simple ASL with FF
        let cpu = FAC_6502()
        cpu.PC = 0x1234
        cpu.P = 0x00
        cpu.A = 0x00
        cpu.memoryWrite(to: 0x1234, value: 0x0E)
        cpu.memoryWrite(to: 0x1235, value: 0x00)
        cpu.memoryWrite(to: 0x1236, value: 0x02)
        cpu.memoryWrite(to: 0x0200, value: 0xFF)
        cpu.fetchAndExecute()
        //print(cpu.ram[0][0xFFF0...])
        #expect(cpu.PC == 0x1237)
        #expect(cpu.A == 0x00)
        #expect(cpu.memoryRead(from: 0x0200) == 0xFE)
        #expect(cpu.P == 0x00 | cpu.negative | cpu.carry)
    }

}
