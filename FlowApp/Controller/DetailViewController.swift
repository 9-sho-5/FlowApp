//
//  DetailViewController.swift
//  FlowApp
//
//  Created by Kusunose Hosho on 2020/06/11.
//  Copyright © 2020 Kusunose Hosho. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    let memoCollection = MemoCollection.sharedInstance
    @IBOutlet var detail: UITextView!
    var toDetailViewtext: String?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detail.layer.borderColor = UIColor.gray.cgColor
        detail.text = toDetailViewtext
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        detail.text = detail.text
        memoCollection.memos[index!].detail = detail.text
        print(memoCollection.memos[index!].detail)
        self.memoCollection.save()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
