//
//  ViewController.swift
//  DoIt
//
//  Created by iem on 30/03/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let dataManager: DataManager = DataManager<Tache>()
    var category : Categorie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        dataManager.loadData(filter: category.nom!)
    }
    
    //MARK: Actions
    @IBAction func editAction(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        
        let buttonType: UIBarButtonSystemItem = tableView.isEditing ? .done : .edit
        let rightButton = UIBarButtonItem(barButtonSystemItem: buttonType, target: self, action: #selector(editAction(_:)))
        var rightButons = navigationItem.rightBarButtonItems
        rightButons![1] = rightButton
        navigationItem.setRightBarButtonItems(rightButons, animated: true)
    }
    
    //MARK: User Experience
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
    }
}

extension ListViewController:  UITableViewDataSource, UITableViewDelegate {
   
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.getItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCellIdentifier") as! ListTableViewCell
        let item = dataManager.getItem(index: indexPath.row)
        cell.labelName?.text = item.nom
        cell.labelCheckmark.isHidden = item.checked ? false : true
        if let tag = item.tag {
            cell.backgroundColor = tag.couleur as? UIColor
        } else {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        dataManager.moveItem(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.dataManager.getItem(index: indexPath.row)
        dataManager.toggleCheckItem(item: item)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = self.dataManager.getItem(index: indexPath.row)
        dataManager.removeItem(item: item)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            let navigationController = segue.destination as? UINavigationController,
            let destination = navigationController.topViewController as? AddItemViewController {
            
            if identifier == "addItem" {
                destination.delegate = self
                destination.context = self.dataManager.persistentContainer.viewContext
                destination.state = ViewState.isAdd
            } else if identifier == "editItem" {
                let cell = sender as! UITableViewCell
                destination.delegate = self
                destination.state = ViewState.isEdit
                destination.tacheToEdit = dataManager.getItem(index:(tableView.indexPath(for: cell)?.row)!) 
            }
        }
    }
}

extension ListViewController {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataManager.filterItems(filter: searchText)
        tableView.reloadData()
    }
}

extension ListViewController : AddItemViewControllerDelegate{
    func addItem(_ controller: AddItemViewController, didFinishAddingItem item: Tache) {
        controller.dismiss(animated: true)
        self.dataManager.addItem(item: item)
        self.dataManager.loadData(filter: category.nom!)
        tableView.reloadData()
    }
    
    
    func addItem(_ controller: AddItemViewController, didFinishEditingItem tache: Tache) {
        controller.dismiss(animated: true)
        let index = IndexPath(item : dataManager.cachedItems.index(where:{ $0 === tache })!, section : 0)
        tableView.reloadRows(at: [index] , with: UITableViewRowAnimation.none)
        tableView.reloadData()
    }
    
    
    func AddItemViewControllerDidCancel(_ controller: AddItemViewController) {
        controller.dismiss(animated: true)
    }
    
}
