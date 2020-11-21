//
//  InstanceKeepable.swift
//  GlobalValueKeeper
//
//  Created by NGUYEN CHI CONG on 11/21/20.
//

import Foundation

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
