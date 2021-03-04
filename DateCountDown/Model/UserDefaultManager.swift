//
//  UserDefaultManager.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/27.
//

import Cocoa

/** for custom class */
@propertyWrapper
public class UserDefaultsObjectMaster<T: JSONCodable> {

    private let defaults: UserDefaults = .standard
    private let key: String
    private let defaultValue: T

    public init(_ key: String,
                _ defaultValue: T)
    {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            guard let json = defaults.value(forKey: key) as? String else { return defaultValue }
            let value = T.init(jsonStr: json)
            return value ?? defaultValue
        }
        set {
            defaults.set(newValue.toJsonString(), forKey: key)
        }
    }
}

/** for custom Array of class */
@propertyWrapper
public class UserDefaultsArrayMaster<T: JSONCodable> {

    private let defaults: UserDefaults = .standard
    private let key: String
    private let defaultValue: [T]

    public init(_ key: String,
                _ defaultValue: [T])
    {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: [T] {
        get {
            let jsonString = defaults.value(forKey: key) as? String
            let array = [T].deserialize(jsonStr: jsonString)?.compactMap{ $0 }
            return array ?? defaultValue
        }
        set {
            defaults.set(newValue.toJsonString() ?? "", forKey: key)
        }
    }
}

/** for base class. ex: String, Int, Double, etc... */
@propertyWrapper
public class UserDefaultsMaster<T> {

    private let defaults: UserDefaults = .standard
    private let key: String
    private let defaultValue: T

    public init(_ key: String,
                _ defaultValue: T)
    {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            return (defaults.object(forKey: key) as? T) ?? defaultValue
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }
}

struct CountDown : JSONCodable{
    let name:String
    let date:String
    var isInvalid:Bool = false
}

