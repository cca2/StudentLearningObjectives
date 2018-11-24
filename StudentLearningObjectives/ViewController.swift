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
import CoreData
import CloudKit

class NoteElementToDisplay {
    let title:String?
    let subtitle:String?
    let objective:StudentLearningObjective?
    let paragraph: String?
    var isSelected = false
    
    init (title:String?) {
        self.title = title
        self.subtitle = nil
        self.objective = nil
        self.paragraph = nil
    }
    
    init (subtitle:String?) {
        self.title = nil
        self.subtitle = subtitle
        self.objective = nil
        self.paragraph = nil
    }

    init (objective:StudentLearningObjective?) {
        self.title = nil
        self.subtitle = nil
        self.objective = objective
        self.paragraph = nil
    }
    
    init (paragraph:String?) {
        self.title = nil
        self.subtitle = nil
        self.objective = nil
        self.paragraph = paragraph
    }
}

class SnippetToDisplay {
    var isSelected:Bool = false
    var team:Team?
    var student:Student?
    
    init(team: Team) {
        self.team = team
    }
    
    init(student: Student) {
        self.student = student
    }
}

// Data model
struct Challenge {
    var name:String
    var teams: [String]
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
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var mustHaveTableView: NSTableView!
    @IBOutlet weak var programmingScrollView: NSScrollView!
    var programmingScrollViewHeight:CGFloat = 0.0
    
    var teamObjectivesDict:[String:[String:Student]] = [:]
    
    var objectivesToDisplay:[StudentLearningObjective] = []
    
    var selectedObjectiveIndex = -1
    var teamMembersNames:[String] = []
    
    var newDataForTraining:[StudentLearningObjective] = []
    
    var elementsToDisplay:[NoteElementToDisplay] = []
    var snippetsToDisplay:[SnippetToDisplay] = []
    
    var cblSprint:CBLSprint!

    // I assume you know how load it from a plist so I will skip
    // that code and use a constant for simplicity
//    let sprint = Challenge(name: "Challenge 4", teams: ["7 pecados", "pulsai"])
    var sprint = Challenge(name: "Challenge 4", teams:[String]())
    
    let keys = ["sprints", "teams"]

    //Salva o delegate
    let delegate = NSApplication.shared.delegate as! AppDelegate
    
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
            let delegate = NSApplication.shared.delegate as! AppDelegate
            delegate.selectedTeam = self.cblSprint.selectedTeam
            teamMembersNames = []
            newTeamSelected()
            self.cblSprint.selectedTeam = self.cblSprint.teamWithName(name: teamName)
            showTeamNotes()
        }
    }
    
    func newTeamSelected() {
        self.snippetsToDisplay = []
        let selectedTeam = self.cblSprint.selectedTeam
        let teamSnippet = SnippetToDisplay(team: selectedTeam!)
        self.snippetsToDisplay.append(teamSnippet)
        teamSnippet.isSelected = true
        
        let teamStudents = selectedTeam?.members
        teamStudents?.forEach{
            student in
            let studentSnippet = SnippetToDisplay(student: student.value)
            self.snippetsToDisplay.append(studentSnippet)
        }
        
        self.cblSprint.selectedStudent = nil
        self.objectivesToDisplay = []
//        mustHaveTableView.deselectAll(nil)
//        mustHaveTableView.reloadData()
        self.displayTeamInfo(team: selectedTeam!)

        //        taggerTrainingTableView.reloadData()
    }
    
    func fetchUserRecordID() {
        let defaultContainer = CKContainer.default()
        
        //Fetch User Record
        defaultContainer.fetchUserRecordID{
            (recordID, error) -> Void in
            if let responseError = error {
                print(responseError)
            }else if let userRecordID = recordID {
                DispatchQueue.main.sync {
                    self.fetchUserRecord(recordID: userRecordID)
                }
            }
        }
    }
    
    func fetchUserRecord(recordID: CKRecord.ID) {
        let defaultContainer = CKContainer.default()
        let privateDatabase = defaultContainer.privateCloudDatabase
        privateDatabase.fetch(withRecordID: recordID) {
            (record, error) -> Void in
            if let responseError = error {
                print(responseError)
            }else if let userRecord = record {
                print(userRecord)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mustHaveTableView.dataSource = self
        self.mustHaveTableView.delegate = self
        self.mustHaveTableView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        self.mustHaveTableView.register(NSNib(nibNamed: "LearningObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("ObjectiveCellID"))
        self.mustHaveTableView.register(NSNib(nibNamed: "SubtitleTableCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("SubtitleCellID"))
        self.mustHaveTableView.register(NSNib(nibNamed: "SubtitleTableCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("TitleCellID"))
        self.teamMembersView.dataSource = self
        self.teamMembersView.delegate = self
        self.teamMembersView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        self.teamMembersView.register(NSNib(nibNamed: "SnippetCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("SnippetCellID"))

        //Closure quando o curso é selecionado
        self.delegate.onCourseSelected = {
            course in
            print("curso \(course.name) selecionado")
        }
        
        self.delegate.onSprintSelected = {
            sprint in
            print("Sprint \(sprint.name) selecionada")
        }
        
        self.delegate.onSelectedCourseSprintsFetched = {
            self.outlineView.reloadData()
        }

        //Setup da parte de CloudKit da Aplicação
        
        //Setup da parte de Outline da aplicação
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        
        let delegate = NSApplication.shared.delegate as! AppDelegate
        

        
//        self.cblSprint = delegate.selectedSprint
//
//        self.cblSprint.retrieveAllTeams {
//            let teamsNames = self.cblSprint.teamsName()
//            teamsNames.forEach{
//                name in
//                self.sprint.teams.append(name)
//            }
//
//            self.cblSprint.studentsDict.keys.forEach{
//                name in
//                self.teamMembersNames.append(name)
//            }
//
//            self.showTeamNotes()
//
//            self.cblSprint.retrieveAllStudents(onSucess: {
//                let studentsData = self.cblSprint.studentObjectiveClassifier.studentsData
//
//                guard let rows = studentsData?.rows else {return}
//                rows.forEach{
//                    row in
//
//                    let teamIndex = row.index(forKey: "Equipe")!
//                    let studentIndex = row.index(forKey: "Estudante")!
//                    let descriptionIndex = row.index(forKey: "Descrição")!
//                    let priorityIndex = row.index(forKey: "Priorização")!
//                    let expertiseLevelIndex = row.index(forKey: "Nível")!
//                    let statusIndex = row.index(forKey: "Status")!
//
//                    let teamName = row.values[teamIndex].stringValue!
//                    let studentName = row.values[studentIndex].stringValue!
//                    let description = row.values[descriptionIndex].stringValue!
//                    let priority = row.values[priorityIndex].stringValue!
//                    let expertiseLevel = row.values[expertiseLevelIndex].stringValue!
//
//                    let objectiveStatus:[Substring] = row.values[statusIndex].stringValue!.split(separator: Character(","))
//                    self.cblSprint.sprint(teamName: teamName, studentName: studentName, description: description, level: expertiseLevel, priority: priority, status: objectiveStatus)
//                }
//
//                self.cblSprint.studentsDict.keys.forEach{
//                    name in
//                    let student = self.cblSprint.studentsDict[name]
//                    self.cblSprint.studentObjectiveClassifier.classifyStudentObjectives(student: student!)
//                }
//
//                self.cblSprint.retrieveAllObjectives {
//                    print(">>> 0 <<<")
//                }
//
//            })
//        }
    }
    
    func showTeamNotes() {
        self.teamMembersView.reloadData()
    }
    
    func displayTeamInfo(team:Team) {
        self.mustHaveTableView.deselectAll(nil)
        self.elementsToDisplay = []
        self.elementsToDisplay.append(NoteElementToDisplay(title: team.name))
        self.elementsToDisplay.append(NoteElementToDisplay(subtitle: "Big Idea"))
        self.elementsToDisplay.append(NoteElementToDisplay(paragraph: team.bigIdea))
        self.elementsToDisplay.append(NoteElementToDisplay(subtitle: "Essential Question"))
        self.elementsToDisplay.append(NoteElementToDisplay(paragraph: team.essentialQuestion))
        self.elementsToDisplay.append(NoteElementToDisplay(subtitle: "Challenge"))
        self.elementsToDisplay.append(NoteElementToDisplay(paragraph: team.challenge))
        self.elementsToDisplay.append(NoteElementToDisplay(subtitle: "Concept"))
        self.elementsToDisplay.append(NoteElementToDisplay(paragraph: team.concept))

        self.mustHaveTableView.reloadData()
    }
    
    func displayStudentObjectives(student:Student) {
        self.elementsToDisplay = []
        
        let studentName = NoteElementToDisplay(title: self.cblSprint.selectedStudent?.name)
        self.elementsToDisplay.append(studentName)
        
        let innovationSubtitle = NoteElementToDisplay(subtitle: "Inovação")
        self.elementsToDisplay.append(innovationSubtitle)
        
        if let innovationObjectives = student.classifiedObjectives["innovation"] {
            innovationObjectives.forEach{
                objective in
                let objectiveElement = NoteElementToDisplay(objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        let programmingSubtitle = NoteElementToDisplay(subtitle: "Programação")
        self.elementsToDisplay.append(programmingSubtitle)
        
        if let programmingObjectives = student.classifiedObjectives["programming"] {
            programmingObjectives.forEach{
                objective in
                let objectiveElement = NoteElementToDisplay(objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        let designSubtitle = NoteElementToDisplay(subtitle: "Design")
        self.elementsToDisplay.append(designSubtitle)
        
        if let designObjectives = student.classifiedObjectives["design"] {
            designObjectives.forEach{
                objective in
                let objectiveElement = NoteElementToDisplay(objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        let successSkillsSubtitle = NoteElementToDisplay(subtitle: "Competências de Sucesso")
        self.elementsToDisplay.append(successSkillsSubtitle)
        
        if let successSkillsObjectives = student.classifiedObjectives["success skills"] {
            successSkillsObjectives.forEach{
                objective in
                let objectiveElement = NoteElementToDisplay(objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
        let appdevSubtitle = NoteElementToDisplay(subtitle: "App Dev")
        self.elementsToDisplay.append(appdevSubtitle)
        
        if let appdevObjectives = student.classifiedObjectives["appdev"] {
            appdevObjectives.forEach{
                objective in
                let objectiveElement = NoteElementToDisplay(objective: objective)
                self.elementsToDisplay.append(objectiveElement)
            }
        }
        
//        self.studentName.stringValue = student.name
        
        self.mustHaveTableView.deselectAll(nil)
        self.mustHaveTableView.reloadData()
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
            return self.elementsToDisplay.count
        }else if (tableView == self.teamMembersView) {
            return self.snippetsToDisplay.count
        }else {
            return 0
        }
    }
}

extension ViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        let notesSelectedRow = self.mustHaveTableView.selectedRow
        if notesSelectedRow > 0 {
            let myRowView = self.mustHaveTableView.rowView(atRow: notesSelectedRow, makeIfNecessary: false)
            myRowView?.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
            myRowView?.isEmphasized = false
        }
        let outlineSelectedRow = self.outlineView.selectedRow
        if outlineSelectedRow > 0 {
            let myRowView = self.outlineView.rowView(atRow: outlineSelectedRow, makeIfNecessary: false)
            myRowView?.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
            myRowView?.isEmphasized = false
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if (tableView == self.mustHaveTableView) {
            if let objective = elementsToDisplay[row].objective {
//                let fakeField = NSTextField()
//                let item = objective.description + " #" + objective.priority + " #" + objective.level + " #" + objective.topic
//                let objectiveDescriptionWidth = CGFloat(540.0)
//
//                fakeField.stringValue = item
//                // exactly how you get the text out of your data array depends on how you set it up
//
//                let yourHeight = fakeField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), objectiveDescriptionWidth, CGFloat(Float.greatestFiniteMagnitude))).height + 10.0
//
//                self.programmingScrollViewHeight = self.programmingScrollViewHeight + yourHeight
//                return yourHeight
                
                let yourHeight = CGFloat(154.0)
                return yourHeight
            }else if let title = elementsToDisplay[row].title {
                return CGFloat(40.0)
            }else if let subtitle = elementsToDisplay[row].subtitle {
                return CGFloat(40.0)
            }else if let paragraph = elementsToDisplay[row].paragraph {
                let fakeField = NSTextField()
                let item = paragraph.description
                fakeField.stringValue = item
                
                let paragraphDescriptionWidth = CGFloat(540.0)                
                let yourHeight = fakeField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), paragraphDescriptionWidth, CGFloat(Float.greatestFiniteMagnitude))).height + 10.0
                
                return yourHeight
            }else {
                return CGFloat(40.0)
            }
        }else if (tableView == self.teamMembersView) {
            if snippetsToDisplay[row].student != nil {
                return CGFloat(110)
            }else {
                let fakeField = NSTextField()
                if let team = snippetsToDisplay[row].team {
                    let item = team.name
                    fakeField.stringValue = item
                    let snippetsViewWidth = CGFloat(160.0)
                    let yourHeight = fakeField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), snippetsViewWidth, CGFloat(Float.greatestFiniteMagnitude))).height + 10.0 + 20.0
                    
                    return yourHeight
                }
                return CGFloat(40)
            }
            
        }else {
            return CGFloat(20)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        tableColumn?.headerCell.backgroundColor = NSColor.white
        if (tableView == self.mustHaveTableView) {
            var cellIdentifier = ""
            
            if tableColumn == tableView.tableColumns[0] {
                if elementsToDisplay[row].objective != nil {
//                    cellIdentifier = "ObjectiveCellID"
                    cellIdentifier = "ObjectiveCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  LearningObjectiveCellView {
                        cell.fitForObjective(elementToDisplay: elementsToDisplay[row])
                        return cell
                    }
                }else if let title = elementsToDisplay[row].title {
                    cellIdentifier = "TitleCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  TitleTableCellView {
                        cell.title.stringValue = title
                        return cell
                    }
                }else if let subtitle = elementsToDisplay[row].subtitle {
                    cellIdentifier = "SubtitleCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  SubtitleTableCellView {
                        cell.subtitle.stringValue = subtitle
                        return cell
                    }
                }else if elementsToDisplay[row].paragraph != nil {
                    cellIdentifier = "ParagraphCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  ParagraphCellView {
                        cell.fitForParagraph(elementToDisplay: elementsToDisplay[row])
                        return cell
                    }
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
            let cellIdentifier = "SnippetCellID"
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? SnippetCellView  {
                if let team = snippetsToDisplay[row].team {
                    if snippetsToDisplay[row].isSelected {
                        cell.displaySelectedTeamSnippet(team: team)
                    }else {
                        cell.displayTeamSnippet(team: team)
                    }
                }else if let student = self.snippetsToDisplay[row].student {
                    if self.snippetsToDisplay[row].isSelected {
                        cell.displaySelectedStudent(student: student)
                    }else {
                        cell.displayStudent(student: student)
                    }
                }
                return cell
            }
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if (tableView == self.mustHaveTableView) {
            if let _ = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ObjectiveCellID"), owner: nil) as?  NSTableCellView {
                let delegate = NSApplication.shared.delegate as! AppDelegate
                if let selectedObjective = self.elementsToDisplay[row].objective {
                    delegate.selectedObjective = (self.cblSprint.selectedStudent!, selectedObjective)
                    self.elementsToDisplay.forEach{
                        element in
                        element.isSelected = false
                    }
                    self.elementsToDisplay[row].isSelected = true
                    self.mustHaveTableView.reloadData()
                }else {
                    self.elementsToDisplay[row].isSelected = false
                }
                return true
            }else {
                return false
            }
        }else if (tableView == self.teamMembersView) {
            let delegate = NSApplication.shared.delegate as! AppDelegate
            self.snippetsToDisplay.forEach{
                snippet in
                snippet.isSelected = false
            }
            self.snippetsToDisplay[row].isSelected = true
            
            if let selectedTeam = self.snippetsToDisplay[row].team {
                self.displayTeamInfo(team: selectedTeam)
            }else if let selectedStudent = self.snippetsToDisplay[row].student {
                self.cblSprint.selectedStudent = selectedStudent
                delegate.selectedStudent = selectedStudent
                self.displayStudentObjectives(student: selectedStudent)
            }
            self.teamMembersView.reloadData()
            return true
        }else if (tableView == self.taggerTrainingTableView) {
            return true
        }else {
            return false
        }
    }
}

extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    // You must give each row a unique identifier, referred to as `item` by the outline view
    //   * For top-level rows, we use the values in the `keys` array
    //   * For the hobbies sub-rows, we label them as ("hobbies", 0), ("hobbies", 1), ...
    //     The integer is the index in the hobbies array
    //
    // item == nil means it's the "root" row of the outline view, which is not visible
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return keys[index]
        } else if let item = item as? String, item == "teams" {
            return ("teams", index)
        } else if let item = item as? String, item == "sprints" {
            return ("sprints", index)
        } else {
            return 0
        }
    }
    
    // Tell how many children each row has:
    //    * The root row has 5 children: name, age, birthPlace, birthDate, hobbies
    //    * The hobbies row has how ever many hobbies there are
    //    * The other rows have no children
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return keys.count
        } else if let item = item as? String, item == "teams" {
            return sprint.teams.count
        } else if let item = item as? String, item == "sprints" {
            return (delegate.selectedCourse?.sprints.count)!
        }else {
            return 0
        }
    }
    
    // Tell whether the row is expandable. The only expandable row is the Hobbies row
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? String, item == "teams" {
            return true
        }else if let item = item as? String, item == "sprints"{
            return true
        } else {
            return false
        }
    }
    
    // Set the text for each row
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier.rawValue else {
            return nil
        }
        
        var text = ""
        
        // Recall that `item` is the row identiffier
        switch (columnIdentifier, item) {
        case ("KeyColumn", let item as String):
            switch item {
//            case "name":
//                text = "Name"
//            case "age":
//                text = "Age"
//            case "birthPlace":
//                text = "Birth Place"
//            case "birthDate":
//                text = "Birth Date"
            case "sprints":
                text = "Sprints"
            case "teams":
                text = "Challenge 4"
            default:
                break
            }
        case ("KeyColumn", _):
            // Remember that we identified the hobby sub-rows differently
            if let (key, index) = item as? (String, Int), key == "teams" {
                text = self.sprint.teams[index]
            }else if let (key, index) = item as? (String, Int), key == "sprints" {
                text = (delegate.selectedCourse?.sprints[index].name)!
            }
//        case ("ValueColumn", let item as String):
//            switch item {
//            case "name":
//                text = sprint.name
//            case "age":
//                text = "\(person.age)"
//            case "birthPlace":
//                text = person.birthPlace
//            case "birthDate":
//                text = "\(person.birthDate)"
//            default:
//                break
//            }
        default:
            text = ""
        }
        
        let cellIdentifier = NSUserInterfaceItemIdentifier("OutlineViewCell")
        let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        cell.textField!.stringValue = text
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let (_, index) = item as? (String, Int) {
            let teamName = self.sprint.teams[index]
            self.cblSprint.selectedTeam = self.cblSprint.teamWithName(name: teamName)
            let delegate = NSApplication.shared.delegate as! AppDelegate
            delegate.selectedTeam = self.cblSprint.selectedTeam
            
            newTeamSelected()
            self.cblSprint.selectedTeam = self.cblSprint.teamWithName(name: teamName)
            showTeamNotes()
        }
        return true
    }    
}
