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
    private var handlers: [() -> Void] = []

    public init() {}

    func onRelease(_ handler: @escaping () -> Void) {
        handlers.append(handler)
    }

    deinit {
        handlers.forEach { handler in
            handler()
        }
    }
}

public final class GlobalValueKeeper {
    public enum Scope {
        case strong
        case weak
        case associated(ObjectLivable)
    }

    public init() {}

    public static let shared = GlobalValueKeeper()

    private var valueTable: [AnyHashable: AnyObject] = [:]

    public func setValue<Object: AnyObject>(_ value: Object, forKey key: AnyHashable = String(describing: Object.self), scope: Scope = .weak) {
        cleanTable()
        switch scope {
        case .strong:
            valueTable[key] = value
        case .weak:
            let wrapper = GlobalValueWrapper(rawValue: value)
            valueTable[key] = wrapper
        case let .associated(object):
            valueTable[key] = value
            object.releasePool.onRelease { [unowned self] in
                self.removeValue(forKey: key)
            }
        }
    }

    public func removeValue(forKey key: AnyHashable) {
        cleanTable()
        valueTable.removeValue(forKey: key)
    }

    public func getValue<Object: AnyObject>(forKey key: AnyHashable = String(describing: Object.self)) -> Object? {
        cleanTable()
        if let value = valueTable[key] as? GlobalValueWrapper {
            return value.rawValue as? Object
        } else {
            return valueTable[key] as? Object
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

// MARK: - Interface

public protocol ValueKeepable {
    var keeper: GlobalValueKeeper { get }
}

public extension ValueKeepable {
    var keeper: GlobalValueKeeper { .shared }
}

// MARK: - Global functions

public func globalValue<Object: AnyObject>(
    _ valueFactory: @autoclosure () -> Object,
    forKey key: AnyHashable = String(describing: Object.self),
    scope: GlobalValueKeeper.Scope = .weak
) -> Object {
    let newValue = valueFactory()
    GlobalValueKeeper.shared.setValue(newValue, forKey: key, scope: scope)
    return newValue
}

public func globalValue<Object: AnyObject>(forKey key: AnyHashable = String(describing: Object.self)) -> Object? {
    GlobalValueKeeper.shared.getValue(forKey: key)
}

public func removeGlobalValue(forKey key: AnyHashable) {
    GlobalValueKeeper.shared.removeValue(forKey: key)
}

public func removeGlobalValue<Object: AnyObject>(_ valueType: Object.Type) {
    GlobalValueKeeper.shared.removeValue(forKey: String(describing: valueType))
}
