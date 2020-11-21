//
//  ObjectTogetherLivable.swift
//  GlobalValueKeeper
//
//  Created by NGUYEN CHI CONG on 11/21/20.
//

import Foundation

public protocol ObjectTogetherLivable: AnyObject {
    func liveTogether(with object: ObjectLivable)
}

extension ObjectTogetherLivable {
    public func liveTogether(with object: ObjectLivable) {
        let objectId = ObjectIdentifier(self)
        GlobalValueKeeper.shared.setValue(self, forKey: objectId, scope: .associatedObject(object))
    }
}
