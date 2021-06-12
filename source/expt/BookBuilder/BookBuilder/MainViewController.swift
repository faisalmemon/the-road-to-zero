//
//  ViewController.swift
//  BookBuilder
//
//  Created by Faisal Memon on 27/05/2021.
//

import Cocoa
import BuilderLibrary

class MainViewController: NSViewController {
    
    var service: BookBuilderService!
    
    @IBAction func findTrademarksAction(_ sender: Any) {
        switch service.updateTrademarkMarkdown() {
        case .TrademarkFileSystemFailure:
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.informativeText = "Trademarks file updated."
            alert.beginSheetModal(for: self.view.window!) { (response) in
                //ignore
            }
        case .TrademarkFileUpdated:
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.informativeText = "Trademarks file updated."
            alert.beginSheetModal(for: self.view.window!) { (response) in
                //ignore
            }
        case .TrademarkNotYetIndexed:
            let alert = NSAlert()
            alert.informativeText = "Cannot build trademarks file, index file is missing.  Build the book, then re-try."
            alert.alertStyle = .warning
            alert.beginSheetModal(for: self.view.window!) { (response) in
                //ignore
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
            if let bookBuilderFile = self.representedObject as? BookBuilderFile {
                service = BuilderLibrary(clientLog: AppDelegate.log, configuration: bookBuilderFile)
            }
        }
    }

}

