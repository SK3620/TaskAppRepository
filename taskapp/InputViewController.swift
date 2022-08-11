//
//  InputViewController.swift
//  taskapp
//
//  Created by 鈴木健太 on 2022/07/28.
//

import UIKit
import RealmSwift
import UserNotifications


class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextView: UITextField!
    
    
    var task: Task!
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.]
//        背景をタップしたらdismissKetBoradを呼ぶ
//        UITapGestrueReconazerでタップを判断する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
//        viewプロぱが背景に該当するため、viewにUItapGestureReconizerを登録
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryTextView.text = task.category
//        上記のtaskは var task = taskArray[indexPath.row]　要は、データベースのこと。
//       datePickerのdateは、 The date displayed by the date picker.を指す。
        
    }
    
    @objc func dismissKeyboard(){
//        キーボードを閉じる
        view.endEditing(true)
    }
    
//    画面が遷移するときに呼ばれる（画面が非表示になるとき）
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextView.text!
            self.realm.add(self.task, update: .modified)
//                .modifiedは、登録するデータのPK(主キー）が被った場合Update（更新）するという処理になります。
//    PKが被っていなかった場合は、新規でデータが登録されます。
            
        }
        
        super.viewWillDisappear(animated)

        func setNotification(task: Task){
//            UNMutableNotificationContentインスタンスを使って通知内容設定
            let content = UNMutableNotificationContent()
//             タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
//            contentのtitleとbodyはUNMutableNotificationContent()内に定意されてるプロぱ
//            titleは 通知のタイトル　bodyは 通知の本文
            if task.title == ""{
                content.title = "(タイトルなし)"
            } else {
                content.title = task.title
            }
            
            if task.contents == ""{
                content.body = "(内容なし)"
            } else {
                content.body = task.contents
            }
//             The sound that will be played for the notification.
            content.sound = UNNotificationSound.default
            
//            ローカル通知が発動するtrigger（日付マッチ）を作成
            let calendar = Calendar.current
//            current　ユーザーの現在のカレンダー
            let dateComponets = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
//            task.date に入っているDate型の日時情報から、年(.year)、月(.month)、日(.day)、分(.minute)の情報を取り出して作成しています。これにより、指定年、指定月、指定日、指定時、指定分に通知　　dateComponentsメソッドで、生成する日時の要素を指定　列挙隊
            
//            Date()インスタンスは、Dateインスタンスが生成した時の時刻が基準日時から経過秒として入る
            
//            A trigger condition that causes a notification the system delivers at a specific date and time.ここにdateComponentsを指定。
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponets, repeats: false)
          
            // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
            let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
            
//            ローカル通知を登録
            let center = UNUserNotificationCenter.current()
//            通知センターのインスタンスを取得するメソッド current()
            center.add(request, withCompletionHandler: {error in print( error ?? "ローカル登録通知　OK")})
//            add(request){error in print(~~~~)でも良い。
//            errorには成功した場合のnilか登録失敗の理由が入る
                
                
//            func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil)
//            add(request, withCompletionHandler: { (error) in print ()})
            
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                       for request in requests {
                           print("/---------------")
                           print(request)
                           print("---------------/")
                       }
            }
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


//            var user = [() -> String]()
//
//            func addUser (user1 : @escaping () -> String)  {
//                      user.append(user1) }
//            外部の変数Userに、関数の引数のクロージャーを格納//クロージャーを外部の変数に格納するような場面で使います。


//func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil)　の最後の部分は、例えば、
//let pass: (Int, Int) -> Int　みたいな形と同じ　引数二つ
//completionHandler: (Error?) -> Void)?　引数はオプショナルError型の引数が一つ






//Dateは現在の日付を取得することができる構造体
//日付を取得する以外にも日付同士を比較したり、日付間の時間間隔の計算、新しい日付の作成などができます。
//let date:Date = Date()
//print(date)
//実行結果：
//2017-10-25 05:29:30 +0000


//let calendar = Calendar.current
//let date = Date()
////それぞれのスマホに設定されている暦（ぐれごれ暦とか和暦とか中国の暦とかなど）を取得。
//// 明日の日付を取得
//let day_tomorrow = calendar.date(
//    byAdding: .day, value: 1, to: calendar.startOfDay(for: date))
//// 昨日の日付を取得
//let day_yesterday = calendar.date(
//    byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
//valueの値を1（明日）、-1（昨日）を指定して日付を取得


////現在の日付を取得
//let date:Date = Date()
////日付のフォーマットを指定する。
//let format = DateFormatter()
//format.dateFormat = "yyyy/MM/dd HH:mm:ss"
////日付をStringに変換する
//let sDate = format.string(from: date)
////from: date　は、 formatする現在の日付であるdateを入れる。




