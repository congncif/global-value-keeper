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

public final class ReleasePool {
    private var handler: (() -> Void)?

    public init() {}

    func setHandler(_ handler: @escaping () -> Void) {
        self.handler = handler
    }

    deinit {
        handler?()
    }
}

public final class GlobalValueKeeper {
    public enum Scope {
        case singleton
        case instance
        case associatedObject(ReleasePool)
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
        case let .associatedObject(releasePool):
            valueTable[key] = value
            releasePool.setHandler { [unowned self] in
                self.removeValue(forKey: key)
            }
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

// MARK: -

public func globalValue<T: AnyObject>(_ valueFactory: @autoclosure () -> T, scope: GlobalValueKeeper.Scope = .instance) -> T {
    let newValue = valueFactory()
    GlobalValueKeeper.shared.setValue(newValue, scope: scope)
    return newValue
}

public func globalValue<T: AnyObject>() -> T? {
    GlobalValueKeeper.shared.getValue()
}

// MARK: -

private var releasePoolKey: UInt8 = 100

extension NSObject {
    private func getAssociatedObject<T>(key: inout UInt8) -> T? {
        return objc_getAssociatedObject(self, &key) as? T
    }

    private func setAssociatedObject<T>(key: inout UInt8,
                                        value: T?,
                                        policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, &key, value, policy)
    }

    public var releasePool: ReleasePool {
        var internalPool: ReleasePool
        if let pool = self.pool {
            internalPool = pool
        } else {
            internalPool = ReleasePool()
            pool = internalPool
        }
        return internalPool
    }

    private var pool: ReleasePool? {
        set {
            setAssociatedObject(key: &releasePoolKey, value: newValue)
        }

        get {
            getAssociatedObject(key: &releasePoolKey)
        }
    }
}
