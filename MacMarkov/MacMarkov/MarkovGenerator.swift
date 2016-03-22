//
//  MarkovGenerator.swift
//  MarkovGenerator
//
//  Created by Adam Boyd on 2016-03-05.
//  Copyright © 2016 Adam. All rights reserved.
//

import Foundation

protocol MarkovGeneratorDelegate {
    func updateProgress(progress: CGFloat)
}

class MarkovGenerator {
    
    private var transitionTable: [String : [String : Int]] = [:]
    
    var minSentenceLength = 3
    var maxSentenceLength = 20
    var delegate: MarkovGeneratorDelegate?
    
    func addFileToGenerator(fileName: String) {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt")!
        
        let separatedText = (try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n.")).map { $0.lowercaseString }
        
        //There has to be a better way of doing this, will fix later
        let cleanText1 = separatedText.map({ $0.stringByReplacingOccurrencesOfString(";", withString: "") })
        let cleanText2 = cleanText1.map({ $0.stringByReplacingOccurrencesOfString(":", withString: "") })
        let cleanText3 = cleanText2.map({ $0.stringByReplacingOccurrencesOfString(",", withString: "") })
        let cleanText4 = cleanText3.map({ $0.stringByReplacingOccurrencesOfString("?", withString: "") })
        let cleanText5 = cleanText4.map({ $0.stringByReplacingOccurrencesOfString("!", withString: "") })
        let cleanText6 = cleanText5.map({ $0.stringByReplacingOccurrencesOfString(".", withString: "") })
        let sentenceArray = cleanText6.map({ $0.componentsSeparatedByString(" ") })
        
        self.buildTransitionTable(sentenceArray)
    }
    
    /**
     Goes through each sentence and adds it to the transition table
     */
    private func buildTransitionTable(sentences: [[String]]) {
        var count = 0
        for sentence in sentences {
            self.addSentenceToTransitionTable(sentence)
            self.delegate?.updateProgress(CGFloat(count) / CGFloat(sentences.count))
            count += 1
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
            
            //The array for the word
            var transitionsArray = self.transitionTable[word]
            if (transitionsArray == nil) {
                transitionsArray = [:]
            }
            
            if transitionsArray![nextWord] != nil {
                transitionsArray![nextWord]! += 1
            } else {
                transitionsArray![nextWord] = 1
            }
            
            self.transitionTable[word] = transitionsArray
            
        }
    }
    
    /**
     Generates a next word based on the provided word
     
     - parameter word: word to generate next word from
     
     - returns: new word randomly chosen based on analyzed text
     */
    private func generateNextWord(word: String) -> String {
        if let transitionDictForWord = self.transitionTable[word] {
            
            //Building an array of the entries for this word
            var arrayOfWords: [String] = []
            for word in transitionDictForWord.keys {
                for _ in 0...transitionDictForWord[word]! {
                    arrayOfWords.append(word)
                }
            }
            
            let random = Int(arc4random()) % arrayOfWords.count
            return arrayOfWords[random]
            
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
                    let resultString = result.reduce("", combine: { ($0=="") ? "\($0)\($1)" : "\($0) \($1)" })
                    return "\(resultString.sentenceCaseString)."
                } else {
                    currentWord = self.randomWord()
                }
            }
            
            result.append(currentWord)
        }
        
        
        let resultString = result.reduce("", combine: { ($0=="") ? "\($0)\($1)" : "\($0) \($1)" })
        return "\(resultString.sentenceCaseString)."
    }
    
}
