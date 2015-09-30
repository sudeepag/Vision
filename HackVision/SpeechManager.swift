//
//  SpeechManager.swift
//  HackVision
//
//  Created by Sudeep Agarwal on 9/19/15.
//  Copyright © 2015 Sudeep Agarwal. All rights reserved.
//

import Foundation
import AVFoundation

class SpeechManager: NSObject, AVSpeechSynthesizerDelegate {
    
    static let sharedManager = SpeechManager()
    var camVC: CamViewController!
    let speechSynthesizer = AVSpeechSynthesizer()
    let vowels = "aeiou"
    
    func readTextForResult(result: ClarifaiResult) {
        let word = wordForTags(result.tags as! [String])!
        let textToRead = "This is " + prefixForWord(word) + word
        readText(textToRead)
        if (word == "document") {
            readText("If you'd like me to read it, double tap on the screen.")
            camVC.shouldRecognizeMultipleTaps = true
        }
    }
    
    func readText(text: String) {
        print("reading text")
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.delegate = camVC
        speechSynthesizer.speakUtterance(speechUtterance)
    }

    func wordForTags(tags: [String]) -> String? {
        print(tags)
        
        for alias in documentAliases {
            if (tags.contains(alias)) {
                return "document"
            }
        }
        
        for word in tags {
            if (WordManager.sharedManager.wordList.contains(word)) {
                return word
            }
        }
        
        return nil
    }
    
    func prefixForWord(word: String) -> String {
        if (vowels.characters.contains(word.characters.first!)) {
            return "an "
        } else {
            return "a "
        }
    }
    
    
}
