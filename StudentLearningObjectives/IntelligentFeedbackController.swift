//
//  IntelligentFeedbackController.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 07/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa

class IntelligentFeedbackController: NSPageController {    
    var cblSprint:CBLSprint?
    var listOfMatchesByObjective:[(Student, StudentLearningObjective)]!
    
    @IBOutlet weak var studentMatchByObjectiveList: NSTableView!
    
    @IBOutlet weak var intelligentLabel: NSTextField!
    @IBOutlet weak var numberOfMatchs: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.intelligentLabel.isHidden = true
        self.numberOfMatchs.isHidden = true
        
        let delegate = NSApplication.shared.delegate as! AppDelegate
        self.cblSprint = delegate.selectedSprint
        
        self.studentMatchByObjectiveList.dataSource = self
        self.studentMatchByObjectiveList.delegate = self
        
        self.studentMatchByObjectiveList.register(NSNib(nibNamed: "StudentMatchByObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("StudentMatchByObjectiveCellID"))
        
        delegate.onObjectiveSelected = {(student, objective) in
            self.listOfMatchesByObjective = self.cblSprint?.matchStudents(student: student, objective: objective)
            self.numberOfMatchs.stringValue = String(self.listOfMatchesByObjective.count)
            self.numberOfMatchs.isHidden = false
            self.intelligentLabel.isHidden = false
            self.studentMatchByObjectiveList.reloadData()
        }
        
        let teamSelectedClosure:((Team) -> ())? = {
            team in
            self.numberOfMatchs.isHidden = true
            self.intelligentLabel.isHidden = true
            self.listOfMatchesByObjective = []
            self.studentMatchByObjectiveList.reloadData()
        }
        
        delegate.onTeamSelected.append(teamSelectedClosure)

//        delegate.onStudentSelected = {
//            self.numberOfMatchs.isHidden = true
//            self.intelligentLabel.isHidden = true
//            self.listOfMatchesByObjective = []
//            self.studentMatchByObjectiveList.reloadData()
//        }
    }
}

extension IntelligentFeedbackController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let matches = self.listOfMatchesByObjective {
            return matches.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let matches = self.listOfMatchesByObjective {
            let objective = matches[row].1
            let fakeField = NSTextField()
            let item = objective.description
            let objectiveDescriptionWidth = CGFloat(262.0)
            
            fakeField.stringValue = item
            // exactly how you get the text out of your data array depends on how you set it up
            
            let yourHeight = fakeField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), objectiveDescriptionWidth, CGFloat(Float.greatestFiniteMagnitude))).height + 70.0
            return yourHeight
        }else {
            return 50.0
        }
    }
}

extension IntelligentFeedbackController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView == self.studentMatchByObjectiveList) {
            let cellIdentifier = "StudentMatchByObjectiveCellID"
            
            if tableColumn == tableView.tableColumns[0] {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  StudentMatchByObjectiveCellView {
                    cell.studentName.stringValue = self.listOfMatchesByObjective[row].0.name
                    cell.displayObjective(objective: self.listOfMatchesByObjective[row].1)
                    return cell
                }
            }
        }
        return nil
    }

}
