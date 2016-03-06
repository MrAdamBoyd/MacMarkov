//
//  MarkovGenerator.swift
//  MarkovGenerator
//
//  Created by Adam Boyd on 2016-03-05.
//  Copyright © 2016 Adam. All rights reserved.
//

import Foundation

class MarkovGenerator {
    
    private let sentences: [[String]]
    private var transitionTable: [String : [String]] = [:]
    
    var minSentenceLength = 3
    var maxSentenceLength = 20
    
    init(sentences: [[String]]) {
        self.sentences = sentences
        
        self.buildTransitionTable()
    }
    
    /**
     Initialize with one filename
     
     - parameter fileName: single file to generate markov chains with
     
     - returns: self
     */
    convenience init(fileName: String) {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt")!
        
        let separatedText = (try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n.")).map { $0.lowercaseString }
        //There has to be a better way of doing this, will fix later
        let cleanText1 = separatedText.map({ $0.stringByReplacingOccurrencesOfString(";", withString: "") })
        let cleanText2 = cleanText1.map({ $0.stringByReplacingOccurrencesOfString(":", withString: "") })
        let cleanText3 = cleanText2.map({ $0.stringByReplacingOccurrencesOfString(",", withString: "") })
        let cleanText4 = cleanText3.map({ $0.stringByReplacingOccurrencesOfString("?", withString: "") })
        let cleanText5 = cleanText4.map({ $0.stringByReplacingOccurrencesOfString("!", withString: "") })
        
        let sentenceArray = cleanText5.map({ $0.componentsSeparatedByString(" ") })
        
        //At this point, we have an array of an array of string. Each outer array is a sentence and contains an inner array of words in each sentence
        self.init(sentences: sentenceArray)
    }
    
    /**
     Goes through each sentence and adds it to the transition table
     */
    private func buildTransitionTable() {
        for sentence in self.sentences {
            self.addSentenceToTransitionTable(sentence)
        }
        
    }
    
    /**
     Adds a single sentence to the transition table
     
     - parameter sentence: sentence to add
     */
    private func addSentenceToTransitionTable(sentence: [String]) {
        
        for index in 0..<sentence.count {
            
            let word = String(sentence[index])
            var nextWord = "$" //Special character
            if index < sentence.count - 1 {
                nextWord = String(sentence[index + 1])
            }
            
            var transitionsArray = self.transitionTable[word]
            if (transitionsArray == nil) {
                transitionsArray = []
            }
            
            transitionsArray?.append(nextWord)
            
            self.transitionTable[word] = transitionsArray
            
        }
    }
    
    /**
     Generates a next word based on the provided word
     
     - parameter word: word to generate next word from
     
     - returns: new word randomly chosen based on analyzed text
     */
    private func generateNextWord(word: String) -> String {
        if let transitionArrayForWord = self.transitionTable[word] {
            let p = Int(arc4random()) % transitionArrayForWord.count
            
            return transitionArrayForWord[p]
        } else {
            return self.randomWord()
        }
    }
    
    /**
     Generates a totally random word
     
     - returns: random word
     */
    private func randomWord() -> String {
        let keyArray = Array(self.transitionTable.keys)
        return keyArray[Int(arc4random()) % keyArray.count]
    }
    
    /**
     Generates sentence based on optional start string
     
     - parameter startString: optional start string, if blank, starts from random word
     
     - returns: sentence based off of start word
     */
    func generateSentence(startString: String = "") -> String {
        
        let startStringArray = startString.componentsSeparatedByString(" ")
        
        var currentWord = self.randomWord()
        var result: [String] = []
        result.append(currentWord)
        
        if startStringArray.count > 0 {
            result = startStringArray
            currentWord = startStringArray.last!
        }
        
        for i in 1...self.maxSentenceLength {
            currentWord = self.generateNextWord(currentWord)
            
            if currentWord == "$" {
                if i > self.minSentenceLength {
                    let resultString = result.reduce("", combine: { "\($0) \($1)" })
                    return "\(resultString)."
                } else {
                    currentWord = self.randomWord()
                }
            }
            
            result.append(currentWord)
        }
        
        
        let resultString = result.reduce("", combine: { "\($0) \($1)" })
        return "\(resultString)."
    }
    
}
