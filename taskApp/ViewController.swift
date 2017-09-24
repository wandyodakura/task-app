//
//  ViewController.swift
//  taskApp
//
//  Created by 小田倉真弘 on 2017/09/09.
//  Copyright © 2017年 masahiro.odakura. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

@available(iOS 10.0, *)
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    

    
    let realm=try! Realm()
    
    var taskArray=try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate=self
        tableView.dataSource=self
        searchBar.delegate=self
            }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      print("\(String(describing: searchBar.text))")
        
      taskArray=realm.objects(Task.self).filter("category = '\(searchBar.text!)'")
        tableView.reloadData()
       searchBar.showsCancelButton = true
    }
    
   
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        taskArray=try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        searchBar.text=""
        tableView.reloadData()
        
    }
    

    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - segue: <#segue description#>
    ///   - sender: <#sender description#>
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath as IndexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
       
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexpath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)->UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    func tableView(_ tableView: UITableView,commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            
    
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
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
}

