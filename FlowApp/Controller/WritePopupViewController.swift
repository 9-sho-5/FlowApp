//
//  WritePopupViewController.swift
//  FlowApp
//
//  Created by Kusunose Hosho on 2020/06/10.
//  Copyright © 2020 Kusunose Hosho. All rights reserved.
//

import UIKit
import SCLAlertView
import RealmSwift

class WritePopupViewController: UIViewController, UITextFieldDelegate {

    var createdMemoclass: Results<CreatedMemoClass>!
    let realm = try! Realm()
    
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    @IBOutlet var uiView: UIView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var detail: UITextView!
    @IBOutlet var addButton: UIButton!
    
    let memoCollection = MemoCollection.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if memoCollection.memos.count == 0 {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                
        }
        let alertView = SCLAlertView(appearance: appearance)
            alertView.showInfo("Info", subTitle: "優先度を選択してタスク管理に役立てよう！\n優先度：😰[⭐️⭐️⭐️⭐️⭐️]\n　　 　  😅[⭐️⭐️⭐️⭐️　  ]\n　 　　  🙂[⭐️⭐️⭐️　  　  ]\n　 　　  🤔[⭐️⭐️　  　  　  ]\n　　　   😪[⭐️　  　  　  　  ]", timeout:SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 5.0, timeoutAction:timeoutAction))
        }
        textField.placeholder = "Write Title Memo"
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.delegate = self
        
        uiView.layer.cornerRadius = 8
        addButton.layer.cornerRadius = 8
        
        uiView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0) // 上向きの影
        uiView.layer.shadowRadius = 3;
        uiView.layer.shadowOpacity = 0.8;
        
        // 枠のカラー
        detail.layer.borderColor = UIColor.gray.cgColor
        
        // 枠の幅
        detail.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        detail.layer.cornerRadius = 10.0
        detail.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        detail.resignFirstResponder()
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func dismissAddPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add() {
        if textField.text!.isEmpty {
            
            SCLAlertView().showError("Error", subTitle: "記述がありません") // Error
            
        } else {
            
            let createdMemo = CreatedMemoClass()
            try! realm.write{
                createdMemo.createdAt = Date()
                realm.add(createdMemo)
            }
            
            let memo = Memo()
            
            memo.text = textField.text!
            memo.detail = detail.text!
            memo.priority = MemoPriority(rawValue: prioritySegment.selectedSegmentIndex)!
            self.memoCollection.addMemoCollection(memo: memo)
        
            textField.text = ""
            detail.text = ""
            
        }
        
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
