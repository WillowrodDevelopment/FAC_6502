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
//            if controller.processorSpeed == .paused {
//                render()
//                let _ = controller.processorSpeed
//            } else {
                await preProcess()
                 await fetchAndExecute()
                await postProcess()
//            }
            
        }
        print("Process complete")
    }
    
    func render() async {
 //       if controller.processorSpeed != .paused {
            while frameStarted + (1.0 / 50) >= Date().timeIntervalSince1970 { //Double(controller.processorSpeed.rawValue)
                // Idle while we wait for frame to catch up
                
            }
            frameStarted = Date().timeIntervalSince1970
            frameCompleted = false
//        }
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
        //resume()
    }
    
    func resume() async {
//        print("standard")
//        invalidateTimer()
//        controller.processorSpeed = .standard
    }
    
    func pause() async {
//            print("paused")
//        invalidateTimer()
//        controller.processorSpeed = .paused
    }
   
    func fast() async {
//        print("turbo")
//        invalidateTimer()
//        controller.processorSpeed = .turbo
    }
    
    func unrestricted() async {
//        print("unrestricted")
//        invalidateTimer()
//        displayTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
//        displayTimer?.fire()
//        controller.processorSpeed = .unrestricted
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
