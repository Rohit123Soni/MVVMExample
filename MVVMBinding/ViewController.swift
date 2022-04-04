//
//  ViewController.swift
//  MVVMBinding
//
//  Created by MacBook on 04/04/2022.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // Instance
    var viewModel = UserListViewModel()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        
        viewModel.users.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        fetchData()
    }
    
    // MARK: - NumbersOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }
    
    
    // MARK: - trailingSwipeActionsConfigurationForRowAt
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let updateAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            debugPrint("Update Tapped")
            
            let alert = UIAlertController(title: "Update", message: nil, preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.text = self.viewModel.users.value?[indexPath.row].name
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                
                self.viewModel.users.value?[indexPath.row].name = textField?.text ?? "N/A"
                
            }))
            self.present(alert, animated: true, completion: nil)
            success(true)
        })
        
        let deleteAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            debugPrint("Delete tapped")
            self.viewModel.users.value?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            success(true)
        })
        
        updateAction.image = UIImage(systemName: "square.and.arrow.up")
        updateAction.backgroundColor = UIColor.gray
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor.red
        
        return UISwipeActionsConfiguration(actions: [deleteAction,updateAction])
    }
    
    
    // MARK: - fetchData()
    func fetchData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            
            do {
                let userModel = try JSONDecoder().decode([User].self, from: data)
                
                self.viewModel.users.value = userModel.compactMap({
                    UserTableViewCellViewModel(name: $0.name)
                })
            } catch {
                
            }
        }
        task.resume()
    }
    
}

