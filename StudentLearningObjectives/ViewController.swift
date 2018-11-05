//
//  ViewController.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 21/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa
import CoreML
import NaturalLanguage
import CreateML

class ViewController: NSViewController {
    
    @IBOutlet weak var trainButton: NSButton!
    @IBOutlet weak var taggerTrainingTableView: NSTableView!
    @IBOutlet weak var studentName: NSTextFieldCell!
    @IBOutlet weak var teamMembersView: NSTableView!
    @IBOutlet weak var teamsPopUp: NSPopUpButton!
    @IBOutlet weak var saveTrainingButton: NSButton!
    
    @IBOutlet weak var mustHaveTableView: NSTableView!
    
    var teamObjectivesDict:[String:[String:Student]] = [:]
    
    var studentsDict:Dictionary = [String:Student]()
    var objectivesToDisplay:[StudentLearningObjective] = []
    
    var selectedObjectiveIndex = -1
    var teamMembersNames:[String] = []
    var selectedStudent:Student?
    
    var selectedTeamName = ""
    
    var newDataForTraining:[StudentLearningObjective] = []
    
    let studentObjectiveClassifier = StudentObjectiveClassifier()
    
    @IBAction func tagHasBeenEdited(_ sender: NSTextField) {
        let newTag = sender.stringValue
        if (newTag == "ACTION" || newTag == "NONE" || newTag == "TOPIC" || newTag == "GENERIC_ACTION" || newTag == "GENERIC_TOPIC" || newTag == "DEVICE") {
            let tagRow = self.taggerTrainingTableView.selectedRow
            let objectiveRow = self.mustHaveTableView.selectedRow
            if objectiveRow > 0 {
                self.objectivesToDisplay[objectiveRow].tags[tagRow].tag = sender.stringValue
            }
        }else {
            //AQUI: não está funcionando
            sender.abortEditing()
        }
    }
    
    @IBAction func saveTrainingButtonPressed(_ sender: Any) {
        let trainer = LearningObjectivesTrainer()
        trainer.updateTrainingData(newDataForTraining: self.newDataForTraining)
        self.studentObjectiveClassifier.taggerModelUpdated()
        self.newDataForTraining = []
        self.mustHaveTableView.reloadData()
    }
    
    @IBAction func trainButtonPressed(_ sender: Any) {
        let selectedObjective = self.objectivesToDisplay[self.selectedObjectiveIndex]
        self.newDataForTraining.append(selectedObjective)
    }
    
    @IBAction func popUpItemSelected(_ sender: NSPopUpButton) {
        if let teamName = sender.titleOfSelectedItem {
            self.selectedTeamName = teamName
            teamMembersNames = []
            let keys = self.teamObjectivesDict[self.selectedTeamName]?.keys
            keys?.forEach{
                key in
                self.teamMembersNames.append(key)
            }
            clearStudentInfo()
            showTeamMembers(teamName: teamName)
        }
    }
    
    func clearStudentInfo() {
        self.studentName.stringValue = ""
        self.selectedStudent = nil
        self.objectivesToDisplay = []
        mustHaveTableView.deselectAll(nil)
        mustHaveTableView.reloadData()
        taggerTrainingTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mustHaveTableView.dataSource = self
        self.mustHaveTableView.delegate = self
        
        self.taggerTrainingTableView.dataSource = self
        self.taggerTrainingTableView.delegate = self
        
        self.teamMembersView.dataSource = self
        self.teamMembersView.delegate = self
        
        
        self.teamMembersView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        self.mustHaveTableView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        
        // Do any additional setup after loading the view.
        self.mustHaveTableView.register(NSNib(nibNamed: "LearningObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("ObjectiveCellID"))
        
        self.mustHaveTableView.register(NSNib(nibNamed: "ObjectiveClassificationTableCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("ExpertiseCellID"))
        
        self.teamMembersView.register(NSNib(nibNamed: "StudentCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("StudentCellID"))
        
        let studentsData = try? MLDataTable(contentsOf: Bundle.main.url(forResource: "ObjetivosCompletos", withExtension: "csv")!)
        guard let rows = studentsData?.rows else {return}
        
        self.teamsPopUp.removeAllItems()
        
        rows.forEach{
            row in
            
            let teamIndex = row.index(forKey: "Equipe")!
            let studentIndex = row.index(forKey: "Estudante")!
            let descriptionIndex = row.index(forKey: "Descrição")!
            let priorityIndex = row.index(forKey: "Priorização")!
            let expertiseLevelIndex = row.index(forKey: "Nível")!
            
            let teamName = row.values[teamIndex].stringValue!
            let studentName = row.values[studentIndex].stringValue!
            let description = row.values[descriptionIndex].stringValue!
            let studentObjective = StudentLearningObjective(description: description)
            
            studentObjective.level = row.values[expertiseLevelIndex].stringValue!
            studentObjective.priority = row.values[priorityIndex].stringValue!
            
            
            if studentsDict[studentName] != nil {
                studentsDict[studentName]?.addOriginalObjective(objective: studentObjective)
            }else {
                let student = Student()
                student.name = studentName
                student.addOriginalObjective(objective: studentObjective)
                studentsDict[studentName] = student
            }
            
            if teamObjectivesDict[teamName] == nil {
                teamObjectivesDict[teamName] = [:]
                teamObjectivesDict[teamName]?[studentName] = studentsDict[studentName]
                self.teamsPopUp.addItem(withTitle: teamName)
            }else {
                teamObjectivesDict[teamName]?[studentName] = studentsDict[studentName]
            }
        }
        
        self.studentsDict.keys.forEach{
            name in
            self.teamMembersNames.append(name)
        }
        self.selectedTeamName = self.teamsPopUp.title
        showTeamMembers(teamName: selectedTeamName)
    }
    
    func showTeamMembers(teamName: String) {
        self.teamMembersNames = []
        if let names = self.teamObjectivesDict[teamName]?.keys {
            names.forEach{
                name in
                self.teamMembersNames.append(name)
            }
            self.teamMembersView.reloadData()
        }
    }
    
    func displayStudentObjectives(student:Student) {
        self.objectivesToDisplay = []
        let studentObjectives = student.classifiedObjectives
        let keys = studentObjectives.keys
        keys.forEach{
            key in
            if let studentObjectives = studentObjectives[key] {
                studentObjectives.forEach{
                    studentObjective in
                    self.objectivesToDisplay.append(studentObjective)
                }
            }
        }
        self.studentName.stringValue = student.name
        self.mustHaveTableView.reloadData()
    }
    
    func classifyTeamMemberObjectives(name:String) {
        if let student = self.studentsDict[name] {
            self.studentObjectiveClassifier.classifyStudentObjectives(student: student)
        }
    }
    
    func highlightTopics(text: String, tags:[(tag:String, value:String)]) -> NSAttributedString {
        let topicAttributes:[NSAttributedString.Key: Any?] = [.foregroundColor:NSColor.red, .font:NSFont.boldSystemFont(ofSize: 16)]
        let attributedText = NSMutableAttributedString(string: "")
        tags.forEach{tag in
            if tag.tag == "TOPIC" {
                attributedText.append(NSAttributedString(string: " " + tag.value, attributes: topicAttributes as [NSAttributedString.Key : Any]))
            }else if (tag.tag == "NONE" || tag.tag == "ACTION" || tag.tag == "GENERIC_ACTION" || tag.tag == "DEVICE" || tag.tag == "GENERIC_TOPIC") {
                attributedText.append(NSAttributedString(string: " " + tag.value))
            }else {
                attributedText.append(NSAttributedString(string: tag.value))
            }
        }
        return attributedText
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        var frame = self.mustHaveTableView.frame
        frame.size.height = CGFloat((self.objectivesToDisplay.count) * 40)
        self.mustHaveTableView.frame = frame
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (tableView == self.taggerTrainingTableView && self.selectedObjectiveIndex >= 0 && self.objectivesToDisplay.count > 0) {
            let numWords = self.objectivesToDisplay[self.selectedObjectiveIndex].tags.count
            return numWords
        }else if (tableView == self.mustHaveTableView) {
            return self.objectivesToDisplay.count
        }else if (tableView == self.teamMembersView) {
            return self.teamMembersNames.count
        }else {
            return 0
        }
    }
}

extension ViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.mustHaveTableView.selectedRow
        if selectedRow > 0 {
            let myRowView = self.mustHaveTableView.rowView(atRow: selectedRow, makeIfNecessary: false)
            myRowView?.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
            myRowView?.isEmphasized = false
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if (tableView == self.mustHaveTableView) {
            let fakeField = NSTextField()
            let item = self.objectivesToDisplay[row].description + " #" + self.objectivesToDisplay[row].priority + " #" + self.objectivesToDisplay[row].level
            let objectiveDescriptionWidth = CGFloat(382.0)
            
            fakeField.stringValue = item
            // exactly how you get the text out of your data array depends on how you set it up
            
            let yourHeight = fakeField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), objectiveDescriptionWidth, CGFloat(Float.greatestFiniteMagnitude))).height + 10.0
            // yourWidth = the width of your cell as CGFloat.

//            if yourHeight < 40.0 {
//                yourHeight = 40.0
//            }
            return yourHeight
            //            return CGFloat(50)
        }else if (tableView == self.teamMembersView) {
            return CGFloat(110)
        }else {
            return CGFloat(20)
        }
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        if tableView == self.mustHaveTableView {
            print(rowView.fittingSize.height)
        }
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        tableColumn?.headerCell.backgroundColor = NSColor.white
        if (tableView == self.mustHaveTableView) {
            let objective = self.objectivesToDisplay[row]
            var cellIdentifier = ""
            
            if tableColumn == tableView.tableColumns[0] {
                cellIdentifier = "ObjectiveCellID"
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  LearningObjectiveCellView {
                    cell.fitForObjective(objective: objective)
                    return cell
                }
            }else if tableColumn == tableView.tableColumns[1] {
                cellIdentifier = "ExpertiseCellID"                
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  ObjectiveClassificationTableViewCell {
                    cell.displayLearningObjectiveInfo(objective: objective)
                    return cell
                }
            }
        }else if (tableView == self.taggerTrainingTableView) {
            if (tableColumn == tableView.tableColumns[0]) {
                let cellIdentifier = "TokenCellID"
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? NSTableCellView  {
                    if (self.selectedObjectiveIndex >= 0) {
                        cell.textField?.stringValue = self.objectivesToDisplay[self.selectedObjectiveIndex].tags[row].value
                    }else {
                        cell.textField?.stringValue = ""
                    }
                    return cell
                }
            }else if (tableColumn == tableView.tableColumns[1]) {
                let cellIdentifier = "TagCellID"
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? NSTableCellView  {
                    if (self.selectedObjectiveIndex >= 0) {
                        cell.textField?.stringValue = self.objectivesToDisplay[self.selectedObjectiveIndex].tags[row].tag
                    }else {
                        cell.textField?.stringValue = ""
                    }
                    return cell
                }
            }
        }else if (tableView == self.teamMembersView) {
            let cellIdentifier = "StudentCellID"
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? StudentCellView  {
                let cellStudent = self.studentsDict[self.teamMembersNames[row]]!
                self.classifyTeamMemberObjectives(name: self.teamMembersNames[row])
                
                if let selectedStudent = self.selectedStudent {
                    if selectedStudent.name == cellStudent.name {
                        cell.displaySelectedStudent(student: selectedStudent)
                    }else {
                        cell.displayStudent(student: cellStudent)
                    }
                }else {
                    cell.displayStudent(student: cellStudent)
                }
                return cell
            }
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if (tableView == self.mustHaveTableView) {
            if let _ = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ObjectiveCellID"), owner: nil) as?  NSTableCellView {
                self.selectedObjectiveIndex = row
                self.mustHaveTableView.reloadData()
                self.taggerTrainingTableView.reloadData()
                return true
            }else {
                return false
            }
        }else if (tableView == self.teamMembersView) {
            self.selectedStudent = self.studentsDict[teamMembersNames[row]]
            self.studentName.stringValue = self.selectedStudent!.name
            self.studentObjectiveClassifier.classifyStudentObjectives(student: self.selectedStudent!)
            self.selectedObjectiveIndex = 0
            self.displayStudentObjectives(student: selectedStudent!)
            self.mustHaveTableView.deselectAll(nil)
            self.mustHaveTableView.reloadData()
            self.teamMembersView.reloadData()
            self.taggerTrainingTableView.reloadData()
            return true
        }else if (tableView == self.taggerTrainingTableView) {
            return true
        }else {
            return false
        }
    }
    
    func displayObjectives(selectedStudent:StudentLearningObjective) {
        
    }
}

