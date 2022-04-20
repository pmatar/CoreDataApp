//
//  TaskListViewController.swift
//  CoreData
//
//  Created by Paul Matar on 18/04/2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let coreDataManager = StorageManager.shared
    private var taskList: [Task] = []
    private let cellID = "task"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetch()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_, completion in
            guard let self = self else { return }
            
            self.delete(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            self.showAlert(with: "Update Task", and: "What do you want to do?", indexPath)
            completion(true)
        }
        action.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showAlert(with: "Update Task", and: "What do you want to do?", indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Private Methods

extension TaskListViewController {
    
    @objc private func addButtonTapped() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 194/255)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func fetch() {
        coreDataManager.fetchContext(&taskList)
    }
    
    private func save(_ taskName: String) {
        let task = coreDataManager.createTask()
        task.title = taskName
        taskList.append(task)
        coreDataManager.saveContext()
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func edit(with text: String, at index: IndexPath) {
        let task = taskList[index.row]
        task.title = text
        coreDataManager.saveContext()
        tableView.reconfigureRows(at: [index])
    }
    
    private func delete(at index: IndexPath) {
        let taskToRemove = taskList.remove(at: index.row)
        coreDataManager.deleteTask(taskToRemove)
        coreDataManager.saveContext()
        tableView.deleteRows(at: [index], with: .automatic)
    }
    
    // MARK: - UIAlertController
    
    private func showAlert(with title: String, and message: String, _ index: IndexPath? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let inputTask = alert.textFields?.first?.text, !inputTask.isEmpty else { return }
            
            if let index = index {
                self.edit(with: inputTask, at: index)
            } else {
                self.save(inputTask)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
            if let index = index {
                textField.text = self.taskList[index.row].title
            }
        }
        present(alert, animated: true)
    }
}
