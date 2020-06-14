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
import MMPopLabel

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MMPopLabelDelegate {
    
    var instroLabel: MMPopLabel!
    @IBOutlet weak var createMemoButton: UIBarButtonItem!
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
//    @IBOutlet var saveButton: UIButton!
    @IBOutlet weak var priorityFace: UIView!
    
    let memoCollection = MemoCollection.sharedInstance
    var toDetailViewtext: String = ""
    var index = 0
    
    var createdMemoclass: Results<CreatedMemoClass>!
    let realm = try! Realm()
    
    var models:Any = []
        
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MMPopLabel.appearance().labelColor = UIColor.blue
        // ポップアップの文字色
        MMPopLabel.appearance().labelTextColor = UIColor.white
        // ポップアップの文字ハイライト時の色
        MMPopLabel.appearance().labelTextHighlightColor = UIColor.green
        // ポップアップの文字フォント
        MMPopLabel.appearance().labelFont = UIFont(name: "HelveticaNeue-Light", size: 12)
        // ポップアップのボタンの文字フォント
        MMPopLabel.appearance().buttonFont = UIFont(name: "HelveticaNeue", size: 12)
        
        instroLabel = MMPopLabel(text: "チュートリアルメッセージ")
        instroLabel.delegate = self
        
        let skipButton = UIButton(frame: CGRect.zero)
        skipButton.setTitle(NSLocalizedString("Skip Tutorial", comment: "Skip Tutorial Button"), for: .normal)
        instroLabel.add(skipButton)
         
        let okButton = UIButton(frame: CGRect.zero)
        okButton.setTitle(NSLocalizedString("OK, Got It!", comment: "Dismiss Button"), for: .normal)
        instroLabel.add(okButton)
        
        self.view.addSubview(instroLabel)
        
        memoCollection.fetchTodos()
        
        table.delegate = self
        table.dataSource = self
        
        let realm = try! Realm()
        createdMemoclass = realm.objects(CreatedMemoClass.self)
    
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
            let priorityIcon = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            priorityIcon.layer.cornerRadius = 6
            priorityIcon.text = memo.priority.face()
            cell.accessoryView = priorityIcon
        return cell
    }
    
    //cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @IBAction func didTapSort() {
        let target = editButton
        instroLabel.pop(at: target)
        
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
