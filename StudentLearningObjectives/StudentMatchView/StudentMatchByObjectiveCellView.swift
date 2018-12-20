//
//  StudentMatchByObjectiveCellView.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 07/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa

class StudentMatchByObjectiveCellView: NSTableCellView {
    @IBOutlet weak var studentName: NSTextField!
    @IBOutlet weak var priorityLevel: NSTextField!
    @IBOutlet weak var learningLevel: NSTextField!
    @IBOutlet weak var objectiveDescription: NSTextField!
    
    func displayObjective(objective: StudentLearningObjective) {
        self.objectiveDescription.stringValue = objective.description
        self.priorityLevel.stringValue = objective.priority
        self.learningLevel.stringValue = objective.level
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

class IntelligentAlertView: NSTableCellView {
    @IBOutlet weak var message: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
}

class TrainingAlertView: NSTableCellView {
    @IBOutlet weak var deviceSelectButton: NSButton!
    @IBOutlet weak var topicSelectButton: NSButton!
    @IBOutlet weak var toolSelectButton: NSButton!
    
    @IBOutlet weak var exportToJSONButton: NSButton!
    
    @IBAction func exportToJSONPressed(_ sender: Any) {
        let classifier = BloomsRevisedTaxonomyClassifier()
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let objectives = appDelegate.selectedSprint?.learningObjectiveByID
        
        //let objective = "Acho interessante passar informações com icons. Acho importante para Apple Watch"
        //let objective2 = "Aprender e aplicar ARM com enfoque na aquisição."
        //
        //classifier.tagObjective(description: objective.description, tokens: ["Apple", "Watch"], tags: ["DEVICE", "DEVICE"])
        //classifier.tagObjective(description: objective2.description, tokens: ["ARM", "aquisição"], tags: ["TOPIC", "TOPIC"])
        //
        //classifier.saveTaggedObjectivesToJSON()
        //
        //
        //classifier.checkForMeasurableVerb(objective: objective, onCheked: {
        //    objective, status, verbs in
        //    if status == BloomsRevisedTaxonomyClassifier.MeasurableVertStatus.NoVerb {
        //        print("o objetivo \(objective) não possui uma ação observável")
        //    }
        //})
        //
        //classifier.checkForLearningTopics(objective: objective, onCheked: {
        //    objective, topics in
        //
        //    if topics.count == 0 {
        //        print("Não foram encontrados tópicos de aprendizado!")
        //    }else if topics.count == 1 {
        //        print("Foi encontrado o tópico: \(topics.first!)")
        //    }else if topics.count > 1 {
        //        print("Foram econtrados os tópicos: \(topics)")
        //    }
        //})
        //
        //classifier.checkForTopics(objective: objective, onCheked: {
        //    objective, topics in
        //})
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
}
