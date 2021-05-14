//
//  ViewController.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Cocoa
import BuilderLibrary





class MainViewController: NSViewController {
    
    @IBOutlet weak var bookRootDirTextField: NSTextField!
    
    @IBAction func changeBookRootDirAction(_ sender: Any) {
        PickBookRootDir.invoke { (path) in
            MainViewControllerHelper
                .handleRevisedBookRootDir(
                    path: path,
                    userLabel: bookRootDirTextField
                )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainViewControllerHelper.setupBookRootDir(label: bookRootDirTextField)
        
        let config = Configuration.en
        BuilderLibrary.buildWithConfiguration(config)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

