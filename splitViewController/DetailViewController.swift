//
//  DetailViewController.swift
//  splitViewController
//
//  Created by Luthfi Fathur Rahman on 6/12/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var objects = [NSManagedObject]()
    var indexObject: Int?
    var detailItem: NSManagedObject?
    let userDefault = UserDefaults.standard

    /*func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = (detailItem?.value(forKeyPath: "title"))! as? String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        textView.text = (detailItem?.value(forKeyPath: "content"))! as! String
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        saveContent(content: textView.text!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //update core data entity's value
    func saveContent(content: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject> (entityName: "Notes")
        
        do {
            let object = try managedContext.fetch(fetchRequest)
            let managedObject = object[indexObject!] as NSManagedObject
            managedObject.setValue(content, forKeyPath: "content")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update attribute. \(error), \(error.userInfo)")
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

