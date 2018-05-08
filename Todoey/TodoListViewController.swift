//
//  ViewController.swift
//  Todoey
//
//  Created by david ladowitz on 4/16/18.
//  Copyright © 2018 LittleCatLabs. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }


    let defaults = UserDefaults.standard

    let dataFilePath = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    // 1. Get Application Singleton
    // 2. get appDelegate on singleton
    // 3. get the persistentContainer and it's viewContext
    let context = (UIApplication.shared.delegate as!  AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // Create cells on screen
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        let item = itemArray[indexPath.row]

        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Clicked on: \(itemArray[indexPath.row])")

//      Toggles on/off checkmark
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

//      Deletes item from array and CoreData database
//      context.delete(itemArray[indexPath.row])
//      itemArray.remove(at: indexPath.row)

        tableView.deselectRow(at: indexPath, animated: true)
        saveItems()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert )

        let action = UIAlertAction(title: "Add Item", style: .default) { 
            (action) in

            // Creates a new item using the CoreDate Item model
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory

            self.itemArray.append(newItem)

            print("Success: \(String(describing: textField.text))")
            self.saveItems()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func saveItems() { 
        do {
            try context.save()
        }  catch {
            print("Error: \(error)")
        }

        self.tableView.reloadData()
    }

    // 'with' is the param name used when calling externally
    // 'request' is the param name used when running internally
    // '=' creates a defualt Item.fetchRequest() unless one is given
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error: \(error)")
        }

        tableView.reloadData()
    }

}


// MARK: Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search: \(searchBar.text!)")

        let request: NSFetchRequest<Item> = Item.fetchRequest()

        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
