//
//  ObjectTogetherLivable.swift
//  GlobalValueKeeper
//
//  Created by NGUYEN CHI CONG on 11/21/20.
//

import Foundation

public protocol ObjectTogetherLivable: ValueKeepable, AnyObject {
    func liveTogether(with object: ObjectLivable)
}

extension ObjectTogetherLivable {
    public func liveTogether(with object: ObjectLivable) {
        let objectId = ObjectIdentifier(self)
        keeper.setValue(self, forKey: objectId, scope: .associated(object))
    }
}
