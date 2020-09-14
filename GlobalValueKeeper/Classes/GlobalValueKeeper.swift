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
        case singleton
        case instance
        case associatedObject(ObjectLivable)
    }

    private init() {}

    public static let shared = GlobalValueKeeper()

    private var valueTable: [AnyHashable: AnyObject] = [:]

    public func setValue<T: AnyObject>(_ value: T, forKey key: AnyHashable = String(describing: T.self), scope: Scope = .instance) {
        cleanTable()
        switch scope {
        case .singleton:
            valueTable[key] = value
        case .instance:
            let wrapper = GlobalValueWrapper(rawValue: value)
            valueTable[key] = wrapper
        case let .associatedObject(object):
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

    public func getValue<T: AnyObject>(forKey key: AnyHashable = String(describing: T.self)) -> T? {
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

// MARK: - Interface

public func globalValue<T: AnyObject>(_ valueFactory: @autoclosure () -> T, scope: GlobalValueKeeper.Scope = .instance) -> T {
    let newValue = valueFactory()
    GlobalValueKeeper.shared.setValue(newValue, scope: scope)
    return newValue
}

public func globalValue<T: AnyObject>() -> T? {
    GlobalValueKeeper.shared.getValue()
}

// MARK: - NSObject runtime

extension NSObject: ObjectLivable, ObjectDataAttachable, ObjectTogetherLivable, InstanceKeepable {}

// MARK: - ObjectLivable, ObjectDataAttachable, ObjectTogetherLivable

private var releasePoolKey: UInt8 = 100
private var attachedDataKey: UInt8 = 101

public protocol ObjectLivable: AnyObject {
    var releasePool: ReleasePool { get }
}

public protocol ObjectDataAttachable: AnyObject {
    var attachedData: Any? { get set }
}

extension ObjectLivable {
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
            setAssociatedObject(self, key: &releasePoolKey, value: newValue)
        }

        get {
            getAssociatedObject(self, key: &releasePoolKey)
        }
    }
}

extension ObjectDataAttachable {
    public var attachedData: Any? {
        set {
            setAssociatedObject(self, key: &attachedDataKey, value: newValue)
        }

        get {
            let value: Any? = getAssociatedObject(self, key: &attachedDataKey)
            return value
        }
    }
}

public protocol ObjectTogetherLivable: AnyObject {
    func liveTogether(with object: ObjectLivable)
}

extension ObjectTogetherLivable {
    public func liveTogether(with object: ObjectLivable) {
        let objectId = ObjectIdentifier(self)
        GlobalValueKeeper.shared.setValue(self, forKey: objectId, scope: .associatedObject(object))
    }
}

public protocol InstanceKeepable: AnyObject {
    func keepInstance()
    func dropInstance()
}

extension InstanceKeepable {
    public func keepInstance() {
        let objectId = ObjectIdentifier(self)
        GlobalValueKeeper.shared.setValue(self, forKey: objectId, scope: .singleton)
    }

    public func dropInstance() {
        let objectId = ObjectIdentifier(self)
        GlobalValueKeeper.shared.removeValue(forKey: objectId)
    }
}

// MARK: - associatedObject

private func getAssociatedObject<T>(_ object: Any, key: inout UInt8) -> T? {
    return objc_getAssociatedObject(object, &key) as? T
}

private func setAssociatedObject<T>(_ object: Any,
                                    key: inout UInt8,
                                    value: T?,
                                    policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
    objc_setAssociatedObject(object, &key, value, policy)
}
