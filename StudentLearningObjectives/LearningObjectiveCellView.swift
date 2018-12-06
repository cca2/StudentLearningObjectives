//
//  LearningObjectiveCellView.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 25/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa
import NaturalLanguage

class EditableTextView: NSTextView {
    var student: Student?
    var learningObjective: StudentLearningObjective?
    
    override func becomeFirstResponder() -> Bool {
        if let student = student, let objective = self.learningObjective {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.selectedObjective = (student, objective)
        }
        self.insertionPointColor = NSColor.red
        return true
    }
}

class LearningObjectiveCellView: NSTableCellView {
    @IBOutlet var descriptionView: EditableTextView!
    @IBOutlet var tagsListView: EditableTextView!
    @IBOutlet weak var statusBox: NSBox!
    @IBOutlet weak var studiedCheck: NSButton!
    @IBOutlet weak var experimentedCheck: NSButton!
    @IBOutlet weak var appliedCheck: NSButton!
    @IBOutlet weak var taughtCheck: NSButton!
    @IBOutlet weak var showObjectiveStatusBtn: NSButton!
    
    var elementToDisplay:NoteElementToDisplay?
    
    var objective:StudentLearningObjective?
    
    @IBAction func showObjectiveStatusPressed(_ sender: NSButton) {
        let state = sender.state
        if state == NSControl.StateValue.on {
            self.elementToDisplay?.showObjectiveStatus = true
            statusBox.isHidden = false
        }else if state == NSControl.StateValue.off {
            self.elementToDisplay?.showObjectiveStatus = false
            statusBox.isHidden = true
        }
        NotificationCenter.default.post(name: NSNotification.Name("didChangeShowStatusForObjective"), object: elementToDisplay)
    }
    
    @IBAction func studiedCheckHasChanged(_ sender: NSButton) {
        if let objective = self.objective {
            if sender.state.rawValue == 0 {
                objective.isStudying = false
            }else if sender.state.rawValue == 1 {
                objective.isStudying = true
            }else {
                objective.isStudying = false
            }            
            NotificationCenter.default.post(name: NSNotification.Name("didUpdateObjective"), object: objective, userInfo: nil)
        }
    }
    
    @IBAction func experimentedCheckHasChanged(_ sender: NSButton) {
        if let objective = self.objective {
            if sender.state.rawValue == 0 {
                objective.isExperimenting = false
            }else if sender.state.rawValue == 1 {
                objective.isExperimenting = true
            }else {
                objective.isExperimenting = false
            }
            NotificationCenter.default.post(name: NSNotification.Name("didUpdateObjective"), object: objective, userInfo: nil)
        }
    }

    @IBAction func appliedCheckHasChanged(_ sender: NSButton) {
        if let objective = self.objective {
            if sender.state.rawValue == 0 {
                objective.isApplyingInTheSolution = false
            }else if sender.state.rawValue == 1 {
                objective.isApplyingInTheSolution = true
            }else {
                objective.isApplyingInTheSolution = false
            }
            NotificationCenter.default.post(name: NSNotification.Name("didUpdateObjective"), object: objective, userInfo: nil)
        }
    }


    @IBAction func taughtHasChecked(_ sender: NSButton) {
        if let objective = self.objective {
            if sender.state.rawValue == 0 {
                objective.isTeachingOthers = false
            }else if sender.state.rawValue == 1 {
                objective.isTeachingOthers = true
            }else {
                objective.isTeachingOthers = false
            }
            NotificationCenter.default.post(name: NSNotification.Name("didUpdateObjective"), object: objective, userInfo: nil)
        }
    }

    func fitForObjective(elementToDisplay: NoteElementToDisplay) {
        self.elementToDisplay = elementToDisplay
        if (self.elementToDisplay?.showObjectiveStatus)! {
            self.statusBox.isHidden = false
        }
        self.descriptionView.nextResponder = self.tagsListView
        let font = NSFont.systemFont(ofSize: 16.0)
        let attributes: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font:font]
        let richTextDescription = NSMutableAttributedString(string: "", attributes:attributes)

        if let objective = elementToDisplay.objective {
            self.objective = objective
            richTextDescription.append(highlightTopics(text: objective.description, tags: objective.tags))
            tagsListView.textStorage?.setAttributedString(addClassificationToDescription(objective: objective))
//            richTextDescription.append(addClassificationToDescription(objective: objective))
//            if objective.isInBacklog {
//                inBacklogCheck.state = NSControl.StateValue.on
//            }
            
//            if objective.isExperimenting {
//                experimentedCheck.state = NSControl.StateValue.on
//            }else {
//                experimentedCheck.state = NSControl.StateValue.off
//            }
//            if objective.isApplyingInTheSolution {
//                appliedCheck.state = NSControl.StateValue.on
//            }else {
//                appliedCheck.state = NSControl.StateValue.off
//            }
//            if objective.isTeachingOthers {
//                taughtCheck.state = NSControl.StateValue.on
//            }else {
//                taughtCheck.state = NSControl.StateValue.off
//            }
        }else if let paragraph = elementToDisplay.paragraph {
            richTextDescription.append(NSAttributedString(string: paragraph))
        }
        self.descriptionView.textStorage?.setAttributedString(richTextDescription)        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    func addClassificationToDescription(objective: StudentLearningObjective) -> NSAttributedString {
        let tagsAttributedString = NSMutableAttributedString(string: "")
        
        let topicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.lightGray]
        let mustHaveTagAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.blue, .font:NSFont.boldSystemFont(ofSize: CGFloat(11.0))]
        if (objective.priority == "must-have") {
            let priorityTagAttributedString = NSAttributedString(string:" #musthave", attributes: mustHaveTagAttributes as [NSAttributedString.Key : Any])
            tagsAttributedString.append(priorityTagAttributedString)
        }else {
            let priorityTagAttributedString = NSAttributedString(string:" #nicetohave", attributes: topicAttributes as [NSAttributedString.Key : Any])
            tagsAttributedString.append(priorityTagAttributedString)
        }
        
        let expertiseLevelTagAttributedString = NSAttributedString(string:" #" + objective.level, attributes: topicAttributes as [NSAttributedString.Key : Any])
        tagsAttributedString.append(expertiseLevelTagAttributedString)
        
        if objective.isStudying {
            tagsAttributedString.append(NSAttributedString(string: " #estudado", attributes: topicAttributes as [NSAttributedString.Key: Any]))
        }
        if objective.isExperimenting {
            tagsAttributedString.append(NSAttributedString(string: " #experimentado", attributes: topicAttributes as [NSAttributedString.Key: Any]))
        }
        if objective.isApplyingInTheSolution {
            tagsAttributedString.append(NSAttributedString(string: " #aplicado", attributes: topicAttributes as [NSAttributedString.Key: Any]))
        }
        if objective.isTeachingOthers {
            tagsAttributedString.append(NSAttributedString(string: " #ensinado", attributes: topicAttributes as [NSAttributedString.Key: Any]))
        }

//        let topicTagAttributedString = NSAttributedString(string: " #" + objective.topic, attributes: topicAttributes as [NSAttributedString.Key : Any])
//        tagsAttributedString.append(topicTagAttributedString)
        
        return tagsAttributedString
    }
    
    func highlightTopics(text: String, tags:[(tag:String, value:String)]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        let topicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.red, .font:NSFont.systemFont(ofSize: 13.0)]
        let nonTopicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.darkGray, .font:NSFont.systemFont(ofSize: 13.0)]
        
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
            var newAttributedString = NSAttributedString(string: lexicalTag.string, attributes:nonTopicAttributes as [NSAttributedString.Key : Any])
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

