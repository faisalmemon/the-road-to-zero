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
        MainViewControllerHelper
            .handleChangeBookRootDir(userLabel: bookRootDirTextField)
    }
    
    @IBAction func findTrademarksAction(_ sender: Any) {
        MainViewControllerHelper.handleFindTrademarks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainViewControllerHelper.setupBookRootDir(label: bookRootDirTextField)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
