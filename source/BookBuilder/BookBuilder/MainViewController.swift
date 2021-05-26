//
//  ViewController.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Cocoa
import BuilderLibrary

typealias Helper = MainViewControllerHelper

class MainViewController: NSViewController {
    
    @IBOutlet weak var bookRootDirTextField: NSTextField!
    
    @IBAction func changeBookRootDirAction(_ sender: Any) {
        Helper.handleChangeBookRootDir(userLabel: bookRootDirTextField)
    }
    
    
    
    @IBAction func findTrademarksAction(_ sender: Any) {
        Helper.handleFindTrademarks()
    }
    
    @IBOutlet weak var consoleScrollView: NSScrollView!
    
    @IBOutlet var consoleTextView: NSTextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.setupBookRootDir(label: bookRootDirTextField)
        Helper.setupConsole(textView: consoleTextView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

