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

class ElementToDisplay {
    let title:String?
    let subtitle:String?
    let objective:StudentLearningObjective?
    
    init(title:String?, subtitle:String?, objective: StudentLearningObjective?) {
        self.title = title
        self.subtitle = subtitle
        self.objective = objective
    }
}

class ViewController: NSViewController {
    
    @IBOutlet var windowView: NSView!
    @IBOutlet weak var extraFeaturesBtn: NSButton!
    @IBOutlet weak var trainButton: NSButton!
    @IBOutlet weak var taggerTrainingTableView: NSTableView!
    @IBOutlet weak var studentName: NSTextFieldCell!
    @IBOutlet weak var teamMembersView: NSTableView!
    @IBOutlet weak var teamsPopUp: NSPopUpButton!
    @IBOutlet weak var saveTrainingButton: NSButton!
    
    @IBOutlet weak var mustHaveTableView: NSTableView!
    @IBOutlet weak var programmingScrollView: NSScrollView!
    var programmingScrollViewHeight:CGFloat = 0.0
    
    var teamObjectivesDict:[String:[String:Student]] = [:]
    
//    var studentsDict:Dictionary = [String:Student]()
    var objectivesToDisplay:[StudentLearningObjective] = []
    
    var selectedObjectiveIndex = -1
    var teamMembersNames:[String] = []
//    var selectedStudent:Student?
    
//    var selectedTeamName = ""
    
    var newDataForTraining:[StudentLearningObjective] = []
    
//    let studentObjectiveClassifier = StudentObjectiveClassifier()
    @IBOutlet weak var designScrollView: NSScrollView!
    @IBOutlet weak var designObjectivesTableView: NSTableView!
    var designScrollViewHeight:CGFloat = 0.0
    
    @IBOutlet weak var innovationScrollView: NSScrollView!
    @IBOutlet weak var innovationObjectivesTableView: NSTableView!
    var innovationScrollViewHeight:CGFloat = 0.0
    
    var elementsToDisplay:[ElementToDisplay] = []
    
    
    var cblSprint:CBLSprint!
//    let trainingFileURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesClassifierTraining.csv")
    
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
//        self.studentObjectiveClassifier.taggerModelUpdated()
        self.newDataForTraining = []
        self.mustHaveTableView.reloadData()
    }
    
    @IBAction func trainButtonPressed(_ sender: Any) {
//        let selectedObjective = self.objectivesToDisplay[self.selectedObjectiveIndex]
//        self.newDataForTraining.append(selectedObjective)
//        self.studentObjectiveClassifier.trainClassifier()
    }
    
    @IBAction func popUpItemSelected(_ sender: NSPopUpButton) {
        if let teamName = sender.titleOfSelectedItem {
            self.cblSprint.selectedTeam = self.cblSprint.teamWithName(name: teamName)
            teamMembersNames = []
            clearStudentInfo()
            self.cblSprint.selectedTeam = self.cblSprint.teamWithName(name: teamName)
            showTeamMembers()
        }
    }
    
    func clearStudentInfo() {
        self.studentName.stringValue = ""
//        self.selectedStudent = nil
        self.cblSprint.selectedStudent = nil
        self.objectivesToDisplay = []
        mustHaveTableView.deselectAll(nil)
        mustHaveTableView.reloadData()
        taggerTrainingTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let delegate = NSApplication.shared.delegate as! AppDelegate
        self.cblSprint = delegate.cblSprint 
        
        self.mustHaveTableView.dataSource = self
        self.mustHaveTableView.delegate = self
        self.mustHaveTableView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        self.mustHaveTableView.register(NSNib(nibNamed: "LearningObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("ObjectiveCellID"))
        self.mustHaveTableView.register(NSNib(nibNamed: "SubtitleTableCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("SubtitleCellID"))
        
        self.taggerTrainingTableView.dataSource = self
        self.taggerTrainingTableView.delegate = self
        
        self.teamsPopUp.removeAllItems()
        
        let teamsNames = self.cblSprint.teamsName()
        teamsNames.forEach{
            name in
            self.teamsPopUp.addItem(withTitle: name)
        }
        
        self.cblSprint.studentsDict.keys.forEach{
            name in
            self.teamMembersNames.append(name)
        }
        
        self.cblSprint.selectedTeam = self.cblSprint.teamWithName(name: self.teamsPopUp.title)
        self.teamMembersView.dataSource = self
        self.teamMembersView.delegate = self
        self.teamMembersView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        self.teamMembersView.register(NSNib(nibNamed: "StudentCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("StudentCellID"))

        showTeamMembers()
    }
    
    func showTeamMembers() {
        self.teamMembersView.reloadData()
    }
    
    func displayStudentObjectives(student:Student) {
        self.elementsToDisplay = []
        
        let innovationSubtitle = ElementToDisplay(title: nil, subtitle: "Inovação", objective: nil)
        self.elementsToDisplay.append(innovationSubtitle)
        
        if let innovationObjectives = student.classifiedObjectives["innovation"] {
            innovationObjectives.forEach{
                objective in
                let objectiveElement = ElementToDisplay(title: nil, subtitle: nil, objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        let programmingSubtitle = ElementToDisplay(title: nil, subtitle: "Programação", objective: nil)
        self.elementsToDisplay.append(programmingSubtitle)
        
        if let programmingObjectives = student.classifiedObjectives["programming"] {
            programmingObjectives.forEach{
                objective in
                let objectiveElement = ElementToDisplay(title: nil, subtitle: nil, objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        let designSubtitle = ElementToDisplay(title: nil, subtitle: "Design", objective: nil)
        self.elementsToDisplay.append(designSubtitle)
        
        if let designObjectives = student.classifiedObjectives["design"] {
            designObjectives.forEach{
                objective in
                let objectiveElement = ElementToDisplay(title: nil, subtitle: nil, objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        let successSkillsSubtitle = ElementToDisplay(title: nil, subtitle: "Competências de Sucesso", objective: nil)
        self.elementsToDisplay.append(successSkillsSubtitle)
        
        if let successSkillsObjectives = student.classifiedObjectives["success skills"] {
            successSkillsObjectives.forEach{
                objective in
                let objectiveElement = ElementToDisplay(title: nil, subtitle: nil, objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        let appdevSubtitle = ElementToDisplay(title: nil, subtitle: "App Dev", objective: nil)
        self.elementsToDisplay.append(appdevSubtitle)
        
        if let appdevObjectives = student.classifiedObjectives["appdev"] {
            appdevObjectives.forEach{
                objective in
                let objectiveElement = ElementToDisplay(title: nil, subtitle: nil, objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        self.studentName.stringValue = student.name
        
        self.mustHaveTableView.deselectAll(nil)
        self.programmingScrollViewHeight = 65.0
        self.mustHaveTableView.reloadData()
        var newProgrammingFrame = self.programmingScrollView.frame
        newProgrammingFrame.size.height = self.programmingScrollViewHeight
        self.programmingScrollView.frame = newProgrammingFrame
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
    
    @IBAction func showExtraFeaturesPressed(_ sender: Any) {
//        self.studentObjectiveClassifier.trainClassifier()
        self.cblSprint.studentObjectiveClassifier.trainClassifier()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (tableView == self.taggerTrainingTableView && self.selectedObjectiveIndex >= 0 && self.objectivesToDisplay.count > 0) {
            let numWords = self.objectivesToDisplay[self.selectedObjectiveIndex].tags.count
            return numWords
        }else if (tableView == self.mustHaveTableView) {
            guard self.cblSprint.selectedStudent != nil else {
                return 0
            }
            return self.elementsToDisplay.count
        }else if (tableView == self.teamMembersView) {
            return (self.cblSprint.selectedTeam!.membersNames().count)
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
            if let objective = elementsToDisplay[row].objective {
                let fakeField = NSTextField()
                let item = objective.description + " #" + objective.priority + " #" + objective.level + " #" + objective.topic
                let objectiveDescriptionWidth = CGFloat(594.0)
                
                fakeField.stringValue = item
                // exactly how you get the text out of your data array depends on how you set it up
                
                let yourHeight = fakeField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), objectiveDescriptionWidth, CGFloat(Float.greatestFiniteMagnitude))).height + 5.0
                
                self.programmingScrollViewHeight = self.programmingScrollViewHeight + yourHeight
                return yourHeight
            }else {
                return CGFloat(40.0)
            }
        }else if (tableView == self.teamMembersView) {
            return CGFloat(110)
        }else {
            return CGFloat(20)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        tableColumn?.headerCell.backgroundColor = NSColor.white
        if (tableView == self.mustHaveTableView) {
            var cellIdentifier = ""
            
            if tableColumn == tableView.tableColumns[0] {
                if let objective = self.elementsToDisplay[row].objective {
                    cellIdentifier = "ObjectiveCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  LearningObjectiveCellView {
                        cell.fitForObjective(objective: objective)
                        return cell
                    }
                }else if let subtitle = elementsToDisplay[row].subtitle {
                    cellIdentifier = "SubtitleCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  SubtitleTableCellView {
                        cell.subtitle.stringValue = subtitle
                        return cell
                    }
                }
            }
        }else if (tableView == self.designObjectivesTableView) {
            let objective = self.cblSprint.selectedStudent?.classifiedObjectives["design"]![row]
            var cellIdentifier = ""
            
            if tableColumn == tableView.tableColumns[0] {
                cellIdentifier = "ObjectiveCellID"
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  LearningObjectiveCellView {
                    cell.fitForObjective(objective: objective!)
                    return cell
                }
            }
        }else if (tableView == self.innovationObjectivesTableView) {
            let objective = self.cblSprint.selectedStudent?.classifiedObjectives["innovation"]![row]
            var cellIdentifier = ""
            
            if tableColumn == tableView.tableColumns[0] {
                cellIdentifier = "ObjectiveCellID"
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  LearningObjectiveCellView {
                    cell.fitForObjective(objective: objective!)
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
                let teamMembersNames = self.cblSprint.selectedTeam?.membersNames()
                let cellStudent = self.cblSprint.studentsDict[(teamMembersNames?[row])!]!
                if let selectedStudent = self.cblSprint.selectedStudent {
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
                
//                self.mustHaveTableView.reloadData()
//                self.taggerTrainingTableView.reloadData()
                let delegate = NSApplication.shared.delegate as! AppDelegate
                delegate.selectedObjective = (self.cblSprint.selectedStudent!, self.elementsToDisplay[row].objective!)
                return true
            }else {
                return false
            }
        }else if (tableView == self.teamMembersView) {
            self.cblSprint.selectedStudent = self.cblSprint.studentsDict[(self.cblSprint.selectedTeam?.membersNames()[row])!]
            self.studentName.stringValue = self.cblSprint.selectedStudent!.name
//            self.studentObjectiveClassifier.classifyStudentObjectives(student: self.selectedStudent!)
            self.displayStudentObjectives(student: self.cblSprint.selectedStudent!)
            self.teamMembersView.reloadData()
            self.taggerTrainingTableView.reloadData()
            return true
        }else if (tableView == self.taggerTrainingTableView) {
            return true
        }else {
            return false
        }
    }
}

