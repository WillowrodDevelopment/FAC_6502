//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 14/03/2025.
//

import Foundation

public extension FAC_6502 {
    public func process() {
        shouldProcess = true
        //resetProcessor()
        //standard()
        while shouldProcess {
//            if controller.processorSpeed == .paused {
//                render()
//                let _ = controller.processorSpeed
//            } else {
                preProcess()
                 fetchAndExecute()
                postProcess()
//            }
            
        }
        print("Process complete")
    }
    
    func render() {
 //       if controller.processorSpeed != .paused {
            while frameStarted + (1.0 / 50) >= Date().timeIntervalSince1970 { //Double(controller.processorSpeed.rawValue)
                // Idle while we wait for frame to catch up
                
            }
            frameStarted = Date().timeIntervalSince1970
            frameCompleted = false
//        }
    //    if controller.processorSpeed != .unrestricted {
            display()
     //   }
        handleInterupt()
//        if loggingService.isLoggingProcessor {
//                   loggingService.logProcessor(message: lastPCValues.map{"\($0)"}.joined(separator: "-"))
//                   lastPCValues.removeAll()
//        }
   
    }
    
    private func handleInterupt() {
//        if controller.processorSpeed != .paused {
//            if iff2 == 1 { // If IFF2 is enabled, run the selected interupt mode
//                if isInHaltState {
//                    // The Z80 will only come out of halt if interupts are enabled - to 'fix' this, this halt stop can be moved out of the if statement.
//                    PC = PC &+ 0x01
//                }
//                push(PC)
//                switch interuptMode {
//                case 0:
//                    PC = 0x0066
//                case 1:
//                    PC = 0x0038
//                default:
//                    let intAddress = (UInt16(I) * 256) + UInt16(R)
//                    PC = memoryReadWord(from: intAddress)
//                }
//                isInHaltState = false
//            }
//        }
    }
    
    func preProcess() {

    }
    
    func postProcess() {
        
    }
    
    public func standard() {
        //resume()
    }
    
    public func resume() {
//        print("standard")
//        invalidateTimer()
//        controller.processorSpeed = .standard
    }
    public func pause() {
//            print("paused")
//        invalidateTimer()
//        controller.processorSpeed = .paused
    }
    public func fast() {
//        print("turbo")
//        invalidateTimer()
//        controller.processorSpeed = .turbo
    }
    
    public func unrestricted() {
//        print("unrestricted")
//        invalidateTimer()
//        displayTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
//        displayTimer?.fire()
//        controller.processorSpeed = .unrestricted
    }
    
    func invalidateTimer() {
//        displayTimer?.invalidate()
//        displayTimer = nil
    }
    
    @objc func fireTimer() {
     //   display()
    }
    
    public func reboot() {
        pause()
        shouldProcess = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Change `2.0` to the desired number of seconds.
            self.startProcess()
        }
    }
}
