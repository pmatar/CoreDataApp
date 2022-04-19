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
        fetchData()
    }
    
    deinit {
        print("No retain cycles")
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
            
            let taskToRemove = self.taskList.remove(at: indexPath.row)
            
            self.delete(taskToRemove, at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let selectedTask = taskList[indexPath.row]

        let action = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            self.showAlert(with: "Update Task", and: "What do you want to do?", selectedTask, indexPath)
            completion(true)
        }
        action.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTask = taskList[indexPath.row]
        
        showAlert(with: "Update Task", and: "What do you want to do?", selectedTask, indexPath)
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
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        do {
            taskList = try coreDataManager.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func save(_ taskName: String) {
        let task = Task(context: coreDataManager.persistentContainer.viewContext)
        task.title = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        coreDataManager.saveContext()
    }
    
    private func edit(_ task: Task, with text: String, at index: IndexPath) {
        task.title = text
        coreDataManager.saveContext()
        fetchData()
        tableView.reconfigureRows(at: [index])
    }
    
    private func delete(_ task: Task, at index: IndexPath) {
        coreDataManager.persistentContainer.viewContext.delete(task)
        coreDataManager.saveContext()
        tableView.deleteRows(at: [index], with: .automatic)
    }
    
    // MARK: - UIAlertController
    
    private func showAlert(with title: String, and message: String, _ task: Task? = nil, _ index: IndexPath? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let inputTask = alert.textFields?.first?.text, !inputTask.isEmpty else { return }
            
            if let task = task, let index = index {
                self.edit(task, with: inputTask, at: index)
            } else {
                self.save(inputTask)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
            textField.text = task?.title
        }
        present(alert, animated: true)
    }
}
