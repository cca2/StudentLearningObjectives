//
//  ObjectiveClassificationTableViewCell.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 28/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa

class ObjectiveClassificationTableViewCell: NSTableCellView {

    @IBOutlet weak var classificationLabel: NSTextField!
    @IBOutlet weak var areaLabel: NSTextField!
    @IBOutlet weak var priorityLabel: NSTextField!
    
    func displayLearningObjectiveInfo(objective: StudentLearningObjective) {
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
