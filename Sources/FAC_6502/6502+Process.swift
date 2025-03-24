//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 14/03/2025.
//

import Foundation

public extension FAC_6502 {
    func process() {
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
    
    func preProcess() {
//        if PC == 0xEB48 && shouldLog{
//            print("Screen write")
//        }
    }
    
    func postProcess() {
        if false {
            print("")
        }
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
