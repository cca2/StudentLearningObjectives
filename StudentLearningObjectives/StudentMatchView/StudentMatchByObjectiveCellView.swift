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
