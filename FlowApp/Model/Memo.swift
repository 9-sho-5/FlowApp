//
//  Memo.swift
//  FlowApp
//
//  Created by Kusunose Hosho on 2020/06/10.
//  Copyright © 2020 Kusunose Hosho. All rights reserved.
//

import UIKit

class Memo: NSObject {
    var text = ""
    var detail = ""
    var priority: MemoPriority = .Low
}

enum MemoPriority: Int {
    case Low    = 0
    case Low_Middle = 1
    case Middle = 2
    case High_Middle = 3
    case High   = 4
    
    func face() -> String {
    switch self {
    case .Low:
        let face1 = "😪"
        return face1
    case .Low_Middle:
        let face2 = "🤔"
        return face2
    case .Middle:
        let face3 = "🙂"
        return face3
    case .High_Middle:
        let face4 = "😅"
        return face4
    case .High:
        let face5 = "😰"
        return face5
    
        }
    }
}
