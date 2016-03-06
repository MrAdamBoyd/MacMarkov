//
//  String+CapitalizeFirst.swift
//  MacMarkov
//
//  Created by Adam Boyd on 2016-03-05.
//  Copyright © 2016 Adam. All rights reserved.
//

import Foundation

extension String {
    var firstChar: String {
        return String(self.characters.prefix(1))
    }
    
    var lastChar: String {
        return String(self.characters.suffix(1))
    }
    
    
    var sentenceCaseString: String {
        return self.firstChar.uppercaseString + String(self.characters.dropFirst())
    }
}