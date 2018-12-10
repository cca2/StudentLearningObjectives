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
    
    var moveUpResponder:EditableTextView?
    var moveDownResponder:EditableTextView?
    
    var isObjectiveDescription: Bool {return true}
    var isTagsList: Bool {return false}

    override var acceptsFirstResponder: Bool { return true }
    
    override func resignFirstResponder() -> Bool {
        self.insertionPointColor = NSColor.clear
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        if let student = self.student, let objective = self.learningObjective {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.selectedObjective = (student, objective)
        }
        self.insertionPointColor = NSColor.red
        return true
    }
    
    override func moveDown(_ sender: Any?) {
        if let moveDownResponder = self.moveDownResponder {
            self.window?.makeFirstResponder(moveDownResponder)
        }
    }

    override func moveUp(_ sender: Any?) {
        if let moveUpResponder = self.moveUpResponder {
            self.window?.makeFirstResponder(moveUpResponder)
        }
    }
    
}

class TagsListTextView: EditableTextView {
    override var isTagsList: Bool {return true}
    override var isObjectiveDescription: Bool {return false}
    
    private var changedMustHave:Bool? {
        didSet {
            if oldValue != changedMustHave {
                highLightTags()
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let res = super.becomeFirstResponder()
        highLightTags()
        return res
    }
    
    override func didChangeText() {
        self.changedMustHave = self.string.contains("#musthave")
        super.didChangeText()
    }
    
    
    func highLightTags() {
        let tagsAttributedString = NSMutableAttributedString(string: "")
        tagsAttributedString.append(self.attributedString())
        
        let topicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.lightGray]
        let mustHaveTagAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.blue]

        if tagsAttributedString.string.contains("#musthave") {
            tagsAttributedString.replaceCharacters(in: NSMakeRange(0, String("#musthave").count), with: NSAttributedString(string: "#musthave", attributes: mustHaveTagAttributes as [NSAttributedString.Key : Any]))
            self.textStorage?.setAttributedString(tagsAttributedString)
        }else {
            self.textColor = NSColor.lightGray
        }
    }
    
}

class LearningObjectiveCellView: NSTableCellView {
    @IBOutlet var descriptionView: EditableTextView!
    @IBOutlet var tagsListView: TagsListTextView!
    
    var objective:StudentLearningObjective? {
        didSet {
            let delegate = NSApplication.shared.delegate as! AppDelegate
            let student = delegate.selectedStudent
            descriptionView.student = student
            descriptionView.learningObjective = objective
            tagsListView.student = student
            tagsListView.learningObjective = objective
            fitForObjective(objective: objective!)
        }
    }

    func fitForObjective(objective: StudentLearningObjective) {
        self.descriptionView.nextResponder = self.tagsListView
        let font = NSFont.systemFont(ofSize: 13.0)
        let attributes: [NSAttributedString.Key:Any] = [.font:font, .foregroundColor:NSColor.darkGray]
        let richTextDescription = NSMutableAttributedString(string: "", attributes:attributes)

        richTextDescription.append(highlightTopics(text: objective.description, tags: objective.tags))
        tagsListView.textStorage?.setAttributedString(addClassificationToDescription(objective: objective))
        self.descriptionView.textStorage?.setAttributedString(richTextDescription)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        self.tagsListView.moveUpResponder = self.descriptionView
        self.descriptionView.moveDownResponder = self.tagsListView
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    func addClassificationToDescription(objective: StudentLearningObjective) -> NSAttributedString {
        let tagsAttributedString = NSMutableAttributedString(string: "")
        
        let topicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.lightGray]
        let mustHaveTagAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.blue]
        if (objective.priority == "must-have") {
            let priorityTagAttributedString = NSAttributedString(string:"#musthave", attributes: mustHaveTagAttributes as [NSAttributedString.Key : Any])
            tagsAttributedString.append(priorityTagAttributedString)
        }else {
            let priorityTagAttributedString = NSAttributedString(string:"#nicetohave", attributes: topicAttributes as [NSAttributedString.Key : Any])
            tagsAttributedString.append(priorityTagAttributedString)
        }
        
        let expertiseLevelTagAttributedString = NSAttributedString(string:" #" + objective.level, attributes: topicAttributes as [NSAttributedString.Key : Any])
        tagsAttributedString.append(expertiseLevelTagAttributedString)
        if objective.isAbandoned {
            tagsAttributedString.append(NSAttributedString(string: " #abandonado", attributes: topicAttributes as [NSAttributedString.Key: Any]))
        }
        if objective.isInBacklog {
            tagsAttributedString.append(NSAttributedString(string: " #inbacklog", attributes: topicAttributes as [NSAttributedString.Key: Any]))
        }
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

