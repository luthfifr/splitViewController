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
        
        self.title = ((detailItem?.value(forKeyPath: "title"))! as! String)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let item = detailItem as? [Notes] {
            textView.text = item[item.count-1].content!
        }
        
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
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        //userDefault.set(textView.text, forKey: masterRow!)
        //userDefault.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

