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
    @IBOutlet var descriptionView: NSTextView!
    @IBOutlet weak var selectedBox: NSBox!
    @IBOutlet weak var statusBox: NSBox!
    @IBOutlet weak var inBacklogCheck: NSButton!
    @IBOutlet weak var abandonedCheck: NSButton!
    @IBOutlet weak var studiedCheck: NSButton!
    @IBOutlet weak var experimentedCheck: NSButton!
    @IBOutlet weak var appliedCheck: NSButton!
    @IBOutlet weak var taughtCheck: NSButton!
    
    func fitForObjective(elementToDisplay: NoteElementToDisplay) {
        let richTextDescription = NSMutableAttributedString(string: "")
//        if let objective = elementToDisplay.objective {
//            richTextDescription.append(highlightTopics(text: objective.description, tags: objective.tags))
//        }
//
//        let attributedText = descriptionView.attributedString()
//        attributedText.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) {
//            (value, range, stop) in
//            if let font = value as? NSFont {
//                richTextDescription.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, richTextDescription.length))
//            }
//        }
//
//        attributedText.enumerateAttribute(NSAttributedString.Key.foregroundColor, in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) {
//            (value, range, stop) in
//            if let foregroundColor = value as? NSColor {
//                richTextDescription.addAttribute(NSAttributedString.Key.foregroundColor, value: foregroundColor, range: NSMakeRange(0, richTextDescription.length))
//            }
//        }

        if let objective = elementToDisplay.objective {
            richTextDescription.append(highlightTopics(text: objective.description, tags: objective.tags))
            richTextDescription.append(addClassificationToDescription(objective: objective))
            if objective.isInBacklog {
                inBacklogCheck.state = NSControl.StateValue.on
            }
            if objective.isStudying {
                studiedCheck.state = NSControl.StateValue.on
            }
            if objective.isExperimenting {
                experimentedCheck.state = NSControl.StateValue.on
            }
            if objective.isApplyingInTheSolution {
                appliedCheck.state = NSControl.StateValue.on
            }
            if objective.isTeachingOthers {
                taughtCheck.state = NSControl.StateValue.on
            }
        }else if let paragraph = elementToDisplay.paragraph {
            richTextDescription.append(NSAttributedString(string: paragraph))
        }
        self.descriptionView.textStorage?.setAttributedString(richTextDescription)
//        self.descriptionView.textStorage?.append(richTextDescription)
        
        selectedBox.isHidden = !elementToDisplay.isSelected
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    func addClassificationToDescription(objective: StudentLearningObjective) -> NSAttributedString {
        let res = NSMutableAttributedString(string: "")

        let topicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.lightGray]
        if (objective.priority == "must-have") {
            let priorityTagAttributedString = NSAttributedString(string:" #musthave", attributes: topicAttributes as [NSAttributedString.Key : Any])
            res.append(priorityTagAttributedString)
        }else {
            let priorityTagAttributedString = NSAttributedString(string:" #nicetohave", attributes: topicAttributes as [NSAttributedString.Key : Any])
            res.append(priorityTagAttributedString)
        }
        
        let expertiseLevelTagAttributedString = NSAttributedString(string:" #" + objective.level, attributes: topicAttributes as [NSAttributedString.Key : Any])
        res.append(expertiseLevelTagAttributedString)
        
        let topicTagAttributedString = NSAttributedString(string: " #" + objective.topic, attributes: topicAttributes as [NSAttributedString.Key : Any])
        res.append(topicTagAttributedString)
        
        return res
    }
    
    func highlightTopics(text: String, tags:[(tag:String, value:String)]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
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

class ParagraphCellView: NSTableCellView {
    @IBOutlet weak var selectedBox: NSBox!
    @IBOutlet var paragraphTextView: NSTextView!
    
    func fitForParagraph(elementToDisplay: NoteElementToDisplay) {
        let richTextDescription = NSMutableAttributedString(string: "")
        if let paragraph = elementToDisplay.paragraph {
            richTextDescription.append(NSAttributedString(string: paragraph))
        }
        let attributedText = paragraphTextView.attributedString()
        attributedText.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) {
            (value, range, stop) in
            if let font = value as? NSFont {
                richTextDescription.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, richTextDescription.length))
            }
        }
        
        attributedText.enumerateAttribute(NSAttributedString.Key.foregroundColor, in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) {
            (value, range, stop) in
            if let foregroundColor = value as? NSColor {
                richTextDescription.addAttribute(NSAttributedString.Key.foregroundColor, value: foregroundColor, range: NSMakeRange(0, richTextDescription.length))
            }
        }
        self.paragraphTextView.textStorage?.setAttributedString(richTextDescription)
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
}

