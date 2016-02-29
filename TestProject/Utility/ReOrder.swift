//
//  RandomOrder.swift
//  TestProject
//
//  Created by Anson on 2015-12-12.
//  Copyright © 2015 SparrowMobile. All rights reserved.
//

import Foundation

class ReOrder {
    static func random<T>(var array: [T], lb: Int, ub: Int) -> Array<T>{
        if (array.count > 1) && (ub > lb){
            let rn = Int(arc4random_uniform(UInt32(ub - lb)))
            if rn != 0{
                swap(&array[rn+lb], &array[lb])
            }
            return ReOrder.random(array, lb: lb+1, ub: ub)
        }
        else{
            return array
        }
    }
}
