//
//  File.swift
//  FAC_6502
//
//  Created by Mike Hall on 14/03/2025.
//

import Foundation

public extension FAC_6502 {
    func process() async{
        shouldProcess = true
        //resetProcessor()
        //standard()
        while shouldProcess {
            if processorSpeed == .paused {
                await render()
                try? await Task.sleep(nanoseconds: 16_000_000)
                let _ = processorSpeed
            } else {
                await preProcess()
                 await fetchAndExecute()
                await postProcess()
            }
            
        }
        print("Process complete")
    }
    
    func render() async {
        if processorSpeed != .paused {
            let targetTime = frameStarted + (1.0 / Double(processorSpeed.rawValue))
            let now = Date().timeIntervalSince1970
            if targetTime > now {
                let sleepNanos = UInt64((targetTime - now) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: sleepNanos)
            }
            frameStarted = Date().timeIntervalSince1970
            frameCompleted = false
        }
    //    if controller.processorSpeed != .unrestricted {
            await display()
     //   }
        await handleInterupt()
//        if loggingService.isLoggingProcessor {
//                   loggingService.logProcessor(message: lastPCValues.map{"\($0)"}.joined(separator: "-"))
//                   lastPCValues.removeAll()
//        }
   
    }
    
//    func preProcess() async {
//        if PC == 0xEB63{
//            print("Screen write")
//        }
//    }
//    
//    func postProcess() async {
//        if false {
//            print("")
//        }
//    }
//    
    func standard() async {
        await resume()
    }
    
    func resume() async {
//        print("standard")
//        invalidateTimer()
        processorSpeed = .standard
    }
    
    func pause() async {
//            print("paused")
//        invalidateTimer()
        processorSpeed = .paused
    }
   
    func fast() async {
//        print("turbo")
//        invalidateTimer()
        processorSpeed = .turbo
    }
    
    func unrestricted() async {
//        print("unrestricted")
//        invalidateTimer()
//        displayTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
//        displayTimer?.fire()
        processorSpeed = .unrestricted
    }
    
    func invalidateTimer() async {
//        displayTimer?.invalidate()
//        displayTimer = nil
    }
    
    @objc func fireTimer() async {
     //   display()
    }
    
    func reboot() async {
//        await pause()
//        shouldProcess = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Change `2.0` to the desired number of seconds.
//            self.startProcess()
//        }
    }
}
