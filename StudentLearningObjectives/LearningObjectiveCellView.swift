//
//  LearningObjectiveCellView.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 25/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa
import NaturalLanguage

class LearningObjectiveCellView: NSTableCellView {
    @IBOutlet weak var descriptionTextField: NSTextField!

    func fitForObjective(objective: StudentLearningObjective) {
        descriptionTextField.attributedStringValue = highlightTopics(text: objective.description, tags: objective.tags)
        var areaText = "N"
        var areaColor = NSColor(red: CGFloat(255), green: CGFloat(126), blue: CGFloat(121), alpha: CGFloat(100.0))
        if objective.area == "design" {
            areaText = "D"
            areaColor = NSColor.red
        }else if objective.area == "innovation" {
            areaText = "I"
            areaColor = NSColor.blue
        }else if objective.area == "programming" {
            areaText = "P"
            areaColor = NSColor.green
        }else if objective.area == "appdev" {
            areaText = "A"
            areaColor = NSColor.orange
        }else if objective.area == "success skills" {
            areaText = "S"
            areaColor = NSColor.magenta
        }
        
        self.descriptionTextField.focusRingType = .none
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    func highlightTopics(text: String, tags:[(tag:String, value:String)]) -> NSAttributedString {
        let topicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.red]
        let attributedText = NSMutableAttributedString(string: "")
        
        var textLexicalTags: [(string:String, rawValue:String)] = []
        
        //Copia as tags para um array temporário que será usado para fazer o highlight
        var tempTags: [(tag:String, value:String)] = []
        tags.forEach{tag in
            tempTags.append(tag)
        }
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                textLexicalTags.append((string:String(text[tokenRange]), rawValue:String(tag.rawValue)))
            }
            return true
        }
        
        textLexicalTags.forEach{
            lexicalTag in
            var foundTag = false
            var newAttributedString = NSAttributedString(string: lexicalTag.string)
            tempTags.forEach{tag in
                if !foundTag {
                    if lexicalTag.string == tag.value{
                        if tag.tag == "TOPIC" {
                            newAttributedString = NSAttributedString(string:lexicalTag.string, attributes: topicAttributes as [NSAttributedString.Key : Any])
                            tempTags.remove(at: 0)
                        }
                        foundTag = true
                    }
                }
            }
            attributedText.append(newAttributedString)
        }
        return attributedText
    }
}
