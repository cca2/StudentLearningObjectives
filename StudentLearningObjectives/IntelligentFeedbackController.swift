//
//  IntelligentFeedbackController.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 07/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa

protocol IntelligentAlertProtocol {
    func displayAlert(message: String) -> Void
}

class IntelligentElementToDisplay {
    var student:Student?
    var objective:StudentLearningObjective? {
        didSet {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            let course = appDelegate.selectedCourse
            self.student = course?.studentsByID[(objective?.studentID)!]
            print(">>> 500 \\(self.student.name)<<<")
        }
    }
    var message:IntelligentAlertMessage?
}

class IntelligentFeedbackController: NSPageController {
    var cblSprint:CBLSprint?
    var listOfMatchesByObjective:[(Student, StudentLearningObjective)]!
    var intelligentAlert:IntelligentAlertMessage?
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    
    var elementsToDisplay:[IntelligentElementToDisplay] = []
    
    @IBOutlet weak var studentMatchByObjectiveList: NSTableView!
    
    @IBOutlet weak var intelligentLabel: NSTextField!
    @IBOutlet weak var numberOfMatchs: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.intelligentLabel.isHidden = true
        self.numberOfMatchs.isHidden = true
        
        self.studentMatchByObjectiveList.dataSource = self
        self.studentMatchByObjectiveList.delegate = self
        
        self.studentMatchByObjectiveList.register(NSNib(nibNamed: "StudentMatchByObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("StudentMatchByObjectiveCellID"))
        
        self.studentMatchByObjectiveList.register(NSNib(nibNamed: "StudentMatchByObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("IntelligentAlertCellID"))
        
        appDelegate.onObjectiveSelected = {(student, objective) in
            self.listOfMatchesByObjective = self.appDelegate.selectedSprint?.matchStudents(student: student, objective: objective)
            self.elementsToDisplay = []
            self.listOfMatchesByObjective.forEach{
                match in
                let intelligentSnippet = IntelligentElementToDisplay()
                intelligentSnippet.objective = match.1
                self.elementsToDisplay.append(intelligentSnippet)
                self.numberOfMatchs.stringValue = String(self.listOfMatchesByObjective.count)
                self.numberOfMatchs.isHidden = false
                self.intelligentLabel.isHidden = false
                self.studentMatchByObjectiveList.reloadData()
            }
        }
        
        let teamSelectedClosure:((Team) -> ())? = {
            team in
            self.numberOfMatchs.isHidden = true
            self.intelligentLabel.isHidden = true
            self.listOfMatchesByObjective = []
            self.elementsToDisplay = []
            self.studentMatchByObjectiveList.reloadData()
        }
        
        appDelegate.onTeamSelected.append(teamSelectedClosure)
        
        let studentSelectedClosure:((Student) ->())? = {
            student in
            self.numberOfMatchs.isHidden = true
            self.intelligentLabel.isHidden = true
            self.listOfMatchesByObjective = []
            self.elementsToDisplay = []
            self.studentMatchByObjectiveList.reloadData()
        }
        appDelegate.onStudentSelected.append(studentSelectedClosure)
        
        let intelligentMessageClosure: ((IntelligentAlertMessage) -> ())? = {
            message in
            self.elementsToDisplay = []
            let elementToDisplay = IntelligentElementToDisplay()
            elementToDisplay.message = message
            self.elementsToDisplay.append(elementToDisplay)
            self.studentMatchByObjectiveList.reloadData()
        }
        appDelegate.onDisplayIntelligentAlertMessage = intelligentMessageClosure
        
        let clearIntelligentAlertClosure: (() -> ())? = {
            self.elementsToDisplay = []
            self.studentMatchByObjectiveList.reloadData()
        }
        appDelegate.onClearIntelligentAlerts = clearIntelligentAlertClosure
    }
}

extension IntelligentFeedbackController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.elementsToDisplay.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let elementToDisplay = self.elementsToDisplay[row]
        if let objective = elementToDisplay.objective {
            let fakeField = NSTextField()
            let item = objective.description
            let objectiveDescriptionWidth = CGFloat(262.0)
            fakeField.stringValue = item
            // exactly how you get the text out of your data array depends on how you set it up
            let yourHeight = fakeField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), objectiveDescriptionWidth, CGFloat(Float.greatestFiniteMagnitude))).height + 70.0
            return yourHeight
        }else {
            return 100.0
        }
//        if let matches = self.listOfMatchesByObjective {
//            let objective = matches[row].1
//            let fakeField = NSTextField()
//            let item = objective.description
//            let objectiveDescriptionWidth = CGFloat(262.0)
//
//            fakeField.stringValue = item
//            // exactly how you get the text out of your data array depends on how you set it up
//
//            let yourHeight = fakeField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), objectiveDescriptionWidth, CGFloat(Float.greatestFiniteMagnitude))).height + 70.0
//            return yourHeight
//        }else {
//            return 50.0
//        }
    }
}

extension IntelligentFeedbackController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView == self.studentMatchByObjectiveList) {
            let elementToDisplay = self.elementsToDisplay[row]
            if let objective = elementToDisplay.objective {
                let cellIdentifier = "StudentMatchByObjectiveCellID"
                if tableColumn == tableView.tableColumns[0] {
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  StudentMatchByObjectiveCellView {
                        cell.studentName.stringValue = (elementToDisplay.student?.name)!
                        cell.displayObjective(objective: objective)
                        return cell
                    }
                }
            }else if let message = elementToDisplay.message {
                let cellIdentifier = "IntelligentAlertCellID"
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? IntelligentAlertView {
                    cell.message.stringValue = message.message
                    return cell
                }
            }
        }
        return nil
    }

}

extension IntelligentFeedbackController: IntelligentAlertProtocol {
    func displayAlert(message: String) {
        
    }
}

