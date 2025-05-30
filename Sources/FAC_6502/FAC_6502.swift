//
//  .swift
//  FAC_650x
//
//  Created by Mike Hall on 06/03/2025.
//

import Foundation
import FAC_Common

open class FAC_6502: LoggingDelegate {
    public var clockCyclesPerFrame = Int(1.108 * BASE_CPU_CLOCK_SPEED) // For PAL Vic20 (1.108Mhz)
    
//    public var rom:[[UInt8]] = []
//    public var ram:[[UInt8]] = [Array(repeating: 0x00, count: 0x10000)]
    
    public let ram = RAM()
    
    public var shouldLog = false
    
    var loggingService = LoggingService.shared
    // Accumilator
    public var A: UInt8 = 0x00
    // Flags
    public var P: UInt8 = 0x00     //   NV-BDIZC
    
    var opCode: UInt8 = 0x00
    var oldPC: UInt16 = 0x00
    
    let carry: Int = 0
    let zero: Int = 1
    let interupt: Int = 2
    let decimal: Int = 3
    let brk: Int = 4
    let five: Int = 5
    let overflow: Int = 6
    let negative: Int = 7
    
    // Control Registers
    public var PC: UInt16 = 0x00
    public var S: UInt8 = 0xFF
    // Index Registers
    public var X: UInt8 = 0x00
    public var Y: UInt8 = 0x00
    
    public var cycleCount = 0
    
    public var processorSpeed: ProcessorSpeed = .standard
    
    public var shouldProcess = false

    var frameCompleted = false
    var frameStarted: TimeInterval = Date().timeIntervalSince1970
    
    var frames = 0
    var startTime = Date().timeIntervalSince1970
    public var fpsValue = 0
    public var secondsValue = 0
    
    public init() {
    }
    
//    public func startProcess() {
//        Task {
//            await process()
//        }
//    }
    
    public func setProcessorSpeed(mhz: Double) async {
        clockCyclesPerFrame = Int(mhz * BASE_CPU_CLOCK_SPEED)
    }
    
    public func resetProcessor() async {
        A = 0x00
        P = 0x00
        X = 0x00
        Y = 0x00
        S = 0xFF
        await ram.reset()
    }
    
    public func logOut() {
        print("Actual values:\nPC: \(PC.toLog())\nS: \(S.toLog())\nA: \(A.toLog())\nP: \(P.toLog())\nX: \(X.toLog())\nY: \(Y.toLog())")
    }
    
    open func fps() async -> Int {
            let seconds = Int(Date().timeIntervalSince1970 - startTime)
            frames += 1
            if seconds > secondsValue {
                secondsValue = seconds
                fpsValue = frames
                frames = 0
            }
return fpsValue
    }
    
    open func display() async {
        await fps()
    }
    
    
    open func memoryWrite(to: UInt16, value: UInt8) async {
        await internalMemoryWrite(to: to, value: value)
    }
    
    
    open func memoryRead(from: UInt16) async -> UInt8 {
        return await internalMemoryRead(from: from)
    }
    
    public func logAsPrint(_ l: String) {
        if shouldLog {
        //      print(l)
        }
    }
    
    open func handleInterupt() async {
        
    }
    
    open func preProcess() async {

    }
    
    open func postProcess() async {
        if false {
            print("")
        }
    }
    
}
