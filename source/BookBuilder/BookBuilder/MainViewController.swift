//
//  ViewController.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Cocoa
import BuilderLibrary

class MainViewControllerHelper {
    static func setupBookRootDir(label: NSTextField) {
        label.stringValue = "Book Root Dir = " + AppDefaults.getBookRootDir()
    }
}


class MainViewController: NSViewController {
    
    @IBOutlet weak var bookRootDirLabelOutlet: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainViewControllerHelper.setupBookRootDir(label: bookRootDirLabelOutlet)
        
        let config = Configuration.en
        BuilderLibrary.buildWithConfiguration(config)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

