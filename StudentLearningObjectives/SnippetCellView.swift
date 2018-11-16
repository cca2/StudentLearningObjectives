//
//  StudentCellView.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 31/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa

class SnippetCellView: NSTableCellView {
    @IBOutlet weak var studentName: NSTextField!
    @IBOutlet weak var numProgrammingObjectivesLabel: NSTextField!
    @IBOutlet weak var numAppDevObjectivesLabel: NSTextField!
    @IBOutlet weak var numSuccessSkillsObjectivesLabel: NSTextField!
    @IBOutlet weak var numInnovationObjectivesLabel: NSTextField!
    @IBOutlet weak var numDesignObjectivesLabel: NSTextField!
    @IBOutlet weak var studentBox: NSBox!
    
    @IBOutlet weak var programmingLabel: NSTextField!
    @IBOutlet weak var designLabel: NSTextField!
    @IBOutlet weak var innovationLabel: NSTextField!
    @IBOutlet weak var successSkillsLabel: NSTextField!
    @IBOutlet weak var appDevLabel: NSTextField!
    
    @IBOutlet weak var selectedCellBoxIndicator: NSBox!
    let labelColor = NSColor.systemGray
    var student: Student?
    var team: Team?
    
    func displayTeamSnippet(team:Team) {
        self.team = team
        
        self.studentName.stringValue = team.name
        self.numProgrammingObjectivesLabel.isHidden = true
        self.numAppDevObjectivesLabel.isHidden = true
        self.numDesignObjectivesLabel.isHidden = true
        self.numInnovationObjectivesLabel.isHidden = true
        self.numSuccessSkillsObjectivesLabel.isHidden = true
        
        self.programmingLabel.isHidden = true
        self.appDevLabel.isHidden = true
        self.designLabel.isHidden = true
        self.successSkillsLabel.isHidden = true
        self.innovationLabel.isHidden = true
        
        self.selectedCellBoxIndicator.fillColor = NSColor.white
    }
    
    func displaySelectedTeamSnippet(team: Team) {
        displayTeamSnippet(team: team)
        self.selectedCellBoxIndicator.fillColor = NSColor.red
    }
    
    func displayStudent(student: Student) {
        self.student = student        
        self.studentName.stringValue = self.student!.name
        
        self.numProgrammingObjectivesLabel.isHidden = false
        self.numAppDevObjectivesLabel.isHidden = false
        self.numDesignObjectivesLabel.isHidden = false
        self.numInnovationObjectivesLabel.isHidden = false
        self.numSuccessSkillsObjectivesLabel.isHidden = false
        
        self.programmingLabel.isHidden = false
        self.appDevLabel.isHidden = false
        self.designLabel.isHidden = false
        self.successSkillsLabel.isHidden = false
        self.innovationLabel.isHidden = false

        let numProgramming:Int = student.classifiedObjectives["programming"]!.count
        self.numProgrammingObjectivesLabel.stringValue = String(numProgramming)
        let numDesign:Int = student.classifiedObjectives["design"]!.count
        self.numDesignObjectivesLabel.stringValue = String(numDesign)
        let numInnovation:Int = student.classifiedObjectives["innovation"]!.count
        self.numInnovationObjectivesLabel.stringValue = String(numInnovation)
        let numSK:Int = student.classifiedObjectives["success skills"]!.count
        self.numSuccessSkillsObjectivesLabel.stringValue = String(numSK)
        let numAppDev:Int = student.classifiedObjectives["appdev"]!.count
        self.numAppDevObjectivesLabel.stringValue = String(numAppDev)
        
        self.studentBox.fillColor = NSColor.white
        self.studentName.textColor = NSColor.black
        self.numAppDevObjectivesLabel.textColor = self.labelColor
        self.numSuccessSkillsObjectivesLabel.textColor = self.labelColor
        self.numInnovationObjectivesLabel.textColor = self.labelColor
        self.numProgrammingObjectivesLabel.textColor = self.labelColor
        self.numDesignObjectivesLabel.textColor = self.labelColor
        
        self.programmingLabel.textColor = self.labelColor
        self.designLabel.textColor = self.labelColor
        self.appDevLabel.textColor = self.labelColor
        self.innovationLabel.textColor = self.labelColor
        self.successSkillsLabel.textColor = self.labelColor
        self.selectedCellBoxIndicator.fillColor = NSColor.white
    }
    
    func displaySelectedStudent(student: Student) {
        self.displayStudent(student: student)
        
        self.studentBox.fillColor = NSColor.white
        self.studentName.textColor = NSColor.black
        self.numAppDevObjectivesLabel.textColor = self.labelColor
        self.numSuccessSkillsObjectivesLabel.textColor = self.labelColor
        self.numInnovationObjectivesLabel.textColor = self.labelColor
        self.numProgrammingObjectivesLabel.textColor = self.labelColor
        self.numDesignObjectivesLabel.textColor = self.labelColor
        
        self.programmingLabel.textColor = NSColor.systemGray
        self.designLabel.textColor = self.labelColor
        self.appDevLabel.textColor = self.labelColor
        self.innovationLabel.textColor = self.labelColor
        self.successSkillsLabel.textColor = self.labelColor
        
        self.selectedCellBoxIndicator.fillColor = NSColor.red
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
