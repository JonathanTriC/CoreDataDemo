//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by JonathanTriC on 16/05/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items:[Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchPeople()
    }

    func fetchPeople() {
        do {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            // Filter
            // let pred = NSPredicate(format: "name CONTAINS %@", "Ted")
            // request.predicate = pred
            
            // Sort
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            
        }
    }
    
    func relationship() {
        let family = Family(context: context)
        family.name = "Joe Family"
        
        let person = Person(context: context)
        person.name = "Maggie"

        family.addToPeople(person)
        
        do {
            try self.context.save()
        } catch {
            
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Person",
                                      message: "What is their name?",
                                      preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { action in
            let textfield = alert.textFields![0]
            
            let newPerson = Person(context: self.context)
            newPerson.name = textfield.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchPeople()
        }
        
        alert.addAction(submitButton)
        self.present(alert, animated: true)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell",
                                                 for: indexPath)
        
        let person = self.items![indexPath.row]
        cell.textLabel?.text = person.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.items![indexPath.row]
        
        let alert = UIAlertController(title: "Edit Person",
                                      message: "Edit name:",
                                      preferredStyle: .alert)
        alert.addTextField()
        
        let textfield = alert.textFields![0]
        textfield.text = person.name
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { action in
            let textfield = alert.textFields![0]
            
            person.name = textfield.text
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchPeople()
        }
        
        alert.addAction(saveButton)
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            
            let personToRemove = self.items![indexPath.row]
            self.context.delete(personToRemove)
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchPeople()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}


