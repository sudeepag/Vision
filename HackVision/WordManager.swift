//
//  WordManager.swift
//  HackVision
//
//  Created by Sudeep Agarwal on 9/19/15.
//  Copyright © 2015 Sudeep Agarwal. All rights reserved.
//

import Foundation

class WordManager {
    
    static let sharedManager = WordManager()
    var wordList = [String]()
    
    init() {
        if let wordsPath = NSBundle.mainBundle().pathForResource("nounlist", ofType: "txt") {
            do {
                let words = try NSString(contentsOfFile: wordsPath, encoding: NSUTF8StringEncoding)
                wordList = words.componentsSeparatedByString("\n") as [String]
            }
            catch {/* error handling here */}
        }
    }
    
}