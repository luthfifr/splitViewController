//
//  MasterViewController.swift
//  splitViewController
//
//  Created by Luthfi Fathur Rahman on 6/12/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var dates = [String]()
    var buatCatatan = UIAlertAction()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Catatan Keren"
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
                self.objects.insert(textfield.text!, at: 0)
                self.dates.insert("\(currentYear)/\(currentMonth)/\(currentDate) \(currentHour):\(currentMinutes):\(currentSeconds)", at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
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
                let object = objects[indexPath.row] as! String
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.masterRow = "baris\(indexPath.row)"
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

        let object = objects[indexPath.row] as! String
        cell.textLabel!.text = object.description
        cell.detailTextLabel?.text = dates[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

