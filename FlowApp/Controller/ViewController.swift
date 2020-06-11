//
//  ViewController.swift
//  FlowApp
//
//  Created by Kusunose Hosho on 2020/06/10.
//  Copyright © 2020 Kusunose Hosho. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var createMemoButton: UIBarButtonItem!
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet weak var priorityFace: UIView!
    
    let memoCollection = MemoCollection.sharedInstance
    
    var createdMemoclass: Results<CreatedMemoClass>!
    let realm = try! Realm()
    
    var models:Any = []
    
    @IBOutlet var searchBar: UISearchBar!
    
    var searchMemo = [String]()
    var searching = false
    var topSafeAreaHeight: CGFloat = 0
    private var searchBarHeight: CGFloat = 44
    
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoCollection.fetchTodos()
        
        table.contentOffset = CGPoint(x: 0, y: searchBarHeight)
        
        searchBar.showsCancelButton = false
        
        searchBar.delegate = self
        table.delegate = self
        table.dataSource = self
        
        let realm = try! Realm()
        createdMemoclass = realm.objects(CreatedMemoClass.self)
    
        notificationToken = createdMemoclass.observe { [weak self] _ in
            self?.table.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            return searchMemo.count
        } else {
            print(self.memoCollection.memos.count)
            return self.memoCollection.memos.count
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

//            models.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.memoCollection.memos.remove(at: indexPath.row)
            
            UIView.animate(withDuration: 1.5, delay: 0.0, options: [.curveLinear], animations: {
                    tableView.deleteRows(at: [indexPath], with: .top)
            }, completion: nil)

        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying: UITableViewCell, forRowAt: IndexPath) {
        if self.memoCollection.memos.count == 0{
            editButton.title = "Edit"
            table.isEditing = false
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear], animations: {
                self.table.contentOffset = CGPoint(x: 0, y: self.searchBarHeight+11)
            }, completion: nil)
        }
    }
        
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //cell移動設定
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let memo = self.memoCollection.memos[sourceIndexPath.row]
        self.memoCollection.memos.remove(at: sourceIndexPath.row)
        self.memoCollection.memos.insert(memo, at: destinationIndexPath.row)
        
//        models.swapAt(sourceIndexPath.row, sourceIndexPath.row)
//
//        let moveObjTmp = models[sourceIndexPath.row]
//        models.remove(at: sourceIndexPath.row)
//        models.insert(moveObjTmp, at: destinationIndexPath.row)
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        if searching {
            cell.textLabel?.text = searchMemo[indexPath.row]
        } else {
            let memo = self.memoCollection.memos[indexPath.row]
            cell.detailTextLabel!.text = memo.detail
            cell.textLabel?.text = memo.text
            let priorityIcon = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            priorityIcon.layer.cornerRadius = 6
            priorityIcon.text = memo.priority.face()
            cell.accessoryView = priorityIcon

//            cell.textLabel?.text = models[indexPath.row]
//            models.append(memos[indexPath.row].text)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    @IBAction func leftBarBtnClicked(sender: UIButton) {
        // 一瞬で切り替わると不自然なのでアニメーションを付与する
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear], animations: {
                self.table.contentOffset = CGPoint(x: 0, y: -self.topSafeAreaHeight)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        table.contentOffset = CGPoint(x: 0, y: searchBarHeight)
    }
    
    @IBAction func didTapSort() {
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

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchMemo = self.memoCollection.memoCollectionToModels.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        print(searchText.count)
        searching = true
        table.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        table.reloadData()
    }
    
    
}

