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
        let topicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.red]
        let areaTagAttributedString = NSAttributedString(string:"#" + objective.area, attributes: topicAttributes as [NSAttributedString.Key : Any])
        let priorityTagAttributedString = NSAttributedString(string:"#" + objective.priority, attributes: topicAttributes as [NSAttributedString.Key : Any])
        let expertiseLevelTagAttributedString = NSAttributedString(string:"#" + objective.level, attributes: topicAttributes as [NSAttributedString.Key : Any])

        areaLabel.attributedStringValue = areaTagAttributedString
        priorityLabel.attributedStringValue = priorityTagAttributedString
        classificationLabel.attributedStringValue = expertiseLevelTagAttributedString
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
