//
//  Document.swift
//  BookBuilder
//
//  Created by Faisal Memon on 27/05/2021.
//

import Cocoa
import BuilderLibrary

class Document: NSDocument {

    var bookBuilderFile: BookBuilderFile
    
    override init() {
        bookBuilderFile = BookBuilderFile.fromBlank()
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        if let contentVC = windowController.contentViewController as? MainViewController {
            contentVC.representedObject = bookBuilderFile
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        if (typeName != Constants.bookBuilderDocumentType) {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        return try bookBuilderFile.toData()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        if (typeName != Constants.bookBuilderDocumentType) {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        do {
            bookBuilderFile = try BookBuilderFile.fromData(data)
        } catch {
            throw NSError(domain: Constants.bookBuilderErrorDomain, code: Constants.couldNotReadDataFile, userInfo: [NSLocalizedDescriptionKey: "Could not read the .bookbuilder file format"])
        }
    }

}

