//
//  ViewController.swift
//  MacMarkov
//
//  Created by Adam Boyd on 2016-03-05.
//  Copyright © 2016 Adam. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

//    let markov = MarkovGenerator(fileName: "shakespeare")
    let markov = MarkovGenerator(fileName: "testshakespeare")
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var generateButton: NSButton!
    @IBOutlet weak var resultLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(markov.generateSentence("his"))

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBAction func generateAction(sender: AnyObject) {
        self.resultLabel.stringValue = self.markov.generateSentence(self.textField.stringValue)
    }
}

