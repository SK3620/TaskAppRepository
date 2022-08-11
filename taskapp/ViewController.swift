//
//  ViewController.swift
//  taskapp
//
//  Created by 鈴木健太 on 2022/07/28.
//

import UIKit
import RealmSwift
import SwiftUI
//追加する

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskSearchBar: UISearchBar!
  
    
    
//    realmのインスタンスを取得する
    let realm = try! Realm()
//    このインスタンス変数を使って、読み書きメソッドを呼び出す
    
//    DB内のタスクが格納されるリスト
//    日付の近い順でソート　昇順
//    移行内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
//    追加する　ここでデータベースを取得してる
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        taskSearchBar.delegate = self
//        文字が入力されていない状態でも、rerunキー（search)ボタンを押すことができる。
        taskSearchBar.enablesReturnKeyAutomatically = false
        
        taskSearchBar.placeholder = "タスク一覧検索入力欄"
    }
    
  
    
// segueで画面遷移がするときに呼ばれる　新しいデータを新規作成する＋ボタンと既存データの編集などのための"cellSegue"identiferを通したセルタップ時の時の２パターンがあるから、if文で判別する。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
//            tableView.indexPathForSelectedRow　identifies the row and section of the selected row
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
//    タスク作成、編集画面からもどってきたときに画面を更新するメソッド
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
//セルの数を返す　データの配列であるtaskArrayの要素数を返す。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return taskArray.count
//        return 10
      }
    
//再利用可能な各セルに対して、内容を返す　再利用可能のセルを得る
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//          cellには再利用可能なセルが格納されている。
//          画面に表示するセルの数+Reuse Queueに保管しているセルの数を使用してる。
       
        
          
//          let taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
//          データベースを取得。
          //          Cellに値を設定する
          let task = self.taskArray[indexPath.row]
          cell.textLabel?.text = task.title
//          textLable　は　The label to use for the main textual content of the table cell.
//          DateFormatterクラスは日付を表すDateクラスを任意の形の文字列に変換する機能を持ちます
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd HH:mm"
//          Date 型の値をフォーマットして String に変換するのに一番簡単なのは DateFormatter を使う方法です。
//          DateFormatter は日付から文字列、文字列から日付への変換やフォーマットをするためにあるクラスです。
//          DateFormatter の dateFormat というプロパティにフォーマット文字列を指定して、string メソッドで文字列に変換します。
          let dateString: String = formatter.string(from: task.date)
//          (from: taskArray[indexPath.row].date)とも書ける。
          cell.detailTextLabel?.text = dateString
          
          return cell
      }
    
//    各セルを選択したときに呼ばれるメソッド セルタップしたときにタスク入力画面に遷移させる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
        
    }
    
//    セルが削除可能なことを伝えるメソッド　また、並び替えが可能かどうかなどの編集ができるかどうかを返すメソッド
//    taskappでは、削除可能であることを知らせるため、（削除を可能にするため）、 .delete を返す。
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return .delete
    }
//    deleteボタンが押されたときによびだされるメソッド　セルが削除されるときに呼ばれる　データベースからタスクを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete{
//            .deleteは上記の、セルが削除可能なことを伝えるメソッドのreturn.delete
//            削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
//            ローカル通知をキャンセルする//            通知センターのインスタンスを取得
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
//            データベースから削除する
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
//                削除する行を指定する NSIndexPath オブジェクトの配列を指定する。
                
            }
            
//            未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/-----------")
                    print(request)
                    print("-----------/")
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        taskSearchBar.endEditing(true)
        
        if taskSearchBar.text == ""{
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
           
            tableView.reloadData()
            return
        } else {

//
//        if taskSearchBar.text != ""{
//            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
//            for i in 0...taskArray.count - 1{
//                searchResult.append(taskArray[i].category)
//            }
//            for data in searchResult{
//                if data.contains(taskSearchBar.text!){
//              ここからどうすれば良いかわかりません。
//                }
//            }
//        }
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
//        データを取得する。
        let predict = NSPredicate(format: "category == %@", taskSearchBar.text!)
        taskArray = taskArray.filter(predict)
        print(taskArray)
        
        
//        引数リストの値をフォーマット文字列に代入し、その結果を解析することによって、述語を作成する。
//
//        述語フォーマット
//        新しい述語のためのフォーマット文字列。
//        args
//        predicateFormatに代入するための引数。
        
        print("searchButtonが押された")
        
        tableView.reloadData()
            
        }
    }
    
    @IBAction func displayAllOfTheListsButton(_ sender: Any) {
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }
}



