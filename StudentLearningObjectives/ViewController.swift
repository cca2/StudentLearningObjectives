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
    let team:Team?
    let title:String?
    let subtitle:String?
    let objective:StudentLearningObjective?
    var paragraph: String?
    var isSelected = false
    var showObjectiveStatus = false
        
    var teamInfoModified:Team.InfoTypes?
    
    init (team:Team, infoType:Team.InfoTypes) {
        self.team = team
        self.title = nil
        self.subtitle = nil
        self.objective = nil
        
        if infoType == Team.InfoTypes.BigIdea {
            self.paragraph = team.bigIdea
        }else if infoType == Team.InfoTypes.EssentialQuestion {
            self.paragraph = team.essentialQuestion
        }else if infoType == Team.InfoTypes.Challenge {
            self.paragraph = team.challenge
        }else if infoType == Team.InfoTypes.Concept {
            self.paragraph = team.concept
        }else {
            self.paragraph = "TESTANDO"
        }
        self.teamInfoModified = infoType
    }
    
    init (title:String?) {
        self.title = title
        self.subtitle = nil
        self.objective = nil
        self.paragraph = nil
        self.team = nil
    }
    
    init (subtitle:String?) {
        self.title = nil
        self.subtitle = subtitle
        self.objective = nil
        self.paragraph = nil
        self.team = nil
    }

    init (objective:StudentLearningObjective?) {
        self.title = nil
        self.subtitle = nil
        self.objective = objective
        self.paragraph = nil
        self.team = nil
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
    @IBOutlet weak var clearDatabaseButton: NSButton!
    
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
    @IBOutlet weak var clearDatabase: NSButton!
    @IBOutlet weak var csv2DatabaseButton: NSButton!
    
    @IBAction func saveCSV2Database(_ sender: Any) {        
        print("---- SALVANDO DADOS DO CSV PARA A BASE DE DADOS ----")
        //Esta parte só deve ser utilizada para se atualizar a partir de um
        //arquivo csv gerado do airtable a base de dados do cloudkit
        let sprint = self.appDelegate.selectedSprint!
        let courseReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: (self.appDelegate.selectedCourse?.id)!), action: .none)
        let sprintReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: sprint.id!), action: .none)

        var studentsNames = [String]()
        var studentReferences = [String: CKRecord.Reference]()
        var teamReferences = [String: CKRecord.Reference]()

        if let studentsData = sprint.studentObjectiveClassifier.studentsData {
            let rows = studentsData.rows
            rows.forEach{
                row in

                let teamIndex = row.index(forKey: "Equipe")!
                let studentIndex = row.index(forKey: "Estudante")!
                let descriptionIndex = row.index(forKey: "Descrição")!
                let priorityIndex = row.index(forKey: "Priorização")!
                let expertiseLevelIndex = row.index(forKey: "Nível")!
                let statusIndex = row.index(forKey: "Status")!

                let description = row.values[descriptionIndex].stringValue!
                let priority = row.values[priorityIndex].stringValue!
                let expertiseLevel = row.values[expertiseLevelIndex].stringValue!
                let objectiveStatus:[Substring] = row.values[statusIndex].stringValue!.split(separator: Character(","))

                let teamName = row.values[teamIndex].stringValue!
                let studentName = row.values[studentIndex].stringValue!

                let learningObjectiveRecord = CKRecord(recordType: "StudentLearningObjectiveRecord")
                learningObjectiveRecord["course"] = courseReference
                learningObjectiveRecord["sprint"] = sprintReference
                learningObjectiveRecord["description"] = description
                learningObjectiveRecord["priority"] = priority
                learningObjectiveRecord["level"] = expertiseLevel
                learningObjectiveRecord["priority"] = priority
                learningObjectiveRecord["isInBacklog"] = false
                learningObjectiveRecord["isAbandoned"] = false
                learningObjectiveRecord["isExperimenting"] = false
                learningObjectiveRecord["isStudying"] = false
                learningObjectiveRecord["isApplyingInTheSolution"] = false
                learningObjectiveRecord["isTeachingOthers"] = false

                objectiveStatus.forEach{status in
                    if status == "no backlog" {
                        learningObjectiveRecord["isInBacklog"] = true
                    }
                    if status == "abandonado" {
                        learningObjectiveRecord["isAbandoned"] = true
                    }
                    if status == "experimentando" {
                        learningObjectiveRecord["isExperimenting"] = true
                    }
                    if status == "estudando" {
                        learningObjectiveRecord["isStudying"] = true
                    }
                    if status == "aplicando no app" {
                        learningObjectiveRecord["isApplyingInTheSolution"] = true
                    }
                    if status == "ensinando em workshop" {
                        learningObjectiveRecord["isTeachingOthers"] = true
                    }
                }


                if let reference = studentReferences[studentName] {
                    learningObjectiveRecord["student"] = reference
                }

                if let reference = teamReferences[teamName] {
                    learningObjectiveRecord["team"] = reference
                }

                if studentsNames.contains(studentName) {
                }else {
                    studentsNames.append(studentName)
                    let studentRecord = CKRecord(recordType: "StudentRecord")
                    studentRecord["name"] = studentName

                    var courses:[CKRecord.Reference] = []
                    courses.append(courseReference)
                    studentRecord["courses"] = courses

                    let studentReference = CKRecord.Reference(recordID: studentRecord.recordID, action: .none)
                    studentReferences[studentName] = studentReference

                    learningObjectiveRecord["student"] = studentReference

                    let studentSprintRelation = CKRecord(recordType: "StudentSprintRelation")

                    studentSprintRelation["sprint"] = sprintReference

                    let teamReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: (sprint.teams[teamName]?.id)!), action: .none)
                    teamReferences[teamName] = teamReference

                    learningObjectiveRecord["team"] = teamReference
                    studentSprintRelation["team"] = teamReference
                    studentSprintRelation["student"] = studentReference

                    let studentCourseRelation = CKRecord(recordType: "StudentCourseRelation")
                    studentCourseRelation["student"] = studentReference
                    var sprints:[CKRecord.Reference] = []
                    sprints.append(CKRecord.Reference(recordID: studentSprintRelation.recordID, action: .none))
                    studentCourseRelation["sprints"] = sprints
                    studentCourseRelation["course"] = courseReference

                    self.database.save(studentRecord) {
                        record, error in
                    }

                    self.database.save(studentCourseRelation) {
                        record, error in
                    }

                    self.database.save(studentSprintRelation) {
                        record, error in
                    }
                }

                self.database.save(learningObjectiveRecord) {
                    record, error in
                }
            }
        }
    }
    
    @IBAction func clearDatabase(_ sender: Any) {
        print("---- APAGANDO A BASE DE DADOS ----")
        print("---- APAGANDO A BASE DE ESTUDANTES ----)")
        let defaultContainer = CKContainer.default()
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "StudentRecord", predicate: predicate)
        defaultContainer.privateCloudDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print (error as Any)
                return
            }
            records.forEach{
                record in
                let student = Student(record: record)
                print(student.name)
                defaultContainer.privateCloudDatabase.delete(withRecordID: record.recordID){
                    (recordID, error) -> Void in

                    guard let recordID = recordID else {
                        print("erro ao deletar registro")
                        return
                    }
                    print("registro \(recordID) deletado com sucesso")
                }
            }
            
            print("---- APAGANDO A BASE DE OBJETIVOS ----)")
            
            let query = CKQuery(recordType: "StudentLearningObjectiveRecord", predicate: predicate)
            self.database.perform(query, inZoneWith: nil) {
                record, error in
                
                record?.forEach{
                    record in
                    self.database.delete(withRecordID: record.recordID) {
                        recordID, error in
                        print("apaguei registro: \(String(describing: recordID?.recordName))")
                    }
                }
            }
            
            let queryStudents = CKQuery(recordType: "StudentRecord", predicate: predicate)
            self.database.perform(queryStudents, inZoneWith: nil) {
                record, error in
                
                record?.forEach{
                    record in
                    self.database.delete(withRecordID: record.recordID) {
                        recordID, error in
                        print("apaguei registro ESTUDANTE: \(String(describing: recordID?.recordName))")
                    }
                }
            }
            
            let queryStudentCourseRelation = CKQuery(recordType: "StudentCourseRelation", predicate: predicate)
            self.database.perform(queryStudentCourseRelation, inZoneWith: nil) {
                record, error in
                
                record?.forEach{
                    record in
                    self.database.delete(withRecordID: record.recordID) {
                        recordID, error in
                        print("apaguei registro REL CURSO: \(String(describing: recordID?.recordName))")
                    }
                }
            }
            let queryStudentSprintRelation = CKQuery(recordType: "StudentSprintRelation", predicate: predicate)
            self.database.perform(queryStudentSprintRelation, inZoneWith: nil) {
                record, error in
                
                record?.forEach{
                    record in
                    self.database.delete(withRecordID: record.recordID) {
                        recordID, error in
                        print("apaguei registro REL SPRINT: \(String(describing: recordID?.recordName))")
                    }
                }
            }

        }
    }
    var programmingScrollViewHeight:CGFloat = 0.0
    
    var teamObjectivesDict:[String:[String:Student]] = [:]
    
    var objectivesToDisplay:[StudentLearningObjective] = []
    
    var selectedObjectiveIndex = -1
    var teamMembersNames:[String] = []
    
    var newDataForTraining:[StudentLearningObjective] = []
    
    var elementsToDisplay:[NoteElementToDisplay] = []
    var snippetsToDisplay:[SnippetToDisplay] = []
    
    var cblSprint:CBLSprint!

    var outlineKeys:[String] = []
    
    //Tags que identificam qual texto foi modificado
    var learningObjectivesByModifiedView:[NSTextView:StudentLearningObjective] = [:]
    var teamsInfoByModifiedView:[NSTextView:(Team, Team.InfoTypes)] = [:]
    var lastModifiedObjective:StudentLearningObjective?
    var objectiveBeingEdited:StudentLearningObjective?
    var teamBeingEdited:(Team?, Team.InfoTypes?)?

    //Salva o delegate
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    
    //Database
//    let defaultContainer = CKContainer.default()
    let database = CKContainer.default().privateCloudDatabase

    var respondersChain:[NSView:(NSView?, NSView?)] = [:]
    var objectiveRespondersCellsList:[LearningObjectiveCellView?] = []
    
    var lastResponderInChain: NSTextView?
    
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
        database.fetch(withRecordID: recordID) {
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
        self.mustHaveTableView.register(NSNib(nibNamed: "LearningObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("ParagraphCellID"))
        self.mustHaveTableView.register(NSNib(nibNamed: "SubtitleTableCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("SubtitleCellID"))
        self.mustHaveTableView.register(NSNib(nibNamed: "SubtitleTableCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("TitleCellID"))
        self.teamMembersView.dataSource = self
        self.teamMembersView.delegate = self
        self.teamMembersView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        self.teamMembersView.register(NSNib(nibNamed: "SnippetCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("SnippetCellID"))

        //Closure quando o curso é selecionado
        self.appDelegate.onCourseSelected = {
            course in
            print(">>> BAIXANDO DADOS DOS ESTUDANTES <<<")
            course.retrieveAllStudents {
                self.appDelegate.selectedCourseStudentsFetched()
                print(">>> REGISTRANDO OS ESTUDANTES <<<")
            }
        }

        self.appDelegate.onSelectedCourseStudentsFetched = {
            
        }
        
        self.appDelegate.onSprintSelected = {
            sprint in
            sprint.retrieveSprintInfo(studentsByID: (self.appDelegate.selectedCourse?.studentsByID)!) {
                self.displayMessage(message: "Informações da Sprint \(String(describing: sprint.name))")
                self.outlineKeys = ["sprints", "teams"]
                
                if let studentsDict = self.appDelegate.selectedCourse?.studentsByID {
                    let studentsIDs = studentsDict.keys
                    studentsIDs.forEach{
                        id in
                        let student = studentsDict[id]
                        student?.classifiedObjectives = [:]
                        self.appDelegate.selectedSprint?.studentObjectiveClassifier.classifyStudentObjectives(student: student!)
                    }
                }
                self.elementsToDisplay = []
                self.snippetsToDisplay = []
                self.objectiveRespondersCellsList = []
                DispatchQueue.main.async {
                    self.mustHaveTableView.reloadData()
                    self.outlineView.reloadData()
                    self.teamMembersView.reloadData()
                }
           }
        }
        
        self.appDelegate.onSelectedCourseSprintsFetched = {
            self.outlineKeys = ["sprints"]
            DispatchQueue.main.async {
                self.outlineView.reloadData()
            }
        }
        
        let teamSelectedClosure:((Team) -> ())? = {
            team in
            self.newTeamSelected()
            DispatchQueue.main.async {
                print(">>> 0 <<<")
            }
        }
        
        self.appDelegate.onTeamSelected.append(teamSelectedClosure)

        let studentSelectedClosure:((Student) -> ())? = {
            student in
            //            self.newTeamSelected()
            self.displayStudentObjectives(student: student)
//            DispatchQueue.main.async {
//                print(">>> 100 \(student.name) selecionado <<<")
//            }
        }
        self.appDelegate.onStudentSelected.append(studentSelectedClosure)
        //Setup da parte de CloudKit da Aplicação
        
        //Setup da parte de Outline da aplicação
        self.outlineView.delegate = self
        self.outlineView.dataSource = self

        
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
    
    func newTeamSelected() {
        self.snippetsToDisplay = []
        //        let selectedTeam = self.cblSprint.selectedTeam
        let selectedTeam = self.appDelegate.selectedTeam
        let teamSnippet = SnippetToDisplay(team: selectedTeam!)
        self.snippetsToDisplay.append(teamSnippet)
        teamSnippet.isSelected = true
        
        var studentsSnippets = [SnippetToDisplay]()
        let teamStudents = selectedTeam?.members
        teamStudents?.forEach{
            student in
            let studentSnippet = SnippetToDisplay(student: student.value)
            studentsSnippets.append(studentSnippet)
        }
        
        studentsSnippets = studentsSnippets.sorted(by: {($0.student?.name)! < $1.student!.name})
        
        studentsSnippets.forEach{
            snippet in
            self.snippetsToDisplay.append(snippet)
        }
        
        self.objectivesToDisplay = []
        self.displayTeamInfo(team: selectedTeam!)
        self.teamMembersView.reloadData()
    
//      taggerTrainingTableView.reloadData()
    }
    

    func showTeamNotes() {
        self.teamMembersView.reloadData()
    }
    
    func displayMessage(message: String) {
        DispatchQueue.main.async {
            self.mustHaveTableView.deselectAll(nil)
            self.elementsToDisplay = []
            self.elementsToDisplay.append(NoteElementToDisplay(title: message))
            self.objectiveRespondersCellsList = []
            self.mustHaveTableView.reloadData()
        }
    }
    
    func displayTeamInfo(team:Team) {
        DispatchQueue.main.async {
            self.mustHaveTableView.deselectAll(nil)
            self.elementsToDisplay = []
            self.elementsToDisplay.append(NoteElementToDisplay(title: team.name))
            self.elementsToDisplay.append(NoteElementToDisplay(subtitle: "Big Idea"))
            self.elementsToDisplay.append(NoteElementToDisplay(team: team, infoType: .BigIdea))
            self.elementsToDisplay.append(NoteElementToDisplay(subtitle: "Essential Question"))
            self.elementsToDisplay.append(NoteElementToDisplay(team: team, infoType: .EssentialQuestion))
            self.elementsToDisplay.append(NoteElementToDisplay(subtitle: "Challenge"))
            self.elementsToDisplay.append(NoteElementToDisplay(team: team, infoType: .Challenge))
            self.elementsToDisplay.append(NoteElementToDisplay(subtitle: "Concept"))
            self.elementsToDisplay.append(NoteElementToDisplay(team: team, infoType: .Concept))
            self.objectiveRespondersCellsList = []
            self.mustHaveTableView.reloadData()
        }
    }
    
    func displayStudentObjectives(student:Student) {
        self.elementsToDisplay = []
        
        let studentNameElement = NoteElementToDisplay(title: student.name)
        self.elementsToDisplay.append(studentNameElement)
        
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
        
        
        self.mustHaveTableView.deselectAll(nil)
        self.objectiveRespondersCellsList = []
        self.mustHaveTableView.reloadData()
    }
    
    func row(objective: StudentLearningObjective) -> Int {
        var res = 0
        var index = 0
        self.elementsToDisplay.forEach{element in
            if let elementObjective = element.objective {
                if objective === elementObjective {
                    index = res
                }else {
                    res = res + 1
                }
            }else {
                res = res + 1
            }
        }
        return index
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

extension ViewController: NSTextViewDelegate {
    func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
        let tagsList = textView.string
        
        if !(tagsList.contains("#musthave") || (tagsList.contains("#nicetohave"))) {
           return ["musthave", "nicetohave"]
        }
        
        if !(tagsList.contains("#inbacklog") || (tagsList.contains("#abandonado"))) {
            return ["inbacklog", "abandonado"]
        }
        
        if !(tagsList.contains("#básico") || (tagsList.contains("#senior")) || (tagsList.contains("#expert"))) {
            return ["básico", "senior", "expert"]
        }

        var rCompletions:[String] = []
        if !(tagsList.contains("#estudado")) {
            rCompletions.append("estudado")
        }

        if !((tagsList.contains("#experimentado"))) {
            rCompletions.append("experimentado")
        }

        if !((tagsList.contains("#aplicado"))) {
            rCompletions.append("aplicado")
        }

        if !((tagsList.contains("#ensinado"))) {
            rCompletions.append("ensinado")
        }

        return rCompletions
    }
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSStandardKeyBindingResponding.insertTab(_:)) || commandSelector == #selector(NSStandardKeyBindingResponding.moveDown(_:)){
            textView.moveDown(nil)
            return true
        }else if commandSelector == #selector(NSStandardKeyBindingResponding.moveUp(_:)) {
                textView.moveUp(nil)
            return true
        }else if commandSelector == #selector(insertNewline(_:)){
            print("adicionar um novo objetivo")
            if let objectiveBeingEdited = appDelegate.selectedObjective?.1 {
                let newObjectiveRow = row(objective: objectiveBeingEdited) + 1
                let newObjective = createNewObjectiveAfterCurrentObjective(currentObjective: objectiveBeingEdited)
                appDelegate.selectedObjective = (appDelegate.selectedStudent, newObjective) as? (Student, StudentLearningObjective)
                let newElementToDisplay = NoteElementToDisplay(objective: newObjective)
                elementsToDisplay.insert(newElementToDisplay, at: newObjectiveRow)
                self.mustHaveTableView.beginUpdates()
                self.mustHaveTableView.insertRows(at: [newObjectiveRow], withAnimation: [])
                self.mustHaveTableView.endUpdates()
            }
            //precisa fazer o novo objetivo ser o firstResponder
            //O problema aqui é que a tabela é recarregada apenas na célula que foi alterada
            return true
        }else {
            return false
        }
    }
    
    func createNewObjectiveAfterCurrentObjective(currentObjective: StudentLearningObjective) -> StudentLearningObjective? {
        var res:StudentLearningObjective?
        let courseID = currentObjective.courseID
        let sprintID = currentObjective.sprintID
        let teamID = currentObjective.teamID
        let studentID = currentObjective.studentID
        res = StudentLearningObjective(courseID: courseID!, sprintID: sprintID!, teamID: teamID!, studentID: studentID)
        let student = appDelegate.selectedCourse?.studentsByID[studentID]
        
        student?.addOriginalObjective(objective: res!)
        appDelegate.selectedSprint?.studentObjectiveClassifier.classifyStudentObjectives(student: student!)
        return res
    }
    
    func textDidChange(_ notification: Notification) {
        print("Hello")
        let textView = notification.object as! EditableTextView
        let index = self.mustHaveTableView.row(for: textView)
        if textView is TagsListTextView {
//            let tagsView = textView as! TagsListTextView
            if let objectiveBeingEdited = appDelegate.selectedObjective?.1 {
                self.lastModifiedObjective = objectiveBeingEdited
            }
        }else if textView is LearningObjectiveTextView {
            if let objectiveBeingEdited = appDelegate.selectedObjective?.1 {
                self.lastModifiedObjective = objectiveBeingEdited
                if textView.isObjectiveDescription {
                    objectiveBeingEdited.description = textView.string
                    //Aumentar ou diminuir a altura da NSTextView da descrição do objetivo
//                    let index = row(objective: objectiveBeingEdited)
                    self.mustHaveTableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: index))
                    self.mustHaveTableView.beginUpdates()
                    self.mustHaveTableView.endUpdates()
                }

                //Avisar quando o objetivo for ser apagado
                self.appDelegate.modifiedSelectedObjectiveDescription = textView.string
            }else {
                self.objectiveBeingEdited = nil
            }
        }else if textView is ParagraphTextView {
            elementsToDisplay[index].paragraph? = textView.string
            self.mustHaveTableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: index))
            self.mustHaveTableView.beginUpdates()
            self.mustHaveTableView.endUpdates()
        }
        
        if let teamBeingEdited = self.teamsInfoByModifiedView[textView]?.0 {
            self.teamBeingEdited = (teamBeingEdited, self.teamsInfoByModifiedView[textView]?.1)
        }else {
            self.teamBeingEdited = nil
        }
        
    }

    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        let textView = textView as! EditableTextView
        if textView.isTagsList {
//            let string = textView.string
            if affectedCharRange.length == 0 {
                if (textView.string.contains("#musthave") || textView.string.contains("nicetohave")) && (textView.string.contains("#inbacklog") || textView.string.contains("#abandonado"))
                    &&  (textView.string.contains("#ensinado") && textView.string.contains("estudado") && textView.string.contains("experimentado") && textView.string.contains("aplicado")){
                    return false
                }
                print(">>> 10 <<<")
                if let rString = replacementString {
                    print(">>> 20 <<<")
                    if rString.contains("#") {
                        print(">>> 30 <<<")
                        textView.complete(self)
                        return true
                    }else if rString == " " {
                        print(">>> 40 <<<")
                        return true
                    }else {
                        print(">>> 50 <<<")
                        let completions = ["inbacklog", "abandonado", "musthave", "nicetohave", "básico", "senior", "expert", "estudado", "experimentado", "aplicado", "ensinado"]
                        var replacementValid = false
                        completions.forEach{completion in
                            if rString == completion {
                                print(">>> 60 \(rString) == \(completion) <<<")
                                replacementValid = true
                            }
                        }
                        return replacementValid
                    }
                }
                print(">>> 60 <<<")
                return true
            }else {
                return true
            }
        }
        return true
    }

    func textShouldEndEditing(_ textObject: NSText) -> Bool {
        if self.lastModifiedObjective != nil {
            print("modificando o objetivo")
            if let objective = self.lastModifiedObjective {
                let textView = textObject as! EditableTextView
                if textView.isTagsList {
                    checkObjectiveState(objective: objective, tagsList: textObject.string)
                }else if textView.isObjectiveDescription {
                    objective.description = descriptionWithOutClassificationTags(textWithTags: textObject.string)!
                }
            }
            NotificationCenter.default.post(Notification(name: Notification.Name("didUpdateObjective"), object:self.lastModifiedObjective, userInfo: nil))
        }else if self.teamBeingEdited != nil {
            print("Mofificando team")
            if self.teamBeingEdited?.1 == Team.InfoTypes.BigIdea {
                self.teamBeingEdited!.0?.bigIdea = textObject.string.trimmingCharacters(in: .whitespaces)
            }else if self.teamBeingEdited?.1 == .EssentialQuestion {
                self.teamBeingEdited?.0?.essentialQuestion = textObject.string.trimmingCharacters(in: .whitespaces)
            }else if self.teamBeingEdited?.1 == .Challenge {
                self.teamBeingEdited?.0?.concept = textObject.string.trimmingCharacters(in: .whitespaces)
            }else if self.teamBeingEdited?.1 == .Concept {
                self.teamBeingEdited?.0?.challenge = textObject.string.trimmingCharacters(in: .whitespaces)
            }
            NotificationCenter.default.post(Notification(name: Notification.Name("didUpdateTeam"), object:self.teamBeingEdited?.0, userInfo: nil))
        }
        return true
    }
    
    func checkObjectiveState(objective: StudentLearningObjective, tagsList: String) {
        if tagsList.contains("#inbacklog") {
            objective.isInBacklog = true
        }else {
            objective.isInBacklog = false
        }
        if tagsList.contains("#abandonado") {
            objective.isAbandoned = true
        }else {
            objective.isAbandoned = false
        }
        
        if tagsList.contains("#musthave") {
            objective.priority = "must-have"
        }else if tagsList.contains("#nicetohave"){
            objective.priority = "nice-to-have"
        }
        
        if tagsList.contains("#básico") {
            objective.level = "básico"
        }else if tagsList.contains("#senior") {
            objective.level = "senior"
        }else if tagsList.contains("#expert") {
            objective.level = "expert"
        }
        
        if tagsList.contains("#estudado") {
            objective.isStudying = true
        }else {
            objective.isStudying = false
        }
        if tagsList.contains("#experimentado") {
            objective.isExperimenting = true
        }else {
            objective.isExperimenting = false
        }
        if tagsList.contains("#aplicado") {
            objective.isApplyingInTheSolution = true
        }else {
            objective.isApplyingInTheSolution = false
        }
    }
    
    func descriptionWithOutClassificationTags(textWithTags:String) -> String? {
        let textWithoutTags = textWithTags.split(separator: "#", omittingEmptySubsequences: true).first?.trimmingCharacters(in: .whitespaces)
        return textWithoutTags
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
                let item = objective.description
                let font = NSFont.systemFont(ofSize: 13.0)
                let attributes: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font:font]

                let attributedItem = NSAttributedString(string: item, attributes:attributes)
                let itemHeight = hightForString(attributedString: attributedItem, width: CGFloat(564.0), padding: CGFloat(4.0))
                
                let cellHeight = itemHeight + 20.0
                return cellHeight
            }else if elementsToDisplay[row].title != nil {
                return CGFloat(40.0)
            }else if elementsToDisplay[row].subtitle != nil {
                return CGFloat(40.0)
            }else if let paragraph = elementsToDisplay[row].paragraph {
                let item = NSAttributedString(string: paragraph)
                let yourHeight = hightForString(attributedString: item, width: CGFloat(564.0), padding: CGFloat(4.0))
                return yourHeight
            }else {
                return CGFloat(20.0)
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
    
    func hightForString(attributedString: NSAttributedString, width:CGFloat, padding:CGFloat) -> CGFloat {
        let storage:NSTextStorage = NSTextStorage(attributedString: attributedString)
        let container: NSTextContainer = NSTextContainer(size: NSSize(width: width, height: CGFloat(Float.greatestFiniteMagnitude)))
        
        let layoutManager = NSLayoutManager()
        storage.addLayoutManager(layoutManager)
        container.lineFragmentPadding = padding
        layoutManager.addTextContainer(container)
        layoutManager.glyphRange(for: container)
        let layoutHeight = layoutManager.usedRect(for: container).size.height
        return layoutHeight + 12.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        print(">>> ELEMENT: \(elementsToDisplay)")
        tableColumn?.headerCell.backgroundColor = NSColor.white
        if (tableView == self.mustHaveTableView) {
            var cellIdentifier = ""
            
            if tableColumn == tableView.tableColumns[0] {
                if elementsToDisplay[row].objective != nil {
                    cellIdentifier = "ObjectiveCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  LearningObjectiveCellView {
                        let objective = elementsToDisplay[row].objective
                        cell.descriptionView.learningObjective = elementsToDisplay[row].objective
                        cell.objective = objective
                        cell.descriptionView.delegate = self
                        cell.tagsListView.delegate = self
                        self.objectiveRespondersCellsList.insert(cell, at: row)

                        //Montar a cadeia de responders
                        if row == 0 {
//                            self.objectiveRespondersCellsList.append(cell)
                        }else {
                            if let previousCell = self.objectiveRespondersCellsList[row - 1] {
                                previousCell.tagsListView.moveDownResponder = cell.descriptionView
                                cell.descriptionView.moveUpResponder = previousCell.tagsListView
                            }else {
                                for i in (0...(row - 1)).reversed() {
                                    if let previousCell = self.objectiveRespondersCellsList[i] {
                                        previousCell.tagsListView.moveDownResponder = cell.descriptionView
                                        cell.descriptionView.moveUpResponder = previousCell.tagsListView
                                        break
                                    }
                                }
                            }
                        }
                        if self.objectiveRespondersCellsList.count > (row + 1) {
                            if let nextCell = self.objectiveRespondersCellsList[row + 1] {
                                cell.tagsListView.moveDownResponder = nextCell.descriptionView
                                nextCell.descriptionView.moveUpResponder = cell.tagsListView
                            }
                        }
                        return cell
                    }
                }else if let title = elementsToDisplay[row].title {
                    self.objectiveRespondersCellsList.append(nil)
                    cellIdentifier = "TitleCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  TitleTableCellView {
                        cell.title.stringValue = title
                        return cell
                    }
                }else if let subtitle = elementsToDisplay[row].subtitle {
                    self.objectiveRespondersCellsList.append(nil)
                    cellIdentifier = "SubtitleCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  SubtitleTableCellView {
                        cell.subtitle.stringValue = subtitle
                        return cell
                    }
                }else if elementsToDisplay[row].team != nil {
                    self.objectiveRespondersCellsList.append(nil)
                    cellIdentifier = "ParagraphCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  ParagraphCellView {
                        cell.fitForParagraph(elementToDisplay: elementsToDisplay[row])
                        cell.paragraphTextView.delegate = self
                        self.teamsInfoByModifiedView[cell.paragraphTextView] = (elementsToDisplay[row].team, elementsToDisplay[row].teamInfoModified) as? (Team, Team.InfoTypes)
                        return cell
                    }
                }else {
                    self.objectiveRespondersCellsList.append(nil)
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
            return true
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
                delegate.selectedStudent = selectedStudent
//                self.displayStudentObjectives(student: selectedStudent)
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
            return outlineKeys[index]
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
            return outlineKeys.count
        } else if let item = item as? String, item == "teams" {
            if let teams = appDelegate.selectedSprint?.teams {
                return teams.count
            }
            return 0
        } else if let item = item as? String, item == "courses" {
            return 1
        }else if let item = item as? String, item == "sprints" {
            return (appDelegate.selectedCourse?.sprints.count)!
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
                if let name = self.appDelegate.selectedSprint?.name {
                    text = name
                }
            default:
                break
            }
        case ("KeyColumn", _):
            // Remember that we identified the hobby sub-rows differently
            if let (key, index) = item as? (String, Int), key == "teams" {
                if let teamName = appDelegate.selectedSprint?.teamsName()[index] {
                    text = teamName
                }
            }else if let (key, index) = item as? (String, Int), key == "sprints" {
                text = (appDelegate.selectedCourse?.sprints[index].name)!
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
        if let (columnIdentifier, index) = item as? (String, Int) {
            if columnIdentifier == "sprints" {
                if let selectedSprint = self.appDelegate.selectedCourse?.sprints[index] {
                    self.appDelegate.selectedSprint = selectedSprint
                }
            } else if columnIdentifier == "teams" {
                if let teamName = self.appDelegate.selectedSprint?.teamsName()[index] {
//                    self.cblSprint.selectedTeam = self.cblSprint.teamWithName(name: teamName)
                    appDelegate.selectedTeam = self.appDelegate.selectedSprint?.teamWithName(name: teamName)
//                    newTeamSelected()
//                    self.cblSprint.selectedTeam = self.cblSprint.teamWithName(name: teamName)
//                    showTeamNotes()
                }
            }
        }
        return true
    }    
}

