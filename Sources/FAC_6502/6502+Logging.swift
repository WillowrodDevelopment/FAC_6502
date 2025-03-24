//
//  6502+Logging.swift
//  FAC_6502
//
//  Created by Mike Hall on 23/03/2025.
//
public extension FAC_6502 {
    func logError(_ message: String) {
        loggingService.logError(message)
    }
    
    func logInfo(_ message: String) {
        loggingService.logInfo(message)
    }
    
    func logWarning(_ message: String) {
        loggingService.logWarning(message)
    }
    
    func logNetwork(_ message: String) {
        loggingService.logNetwork(message)
    }
    
    func logProcessor(_ pc: UInt16, _ message: String) {
        if shouldLog {
            loggingService.logProcessor(pc, message)
        }
    }
    
    func log(_ message: String) {
        loggingService.log(message)
    }
}
