//
//  GlobalValueKeeper.swift
//  GlobalValueKeeper
//
//  Created by NGUYEN CHI CONG on 3/8/20.
//

import Foundation

final class GlobalValueWrapper {
    weak var rawValue: AnyObject?

    init(rawValue: AnyObject) {
        self.rawValue = rawValue
    }
}

public final class GlobalValueKeeper {
    public enum Scope {
        case singleton
        case instance
    }

    private init() {}

    public static let shared = GlobalValueKeeper()

    private var valueTable: [String: AnyObject] = [:]

    public func setValue<T: AnyObject>(_ value: T, forKey key: String = String(describing: T.self), scope: Scope = .instance) {
        cleanTable()
        switch scope {
        case .singleton:
            valueTable[key] = value
        case .instance:
            let wrapper = GlobalValueWrapper(rawValue: value)
            valueTable[key] = wrapper
        }
    }

    public func removeValue(forKey key: String) {
        cleanTable()
        valueTable.removeValue(forKey: key)
    }

    public func getValue<T: AnyObject>(forKey key: String = String(describing: T.self)) -> T? {
        cleanTable()
        if let value = valueTable[key] as? GlobalValueWrapper {
            return value.rawValue as? T
        } else {
            return valueTable[key] as? T
        }
    }

    private func cleanTable() {
        let newTable = valueTable.compactMapValues { (object) -> AnyObject? in
            if let value = object as? GlobalValueWrapper {
                return value.rawValue != nil ? value : nil
            } else {
                return object
            }
        }
        valueTable = newTable
    }
}

public func globalValue<T: AnyObject>(_ valueFactory: @autoclosure () -> T, scope: GlobalValueKeeper.Scope = .instance) -> T {
    let newValue = valueFactory()
    GlobalValueKeeper.shared.setValue(newValue, scope: scope)
    return newValue
}

public func globalValue<T: AnyObject>() -> T? {
    GlobalValueKeeper.shared.getValue()
}