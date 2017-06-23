//
//  MasterViewController.swift
//  splitViewController
//
//  Created by Luthfi Fathur Rahman on 6/12/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [NSManagedObject]()
    var dates = [NSManagedObject]()
    var buatCatatan = UIAlertAction()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Catatan Keren"
        
        self.tableView.tableFooterView = UIView()
        
        navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        //fetch from core data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject> (entityName: "Notes")
        
        do {
            objects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch from Core Data. \(error), \(error.userInfo)")
        }
        
        printCoreData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        let alertJudul = UIAlertController (title: "Masukkan Judul Catatan", message: "Masukkan judul catatan untuk mempermudah pengorganisasian catatan.", preferredStyle: UIAlertControllerStyle.alert)
        alertJudul.addTextField(configurationHandler: { textfield in
            textfield.placeholder = "Judul catatan"
            NotificationCenter.default.addObserver(self, selector: #selector(self.alertTextFieldHasChanged), name: NSNotification.Name.UITextFieldTextDidChange, object: textfield)
        })
        self.buatCatatan = UIAlertAction(title: "Buat Catatan", style: UIAlertActionStyle.default,handler: { (action) in
            let textfield: UITextField = (alertJudul.textFields?.first!)!
            let date = Date()
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: date)
            let currentMinutes = calendar.component(.minute, from: date)
            let currentSeconds = calendar.component(.second, from: date)
            let currentDate = calendar.component(.day, from: date)
            let currentMonth = calendar.component(.month, from: date)
            let currentYear = calendar.component(.year, from: date)
            
            if !(textfield.text?.isEmpty)! {
                self.saveTitle(title: textfield.text!, date: "\(currentYear)/\(currentMonth)/\(currentDate) \(currentHour):\(currentMinutes):\(currentSeconds)")
                self.tableView.reloadData()
            }
        })
        self.buatCatatan.isEnabled = false
        alertJudul.addAction(buatCatatan)
        alertJudul.addAction(UIAlertAction(title: "Batalkan", style: UIAlertActionStyle.destructive,handler:nil))
        self.present(alertJudul, animated: true, completion: nil)
    }
    
    func alertTextFieldHasChanged(notification: Notification){
        let textfield = notification.object as! UITextField
        self.buatCatatan.isEnabled = !(textfield.text?.isEmpty)!
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] 
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //assign core data entity values to UITableView textLabel(s)
        if indexPath.row < objects.count {
            if let object = objects as? [Notes] {
                if object[indexPath.row].title != nil && object[indexPath.row].date != nil {
                    cell.textLabel!.text = object[indexPath.row].title!
                    cell.detailTextLabel?.text = object[indexPath.row].date!
                } else {
                    cell.textLabel!.text = object[indexPath.row].title
                    cell.detailTextLabel?.text = object[indexPath.row].date
                }
                
            }
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //delete a core data object
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject> (entityName: "Notes")
            
            do {
                let object = try managedContext.fetch(fetchRequest)
                managedContext.delete(object[indexPath.row])
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete from Core Data. \(error), \(error.userInfo)")
            }
            
            do {
                objects.removeAll()
                objects = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch from Core Data. \(error), \(error.userInfo)")
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
        
        self.tableView.reloadData()
    }
    
    //save to core data
    func saveTitle(title: String, date: String) {
        
        let content = " "
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Notes", in: managedContext)!
        
        let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        managedObject.setValue(title, forKeyPath: "title")
        managedObject.setValue(date, forKeyPath: "date")
        managedObject.setValue(content, forKeyPath: "content")
        
        do {
            try managedContext.save()
            objects.append(managedObject)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        printCoreData()
    }
    
    //print core data entities
    func printCoreData() {
        for object in objects as! [Notes] {
            print("\(object.title as Any), \(object.date as Any), \(object.content as Any)")
        }
    }

}

