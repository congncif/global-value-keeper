//
//  InstanceKeepable.swift
//  GlobalValueKeeper
//
//  Created by NGUYEN CHI CONG on 11/21/20.
//

import Foundation

// Conform this protocol when your object needs to self-control itself lifecycle.
// Note: Once the instance kept, it won't be released until dropInstance() called.
public protocol InstanceKeepable: AnyObject {
    func keepInstance()
    func dropInstance()
}

extension InstanceKeepable {
    private var keeper: GlobalValueKeeper { .shared }

    public func keepInstance() {
        let objectId = ObjectIdentifier(self)
        keeper.setValue(self, forKey: objectId, scope: .strong)
    }

    public func dropInstance() {
        let objectId = ObjectIdentifier(self)
        keeper.removeValue(forKey: objectId)
    }
}
