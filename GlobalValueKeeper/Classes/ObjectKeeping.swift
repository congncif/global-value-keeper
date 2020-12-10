//
//  ObjectKeeping.swift
//  GlobalValueKeeper
//
//  Created by NGUYEN CHI CONG on 12/10/20.
//

import Foundation

// Conform this protocol when your object needs to keep alive another object without declaring explicitly.
public protocol ObjectKeeping: ValueKeepable {
    func keepObject<Object: AnyObject>(_ object: Object, forKey key: String)
    func keptObject<Object: AnyObject>(forKey key: String) -> Object?
    func dropObject(forKey key: String)
}

public extension ObjectKeeping {
    func keepObject<Object: AnyObject>(_ object: Object, forKey key: String = String(describing: Object.self)) {
        keeper.setValue(object, forKey: key, scope: .strong)
    }

    func keptObject<Object: AnyObject>(forKey key: String = String(describing: Object.self)) -> Object? {
        keeper.getValue(forKey: key)
    }

    func dropObject(forKey key: String) {
        keeper.removeValue(forKey: key)
    }

    func dropObject<Object: AnyObject>(_ objectType: Object.Type) {
        dropObject(forKey: String(describing: objectType))
    }
}
