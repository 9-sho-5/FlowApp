//
//  ViewController.swift
//  FlowApp
//
//  Created by Kusunose Hosho on 2020/06/10.
//  Copyright © 2020 Kusunose Hosho. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var identifier: Int = 0
    @IBOutlet weak var createMemoButton: UIBarButtonItem!
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    let memoCollection = MemoCollection.sharedInstance
    var toDetailViewtext: String = ""
    var index = 0
    
    var createdMemoclass: Results<CreatedMemoClass>!
    var editCount: Results<editCounter>!

    let realm = try! Realm()
    
    var models:Any = []
        
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if createdMemoclass.count == 0 {
            let appearance = SCLAlertView.SCLAppearance (
                showCloseButton: true
            )
        let alertView = SCLAlertView(appearance: appearance)
            
            alertView.showInfo("Info", subTitle: "emoji😄を使って\n期限順⬇️にタスク管理しよう！\n\n優先度：😰[⭐️⭐️⭐️⭐️⭐️]\n　　 　  😅[⭐️⭐️⭐️⭐️　  ]\n　　 　  🙂[⭐️⭐️⭐️　  　  ]\n　　 　  🤔[⭐️⭐️　     　    ]\n　　 　  😪[⭐️　  　  　  　 ]")
        }
        
        memoCollection.fetchTodos()
        
        table.delegate = self
        table.dataSource = self
        
        let realm = try! Realm()
        createdMemoclass = realm.objects(CreatedMemoClass.self)
        editCount = realm.objects(editCounter.self)
    
        notificationToken = createdMemoclass.observe { [weak self] _ in
            self?.table.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)

        let memo = self.memoCollection.memos[indexPath.row]
        let storyboard = self.storyboard!
        // 2. 遷移先のViewControllerを取得
        let next = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        //  3. １で用意した遷移先の変数に値を渡す
        next.toDetailViewtext = memo.detail
        next.totextFieldtext = memo.text
        next.toPriority = memo.priority.rawValue
        next.index = indexPath.row
        // 4. 画面遷移実行
//        performSegue(withIdentifier: "DetailViewController", sender: self)
        
        self.present(next, animated: true, completion: nil)
    }

//表示させるmemoの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            print(self.memoCollection.memos.count)
            return self.memoCollection.memos.count

    }
    //編集に関する記述
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        switch editingStyle {
        case .delete:
            self.memoCollection.memos.remove(at: indexPath.row)
            self.memoCollection.save()
            table.deleteRows(at: [indexPath], with: UITableView.RowAnimation.middle)
        default:
            return
        }
    }
    
    //横スライドでの削除をできなくする
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //memoの数が0になった時に編集中を完了にする
    func tableView(_ tableView: UITableView, didEndDisplaying: UITableViewCell, forRowAt: IndexPath) {
        if self.memoCollection.memos.count == 0{
            editButton.title = "Edit"
            table.isEditing = false
        }
    }
    
    //cellの移動を可能にする
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //cell移動設定
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let memo = self.memoCollection.memos[sourceIndexPath.row]
        self.memoCollection.memos.remove(at: sourceIndexPath.row)
        self.memoCollection.memos.insert(memo, at: destinationIndexPath.row)
        self.memoCollection.save()
    }
        
    //cellに表示するもの
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
            let memo = self.memoCollection.memos[indexPath.row]
            cell.detailTextLabel!.text = memo.detail
            cell.textLabel?.text = memo.text
            let priorityIcon = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            priorityIcon.layer.cornerRadius = 6
            priorityIcon.font = priorityIcon.font.withSize(30)
            priorityIcon.text = memo.priority.face()
            cell.accessoryView = priorityIcon
        return cell
    }
    
    //cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @IBAction func didTapSort() {
        
        if editCount.count == 0 {
            let appearance = SCLAlertView.SCLAppearance (
                    showCloseButton: true
                )
            let alertView = SCLAlertView(appearance: appearance)
                
                alertView.showInfo("Info", subTitle: "⚙️　　　　　機　能　　　　　⚙️\n\nMemoの削除❌　　　　　　　　\nMemoの順番の入れ替え🔀\n\n🤔\n\n⚙️　　　　　　　　　　　　　⚙️")
            let createdMemo = editCounter()
            try! realm.write{
                realm.add(createdMemo)
            }
        }
        
        if table.isEditing {
            
            editButton.title = "Edit"
            table.isEditing = false
            
        } else {
            
            editButton.title = "Done"
            table.isEditing = true
            
        }
            table.reloadData()
        }
}
