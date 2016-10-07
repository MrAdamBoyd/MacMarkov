//
//  MarkovGenerator.swift
//  MarkovGenerator
//
//  Created by Adam Boyd on 2016-03-05.
//  Copyright © 2016 Adam. All rights reserved.
//

import Foundation

protocol MarkovGeneratorDelegate {
    func updateProgress(_ progress: CGFloat)
    func finishedFile()
}

class MarkovGenerator {
    
    fileprivate var transitionTable: [String : [String : Int]] = [:]
    
    var minSentenceLength = 3
    var maxSentenceLength = 20
    var delegate: MarkovGeneratorDelegate?
    
    func addFileToGenerator(_ fileName: String) {
        let separatedText = (try! String(contentsOfFile: fileName, encoding: String.Encoding.utf8)).components(separatedBy: CharacterSet(charactersIn: "\n.")).map { $0.lowercased() }
        
        //There has to be a better way of doing this, will fix later
        let cleanedText = separatedText.map({ self.cleanText($0) })
        let sentenceArray = cleanedText.map({ $0.components(separatedBy: " ") })
        
        self.buildTransitionTable(sentenceArray)
    }
    
    /**
     Goes through each sentence and adds it to the transition table
     */
    fileprivate func buildTransitionTable(_ sentences: [[String]]) {
        var count = 0
        let howOftenToNotifyDelegate = sentences.count % 1000 //Number of times it needs to be called
        for sentence in sentences {
            self.addSentenceToTransitionTable(sentence)
            if count % howOftenToNotifyDelegate == 0 {
                self.delegate?.updateProgress(CGFloat(count) / CGFloat(sentences.count))
            }
            count += 1
        }
        
        self.delegate?.finishedFile()
        
    }
    
    /**
     Adds a single sentence to the transition table
     
     - parameter sentence: sentence to add
     */
    fileprivate func addSentenceToTransitionTable(_ sentence: [String]) {
        
        for index in 0..<sentence.count {
            
            let word = String(sentence[index])!
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
    fileprivate func generateNextWord(_ word: String) -> String {
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
    fileprivate func randomWord() -> String {
        let keyArray = Array(self.transitionTable.keys)
        return keyArray[Int(arc4random()) % keyArray.count]
    }
    
    /**
     Generates sentence based on optional start string
     
     - parameter startString: optional start string, if blank, starts from random word
     
     - returns: sentence based off of start word
     */
    func generateSentence(withSeedString startString: String = "") -> String {
        
        let startStringArray = startString.components(separatedBy: " ")
        
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
                    let resultString = result.reduce("", { ($0 == "") ? "\($0)\($1)" : "\($0) \($1)" })
                    return "\(resultString.sentenceCaseString)"
                } else {
                    currentWord = self.randomWord()
                }
            }
            
            result.append(currentWord)
        }
        
        
        let resultString = result.reduce("", { ($0 == "") ? "\($0)\($1)" : "\($0) \($1)" })
        return "\(resultString.sentenceCaseString)"
    }
    
    /**
     Removes all but alphanumeric and "-" from string
     
     - parameter text: text to clean
     
     - returns: text without any special characters
     */
    fileprivate func cleanText(_ text: String) -> String {
        let chars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
        return String(text.characters.filter { chars.contains($0) })
    }
    
}
