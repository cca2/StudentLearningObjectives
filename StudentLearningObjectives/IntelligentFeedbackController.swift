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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let delegate = NSApplication.shared.delegate as! AppDelegate
        self.cblSprint = delegate.cblSprint
        
        self.studentMatchByObjectiveList.dataSource = self
        self.studentMatchByObjectiveList.delegate = self
        
        self.studentMatchByObjectiveList.register(NSNib(nibNamed: "StudentMatchByObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("StudentMatchByObjectiveCellID"))
        
        delegate.onObjectiveSelected = {(student, objective) in
            self.listOfMatchesByObjective = self.cblSprint?.matchStudents(student: student, objective: objective)
            self.studentMatchByObjectiveList.reloadData()
        }
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
        return 100.0
    }
}

extension IntelligentFeedbackController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView == self.studentMatchByObjectiveList) {
            let cellIdentifier = "StudentMatchByObjectiveCellID"
            
            if tableColumn == tableView.tableColumns[0] {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  StudentMatchByObjectiveCellView {
                    cell.studentName.stringValue = self.listOfMatchesByObjective[row].0.name
                    cell.objectiveDescription.stringValue = self.listOfMatchesByObjective[row].1.description
                    return cell
                }
            }
        }
        return nil
    }

}
