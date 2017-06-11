//
//  DetailViewController.swift
//  splitViewController
//
//  Created by Luthfi Fathur Rahman on 6/12/17.
//  Copyright © 2017 Luthfi Fathur Rahman. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var masterRow: String?
    var detailItem: String?
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
        
        self.title = detailItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if (masterRow) != nil {
            if userDefault.object(forKey: masterRow!) != nil {
                textView.text = userDefault.string(forKey: masterRow!)
            } else {
                textView.text = ""
            }
        } else {
            textView.text = ""
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        userDefault.set(textView.text, forKey: masterRow!)
        userDefault.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

