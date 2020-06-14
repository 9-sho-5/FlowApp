//
//  DetailViewController.swift
//  FlowApp
//
//  Created by Kusunose Hosho on 2020/06/11.
//  Copyright © 2020 Kusunose Hosho. All rights reserved.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController {
    
    var createdMemoclass: Results<CreatedMemoClass>!
    let realm = try! Realm()
    
    let memoCollection = MemoCollection.sharedInstance
    
    @IBOutlet var detail: UITextView!
    @IBOutlet var textField: UITextField!
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    
    var toDetailViewtext: String?
    var totextFieldtext: String?
    var toPriority: Int?
    
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.tapGesture(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
        
        prioritySegment.selectedSegmentIndex = toPriority!
        
        detail.layer.borderColor = UIColor.gray.cgColor
        detail.text = toDetailViewtext
        textField.text = totextFieldtext
        print(MemoPriority(rawValue: toPriority!)!)
    }
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
        detail.resignFirstResponder()
    }
    
    @IBAction func dismissAddPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        detail.resignFirstResponder()
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        memoCollection.memos[index!].detail = detail.text
        memoCollection.memos[index!].text = textField.text!
        
        memoCollection.memos[index!].priority = MemoPriority(rawValue: prioritySegment.selectedSegmentIndex)!
        
        self.memoCollection.save()
        
        let detail = CreatedMemoClass()
        try! realm.write{
            realm.add(detail)
        }
    }
}
