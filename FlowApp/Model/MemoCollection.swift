//
//  MemoCollection.swift
//  FlowApp
//
//  Created by Kusunose Hosho on 2020/06/10.
//  Copyright © 2020 Kusunose Hosho. All rights reserved.
//

import UIKit

class MemoCollection: NSObject {
    static let sharedInstance = MemoCollection()
    var memos:[Memo] = []
    
    func addMemoCollection(memo: Memo){
        self.memos.append(memo)
        self.save()
    }
    //Memoクラスのインスタンスの要素を辞書型に変換してUserDefaultsに保存する
    func save() {
        var memoList: Array<Dictionary<String, AnyObject>> = []
        for memo in memos {
            let memoDic = MemoCollection.convertDictionary(memo: memo)  //varに変更
            memoList.append(memoDic)
        }
        let defaults = UserDefaults.standard
        defaults.set(memoList, forKey: "memoLists")
        defaults.synchronize()
    }
    //キーを設定して辞書の型にMemoの情報を入れる
    class func convertDictionary(memo: Memo) -> Dictionary<String, AnyObject> {
        var dic = Dictionary<String, AnyObject>()
        dic["text"] = memo.text as AnyObject
        dic["detaili"] = memo.detail as AnyObject
        dic["priority"] = memo.priority.rawValue as AnyObject
        return dic
    }
    //辞書型をmemo型にする設定
    class func convertMemoModel(attiributes: Dictionary<String, AnyObject>) -> Memo {
        let memo = Memo()
        memo.text = attiributes["title"] as! String
        memo.detail = attiributes["descript"] as! String
        memo.priority = MemoPriority(rawValue: attiributes["priority"] as! Int)!
        return memo
    }
    //UserDefaultsに保存された辞書型をtodo型に変換して取得
    func fetchTodos() {
        let defaults = UserDefaults.standard
        if let memoList = defaults.object(forKey: "memo¥oLists") as? Array<Dictionary<String, AnyObject>> {
            for memoDic in memoList {
                let memo = MemoCollection.convertMemoModel(attiributes: memoDic)
                self.memos.append(memo)
            }
        }
    }
}
