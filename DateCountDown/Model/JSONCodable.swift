//
//  JSONCodable.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/27.
//

import Cocoa

public typealias JsonObject = [String: Any]

public protocol JSONCodable: Codable {
    func toDictionary() -> JsonObject?
    func toJsonString() -> String?
    init?(json: JsonObject)
    init?(jsonStr: String)
}

extension JSONCodable {
    public func toDictionary() -> JsonObject? {
        // Encode the data
        if let jsonData = try? JSONEncoder().encode(self),
            // Create a dictionary from the data
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JsonObject {
            return dict
        }
        return nil
    }
    
    public func toJsonString() -> String? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonStr = String(data: data, encoding: .utf8)
            return jsonStr
        }catch let error {
            JSONCodableLog.debug("\n ************* JSONCodable Parser Error Begin *****************\n")
            JSONCodableLog.debug(error)
            JSONCodableLog.debug("\n ************* JSONCodable Parser Error End *****************\n")
            return nil
        }
    }
    
    public init?(json: JsonObject) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let object = try JSONDecoder().decode(Self.self, from: data)
            self = object
        } catch let error {
            JSONCodableLog.debug("\n ************* JSONCodable Parser Error Begin *****************\n")
            JSONCodableLog.debug(json)
            JSONCodableLog.debug(error)
            JSONCodableLog.debug("\n ************* JSONCodable Parser Error End *****************\n")
            return nil
        }
    }
    
    public init?(jsonStr: String) {
        let data = Data(jsonStr.utf8)
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let dict = json as? JsonObject else { return nil }
            self.init(json: dict)
        }catch let error {
            JSONCodableLog.debug("\n ************* JSONCodable Parser Error Begin *****************\n")
            JSONCodableLog.debug(jsonStr)
            JSONCodableLog.debug(error)
            JSONCodableLog.debug("\n ************* JSONCodable Parser Error End *****************\n")
            return nil
        }
    }
}

public extension Array where Element : JSONCodable {
    
    static func deserialize(jsonStr:String?) -> [Element?]? {
        guard let jsonStr = jsonStr ,
              let data = jsonStr.data(using: .utf8) else { return nil }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            guard let arr = jsonObject as? [Any] else { return nil }
            return arr.map { (item) -> Element? in
                if let codable = item as? JsonObject {
                    return Element(json: codable)
                }
                return nil
            }
        }catch let error {
            JSONCodableLog.debug("\n ************* JSONCodable Parser Error Begin *****************\n")
            JSONCodableLog.debug(jsonStr)
            JSONCodableLog.debug(error)
            JSONCodableLog.debug("\n ************* JSONCodable Parser Error End *****************\n")
            return nil
        }
    }
}

extension Collection where Iterator.Element : JSONCodable {
    func toJson() -> [[String:Any]?] { return self.map({ $0.toDictionary() }) }
    
    func toJsonString() -> String? {
        let arr = self.toJson()
        if JSONSerialization.isValidJSONObject(arr) {
            do {
                let data = try JSONSerialization.data(withJSONObject: arr, options: .prettyPrinted)
                return String(data: data, encoding: .utf8)
            }catch let error {
                JSONCodableLog.debug("\n ************* JSONCodable Parser Error Begin *****************\n")
                JSONCodableLog.debug(self)
                JSONCodableLog.debug(error)
                JSONCodableLog.debug("\n ************* JSONCodable Parser Error End *****************\n")
                return nil
            }
        }else{
            return nil
        }
    }
}

struct JSONCodableLog {
    static func debug<T>(_ message:T, file:String = #file, function:String = #function, line:Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[Debug] [\(fileName)] [\(line)] [\(function)] \(message)")
        #endif
    }
}
