//
//  ViewController.swift
//  BookBuilder
//
//  Created by Faisal Memon on 14/05/2021.
//

import Cocoa
import BuilderLibrary


class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let config = Configuration.en
        BuilderLibrary.buildWithConfiguration(config)
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

