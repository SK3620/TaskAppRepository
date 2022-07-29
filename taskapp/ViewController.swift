//
//  ViewController.swift
//  taskapp
//
//  Created by 鈴木健太 on 2022/07/28.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
    }
//セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 0
      }
    
//各セルの内容を返す　再利用可能のセルを得る
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//          cellには再利用可能なセルが格納されている。
//          画面に表示するセルの数+Reuse Queueに保管しているセルの数を使用してる。
          return cell
      }
    
//    各セルを選択したときに呼ばれるメソッド セルタップしたときにタスク入力画面に遷移させる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSugue", sender: nil)
        
    }
    
//    セルが削除可能なことを伝えるメソッド　また、並び替えが可能かどうかなどの編集ができるかどうかを返すメソッド
//    taskappでは、削除可能であることを知らせるため、（削除を可能にするため）、 .delete を返す。
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return .delete
    }
    
//    deleteボタンが押されたときによびだされるメソッド　セルが削除されるときに呼ばれる　データベースからタスクを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    }
      

}

