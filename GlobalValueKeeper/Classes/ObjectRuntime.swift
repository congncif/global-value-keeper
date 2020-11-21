//
//  ObjectRuntime.swift
//  GlobalValueKeeper
//
//  Created by NGUYEN CHI CONG on 11/21/20.
//

import Foundation

// MARK: - ObjectLivable, ObjectDataAttachable

private var releasePoolKey: UInt8 = 100
private var attachedDataKey: UInt8 = 101

public protocol ObjectLivable: AnyObject {
    var releasePool: ReleasePool { get }
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

public protocol ObjectDataAttachable: AnyObject {
    var attachedData: Any? { get set }
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

    public func attach<ValueType>(value: ValueType?, key: String? = nil) {
        let storeKey = key ?? String(describing: ValueType.self)
        var dictData = attachedData as? [String: Any] ?? [:]
        dictData[storeKey] = value
        attachedData = dictData
    }

    public func attachedValue<ValueType>(forKey key: String? = nil) -> ValueType? {
        let storeKey = key ?? String(describing: ValueType.self)
        let dictData = attachedData as? [String: Any]
        let data = dictData?[storeKey]
        return data as? ValueType
    }

    public func attachedValue<ValueType>(forKey key: String? = nil, defaultValue: ValueType) -> ValueType {
        attachedValue(forKey: key) ?? defaultValue
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
