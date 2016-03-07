//
//  ViewController.swift
//  MacMarkov
//
//  Created by Adam Boyd on 2016-03-05.
//  Copyright © 2016 Adam. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var markov: MarkovGenerator!
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var generateButton: NSButton!
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinner.startAnimation(self)
        self.textField.enabled = false
        self.generateButton.enabled = false
        self.resultLabel.enabled = false
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.markov = MarkovGenerator(fileName: "someshakespeare")
            
            dispatch_async(dispatch_get_main_queue()) {
                //When done loading, stop the spinner
                self.spinner.stopAnimation(self)
                self.spinner.hidden = true
                self.textField.enabled = true
                self.generateButton.enabled = true
                self.resultLabel.enabled = true
            }
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    /**
     User hit the generate button, use the markov generator to make a sentence and then set the text
     
     - parameter sender: generate button
     */
    @IBAction func generateAction(sender: AnyObject) {
        self.resultLabel.stringValue = self.markov.generateSentence(self.textField.stringValue)
    }
}

