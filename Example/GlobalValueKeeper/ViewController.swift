//
//  ViewController.swift
//  GlobalValueKeeper
//
//  Created by CONG NGUYEN CHI on 03/08/2020.
//  Copyright (c) 2020 CONG NGUYEN CHI. All rights reserved.
//

import GlobalValueKeeper
import UIKit

class SomeValue {
    var value: String = "Some string"
}

class SubValue: SomeValue {
    override init() {
        super.init()
        value = "Sub string"
    }
}

class Sub2Value: SomeValue {
    override init() {
        super.init()
        value = "Sub string 2"
    }
}

class SomeClass: NSObject {
    var value: SomeValue = globalValue(SomeValue())
    lazy var value2: SubValue = globalValue(SubValue(), scope: .associatedObject(self))
}

class ViewController: UIViewController {
    var some: SomeClass? = SomeClass()

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = some?.value2

        var value1: SomeValue? = globalValue()
        print(String(describing: value1?.value))

        let subValue: SubValue? = globalValue()
        print(String(describing: subValue?.value))

        value1 = nil
        some = nil

        let value2: SomeValue? = globalValue()
        print(String(describing: value2?.value))

        let subValue2: SubValue? = globalValue()
        print(String(describing: subValue2?.value))

        var newValue: Sub2Value? = globalValue(Sub2Value())
        attachedData = newValue

        newValue = nil

        let newValue2: Sub2Value? = globalValue()
        print(String(describing: newValue2?.value))
    }
}
