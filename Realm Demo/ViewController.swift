//
//  ViewController.swift
//  Realm Demo
//
//  Created by ahmed on 6/25/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    fileprivate let cellIdentifier = "cellPerson"

    @IBOutlet var tableView: UITableView!
    
    var persons : Results<Person>!
    var notifier : NotificationToken!
    
    deinit {
        notifier.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        createNewPerson()
        loadDataFromRealmDB()
        
        //deleteFromRealm()
        //updateRealmObject()
        //readFromRealm()
    }
    
    private func loadDataFromRealmDB() {
        let realm = try! Realm()
        self.persons = realm.objects(Person.self)
        
        self.notifier = self.persons.addNotificationBlock{ (results) in
            switch results {
            case .error(let error):
                print(error)
                
            case .initial(_):
                self.tableView.reloadData()
                
            case .update(_, deletions: _, insertions: _, modifications: _):
                self.tableView.reloadData()
            }
        }
    }
//    
//    func updateRealmObject() {
//        let realm = try! Realm()
//        try! realm.write {
//            let ahmed = realm.objects(Person.self).filter("name == 'ahmed'").first
//            ahmed?.age = 55
//            print("Update successed")
//        }
//    }
//    
//    func deleteFromRealm () {
//        let realm = try! Realm()
//        try! realm.write {
//            //realm.deleteAll()
//            let amrs = realm.objects(Person.self).filter("name == 'amr'")
//            realm.delete(amrs)
//            print("deletion successed")
//        }
//    }
//    func readFromRealm() {
//        let realm = try! Realm()
//        let pesrons = realm.objects(Person.self)
//        for p in pesrons {
//            print(p.name, p.age)
//        }
//        print("read successed")
//    }
//    
    func createNewPerson() {
        let person1 = Person()
        person1.name = "ahmed"
        person1.age = 25
        
        let person2 = Person()
        person2.name = "amr"
        person2.age = 16
        
        let person3 = Person()
        person3.name = "hasan"
        person3.age = 35
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(person1)
            realm.add(person2)
            realm.add(person3)
        }
    }
    
    @IBAction func deletionBtn(_ sender: UIButton) {
        
        let realm = try! Realm()
        try! realm.write {
            if let person = realm.objects(Person.self).first {
                realm.delete(person)
                print("deletion successed")
            }
        }
    }
    
    @IBAction func addPerson_btn(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Person", message: "Eneter name and age", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: {
            $0.placeholder = "name"
            $0.textAlignment = .center
        })
        
        alert.addTextField(configurationHandler: {
            $0.placeholder = "age"
            $0.textAlignment = .center
            $0.keyboardType = .numberPad
        })
        
        alert.addAction(UIAlertAction(title: "ADD", style: .destructive, handler: { (action: UIAlertAction)in
            guard let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces), !name.isEmpty , let age = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces), !age.isEmpty else{return}
            
            let newPerson = Person()
            newPerson.name = name
            newPerson.age = Int(age) ?? 0
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(newPerson)
            }
        }))
    
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.persons.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.textLabel?.text = self.persons[indexPath.row].name
            cell.textLabel?.textAlignment = .center
            cell.detailTextLabel?.text = String(self.persons[indexPath.row].age)
            cell.detailTextLabel?.textAlignment = .center
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        return cell
    }
}
extension ViewController : UITableViewDelegate {
    
//    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let person = self.persons[indexPath.row]
//            let realm = try! Realm()
//            try! realm.write {
//                realm.delete(person)
//            }
//        }
//    }
    //anothe method to delete and edit row in tableView
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let person = self.persons[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete"){(action: UITableViewRowAction, indexPath: IndexPath) in
            
            self.handleDelete(person: person, indexPath: indexPath)
        }
        
        let updateAction = UITableViewRowAction(style: .default, title: "Update"){(action: UITableViewRowAction, indexPath: IndexPath) in
            
            self.handleUpdate(person: person, indexPath: indexPath)
        }
        updateAction.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        return [deleteAction,updateAction]
    }
    
    private func handleDelete(person: Person, indexPath: IndexPath) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(person)
        }
        //it is what used to delete specific Rows without reload all data
//        self.tableView.beginUpdates()
//        self.tableView.deleteRows(at: [indexPath], with: .automatic)
//        self.tableView.endUpdates()
    }
    
    private func handleUpdate(person: Person, indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Edit Person", message: "Are you want edit really?" , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: {
            $0.text = person.name
        })
        alert.addAction(UIAlertAction(title: "Edit", style: .destructive, handler: {(action: UIAlertAction) in
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else{ return }
            let realm = try! Realm()
            try! realm.write {
                let ps = realm.objects(Person.self).filter("name == '\(person.name)'")
                for p in ps {
                    p.name = name
                }
                print("Update successed")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}









