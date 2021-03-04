//
//  BatteryImp.swift
//  DateCountDown
//
//  Created by sabrina on 2021/3/4.
//

import Foundation
import IOKit

enum BatteryError: Error { case error }

class BatteryImp : NSObject {
    
    fileprivate enum Key: String {
            case CurrentCapacity  = "BatteryPercent"
            case ProduceName      = "Product"
        }
    
    static let IOSERVICE_BATTERY = "AppleDeviceManagementHIDEventService"
    private let localNotify = LocalNotifications()
    private let lowBattery: Int = 20
    
    func checkBattery() {
        var serialPortIterator = io_iterator_t()
        var object : io_object_t
        let masterPort: mach_port_t = kIOMasterPortDefault
        let matchingDict : CFDictionary = IOServiceMatching(BatteryImp.IOSERVICE_BATTERY)
        let kernResult = IOServiceGetMatchingServices(masterPort, matchingDict, &serialPortIterator)
        var lowBatteryDevices:[String:Int] = [:]
        
        if KERN_SUCCESS == kernResult {
            repeat {
                object = IOIteratorNext(serialPortIterator)
                if object != 0, let percent = IORegistryEntryCreateCFProperty(object, Key.CurrentCapacity.rawValue as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Int {
                    let name = IORegistryEntryCreateCFProperty(object, Key.ProduceName.rawValue as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? String ?? "NO"
                    print("\(name), Battery = \(percent)%")
                    if percent <= lowBattery {
                        lowBatteryDevices[name] = percent
                    }
                }
            } while object != 0
            
            //MARK: Send Local Notify
            if !lowBatteryDevices.isEmpty {
                var body = ""
                for (key, value) in lowBatteryDevices {
                    body += String(format: "【%@】電池電量：%d%%\n", key, value)
                }
                let df = DateFormatter()
                df.dateFormat = "yyyyMMddHHmmss"
                let registeriIdentifier = df.string(from: Date())
                localNotify.register(title: "!!! 電池電量低，請盡快充電 !!!", body: body, identifier: registeriIdentifier, date: Date()) { (msg) in
                    print(msg)
                } failure: { (err) in
                    print(err.localizedDescription)
                }
            }
            
            //Release object
            IOObjectRelease(object)
        }
        IOObjectRelease(serialPortIterator)
    }
}
