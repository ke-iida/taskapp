//
//  Task.swift
//  taskapp
//
//  Created by Keisuke Iida on 2022/02/27.
//

import RealmSwift

class Task: Object {
    //ID to manage. Primary key
    @objc dynamic var id = 0
    // title
    @objc dynamic var title = ""
    // contents
    @objc dynamic var contents = ""
    // date
    @objc dynamic var date = Date()
    // category
    @objc dynamic var category = ""
    //set id as promary key
    override static func primaryKey() -> String? {
        return "id"
    }
}
