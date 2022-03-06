//
//  ViewController.swift
//  taskapp
//
//  Created by Keisuke Iida on 2022/02/13.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UISearchBar!
    
    
    // get Realm instance
    let realm = try! Realm()
    //the list to import the task at DB
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        search.delegate = self
    }
    
    //return the number of data (= cell)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }

    //retun the contents of cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get the reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //set value on cell
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //the method conducted when select the cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil)
        }
    
    //the method inform cell is deletable
    func tableView(_ tableView: UITableView, editingStyleForRowAt IndexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //the method called when push the Delete button
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get delete task
            let task = self.taskArray[indexPath.row]
            
            //cancell local notification
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //delete it from database
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //output the un-notified local notification on log
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------")
                    print(request)
                    print("---------/")
                }
            }
        }
    }
    
    //called when move to next page by segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }
        else {
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
        
    }
    
    //update TableView when back from input view
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            //if empty in searchbox
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date", ascending: true)
            print("!!!!!!!!%@",taskArray)
            tableView.reloadData()
            return
        }
        if searchText == "" {
                    //if empty in searchbox
                    taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date", ascending: true)
                    print("!!!!!!!!%@",taskArray)
                    tableView.reloadData()
                    return
                }
        //if word in searchbox
        taskArray = try! Realm().objects(Task.self).filter(NSPredicate(format: "category == %@", searchText))
        print("searchText = %@", searchText)
        print("========%@",taskArray)
        tableView.reloadData()
        }
        
}


