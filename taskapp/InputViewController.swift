//
//  InputViewController.swift
//  taskapp
//
//  Created by Keisuke Iida on 2022/02/13.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    //@IBOutlet weak var categoryPikcer: UIPickerView! //Picker UI for Category
    @IBOutlet weak var categoryField: UITextField!
    
    var task: Task!
    let realm = try! Realm()
    let categoryList = ["No Action","In Action","Done","Completed"]
    var items = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // set to call dismissKeyboard method when tap the background
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryField.text = task.category
        
        //add for category
        //categoryPikcer.delegate = self
        //categoryPikcer.dataSource = self
    }
    
    @objc func dismissKeyboard(){
        //close keyboard
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryField.text!
            self.realm.add(self.task, update: .modified)
            //print("^^^^^^^^^^^^%@",items)
        }
        
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    //register local notification of task
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        //set title and contents
        if task.title == "" {
            content.title = "(No Title)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(No Contents)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        //Create trigger of popup Notification with matching the date
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //create local notification from identifier, content, trigger
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //register local Notification
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "Success to register local Notification!")
        }
        
        // output un-notified local notification on log
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/----------")
                print(request)
                print("----------/")
            }
        }
        
    }

    //add Category
    //func numberOfComponents(in pickerView: UIPickerView) -> Int {
    //  return 1
    //}

    //func pickerView(_ pickerView:UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    //    return categoryList.count
    //}
    //func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //   return categoryList[row]
    //}
    //func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    //    items = categoryList[row]
    //    //try! realm.write {
    //        //self.task.category = categoryList[row]
    //    //}
    //    print("------------%@", categoryList[row])
    //}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
