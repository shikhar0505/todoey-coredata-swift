//
//  ViewController.swift
//  Todoey-CoreData
//
//  Created by Shikhar Kumar on 2/12/20.
//  Copyright © 2020 Shikhar Kumar. All rights reserved.
//

import UIKit
import CoreData

class TodoTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todoItems = [TodoItem]()
    var parentCategory: Category?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = parentCategory?.title
        searchBar.delegate = self
        loadItems()
    }
    
    // MARK: - Add new todo item

    @IBAction func addNewItemButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if textField.text != "" {
                
                let newItem = TodoItem(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.parentCategory
                
                self.todoItems.append(newItem)
                self.saveItem()
            }
        }
        alert.addTextField { (field) in
            field.placeholder = "Add a new todo item"
            textField = field
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = todoItems[indexPath.row].title
        cell.accessoryType = todoItems[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        tableView.reloadData()
    }
    
    // MARK: - Data Model Manipulation
    
    func loadItems(for request : NSFetchRequest<TodoItem> = TodoItem.fetchRequest()) {
        request.predicate = NSPredicate(format: "%K == %@", "parentCategory", parentCategory!)
        do {
            todoItems = try context.fetch(request)
        } catch {
            print("Error fetching todo items \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving todo items \(error)")
        }
        tableView.reloadData()
    }
    
}

// MARK: - Search Bar

extension TodoTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", "parentCategory", parentCategory!),
            NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        ])
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            todoItems = try context.fetch(request)
        } catch {
            print("Error fetching todo items \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            self.tableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
