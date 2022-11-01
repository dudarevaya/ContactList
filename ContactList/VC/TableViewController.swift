//
//  TableViewController.swift
//  M20
//
//  Created by Яна Дударева on 06.09.2022.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import CoreData

enum Keys {
    static let sorting = "sorting"
    static let strSorting = "strSorting"
}

class TableViewController: UIViewController {
    
    let defaults: UserDefaults = {
        let defaults = UserDefaults.standard
        return defaults
    }()
    
    private let persistantContainer = NSPersistentContainer(name: "M20")
    
    private lazy var fetchedResultsController: NSFetchedResultsController<InfoData> = {
        let fetchRequest = InfoData.fetchRequest()
        var sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sort = NSSortDescriptor(key: defaults.string(forKey: Keys.strSorting), ascending: defaults.bool(forKey: Keys.sorting))
        if defaults.string(forKey: Keys.strSorting) != nil {
            fetchRequest.sortDescriptors = [sort]
        } else {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    let cell = "Cell"
    
    let sortVariations: [String] = ["A-Z", "Z-A"]
    
    var info: InfoData?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(Cell.self, forCellReuseIdentifier: cell)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        fetchedResultsController.delegate = self
        
        persistantContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistant Store")
                print("\(error), \(error.localizedDescription)")
            } else {
                do {
                    try self.fetchedResultsController.performFetch()
                    self.tableView.reloadData()
                } catch {
                    print(error)
                }
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCell))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(goToSort))
        setupViews()
        setupConstraints()
    }
    
    // MARK: ViewModels
    
    @objc func addCell() {
        let vc = MakeViewController()
        vc.info = InfoData.init(entity: NSEntityDescription.entity(forEntityName: "InfoData", in: persistantContainer.viewContext)!, insertInto: persistantContainer.viewContext)
        navigationController?.pushViewController(vc, animated: true)
        tableView.reloadData()
    }
    
    func addEntity() {
        let vc = MakeViewController()
        vc.info = InfoData.init(entity: NSEntityDescription.entity(forEntityName: "InfoData", in: persistantContainer.viewContext)!, insertInto: persistantContainer.viewContext)
        tableView.reloadData()
    }
    
    @objc func goToSort() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Sort", preferredStyle: .actionSheet)
        let sortAction1 = UIAlertAction(title: "A-Z", style: .default) { [self] action in
            let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
            defaults.set(true, forKey: Keys.sorting)
            defaults.set("lastName", forKey: Keys.strSorting)
            self.fetchedResultsController.fetchRequest.sortDescriptors = [sortDescriptor]
            try? self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
        }
        let sortAction2 = UIAlertAction(title: "Z-A", style: .default) { [self] action in
            let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: false)
            defaults.set(false, forKey: Keys.sorting)
            defaults.set("lastName", forKey: Keys.strSorting)
            self.fetchedResultsController.fetchRequest.sortDescriptors = [sortDescriptor]
            try? self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        optionMenu.addAction(sortAction1)
        optionMenu.addAction(sortAction2)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

// MARK: TableViewDataSource

extension TableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell) as? Cell

//        let viewModel = info[indexPath.row]
//        cell?.textLabel?.text = viewModel.lastName + " " + viewModel.name
        let viewModel = fetchedResultsController.object(at: indexPath)
        cell?.textLabel?.text = (viewModel.lastName ?? "") + " " + (viewModel.name ?? "")
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let category = info[indexPath.row]
        let category = fetchedResultsController.object(at: indexPath)
        
        let vc = EditViewController(birth: category.birth ?? "", occupation: category.occupation ?? "", name: category.name ?? "", lastName: category.lastName ?? "", country: category.country ?? "")
        vc.title = (category.lastName ?? "") + " " + (category.name ?? "")
        vc.info = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let info = fetchedResultsController.object(at: indexPath)
            persistantContainer.viewContext.delete(info)
            try? persistantContainer.viewContext.save()
        }
    }
    
    
}
extension TableViewController: UITableViewDelegate {}

// MARK: FetchedResultsControllerDelegate

extension TableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            if let indexPath = indexPath {
                let info = fetchedResultsController.object(at: indexPath)
                let cell = tableView.cellForRow(at: indexPath)
                cell!.textLabel?.text = (info.lastName ?? "") + " " + (info.name ?? "")
            }
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        @unknown default:
            return
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
