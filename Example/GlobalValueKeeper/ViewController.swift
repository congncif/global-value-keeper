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

class SomeClass {
    var value: SomeValue = globalValue(SomeValue())
    var value2: SubValue = globalValue(SubValue())
}

class ViewController: UIViewController {
    var some: SomeClass? = SomeClass()

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
}