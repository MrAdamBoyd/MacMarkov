//
//  ViewController.swift
//  MacMarkov
//
//  Created by Adam Boyd on 2016-03-05.
//  Copyright © 2016 Adam. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, MarkovGeneratorDelegate, NSTextFieldDelegate {

    var markov: MarkovGenerator!
    
    @IBOutlet weak var addTextButton: NSButton!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var generateButton: NSButton!
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressTextfield: NSTextField!
    @IBOutlet weak var progressView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinner.isHidden = true
        self.progressView.isHidden = true
        self.progressIndicator.doubleValue = 0
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = 100
        self.textField.delegate = self
        self.textField.isEnabled = false
        self.generateButton.isEnabled = false
        self.resultLabel.isEnabled = false
        
        //Setting up the markov generator
        self.markov = MarkovGenerator()
        self.markov.delegate = self
    }

    /**
     User hit the generate button, use the markov generator to make a sentence and then set the text
     
     - parameter sender: generate button
     */
    @IBAction func generateAction(_ sender: AnyObject) {
        self.resultLabel.stringValue = self.markov.generateSentence(withSeedString: self.textField.stringValue)
    }
    
    @IBAction func addTextAction(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["txt"]
        openPanel.title = "Choose a file"
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton)
            {
                if let fileURL = openPanel.url {
                    self.progressView.isHidden = false
                    self.spinner.isHidden = false
                    self.spinner.startAnimation(self)
                    self.generateButton.isEnabled = false
                    self.addTextButton.isEnabled = false
            
                    //Start markov
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.markov.addFileToGenerator(fileURL.path)
                    }
                }
            }
        })
    }
    
    //MARK: - MarkovGeneratorDelegate
    
    func updateProgress(_ progress: CGFloat) {
        DispatchQueue.main.async {
            self.progressTextfield.stringValue = String(format: "%.2f%", progress * 100) + "%"
            let difference = (Double(progress) * 100) - self.progressIndicator.doubleValue
            self.progressIndicator.increment(by: difference)
        }
    }
    
    func finishedFile() {
        DispatchQueue.main.async {
            //When done loading, stop the spinner
            self.spinner.stopAnimation(self)
            self.spinner.isHidden = true
            self.progressView.isHidden = true
            self.addTextButton.isEnabled = true
            self.textField.isEnabled = true
            self.generateButton.isEnabled = true
            self.resultLabel.isEnabled = true
        }
    }
    
    //MARK: - NSTextFieldDelegate
    override func controlTextDidEndEditing(_ obj: Notification) {
        self.generateAction(self.generateButton)
    }
}

