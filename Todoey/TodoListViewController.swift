//
//  ViewController.swift
//  Todoey
//
//  Created by david ladowitz on 4/16/18.
//  Copyright © 2018 LittleCatLabs. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    let defaults = UserDefaults.standard

    let dataFilePath = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        loadItems()
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

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        tableView.deselectRow(at: indexPath, animated: true)
        saveItems()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert )

        let action = UIAlertAction(title: "Add Item", style: .default) { 
            (action) in

            print("Success: \(String(describing: textField.text))")
            self.itemArray.append(Item(title: textField.text!, done: false))

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
        let encoder = PropertyListEncoder()

        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }  catch {
            print("Error \(error)")
        }

        self.tableView.reloadData()
    }

    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()

            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("itemsArray: \(itemArray)")
            }

        }
    }
}

