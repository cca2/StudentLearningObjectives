//
//  CBLSprint.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 07/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import CreateML
import CloudKit
import Cocoa

class CBLSprint {
    
    var id: String?
    var name:String?
    var teams:Dictionary = [String:Team]()
    var studentsDict:Dictionary = [String:Student]()
    
    var studentsByID:[String: Student]?
    var teamsByID = [String:Team]()
    var learningObjectiveByID = [String: StudentLearningObjective]()
//    var learningObjectivesByStudentID = [String: [StudentLearningObjective]]()
    var learningObjectivesByStudentID = [String: [String:StudentLearningObjective]]()
    
    var selectedTeam:Team?
    var selectedStudent: Student?
    let studentObjectiveClassifier = StudentObjectiveClassifier()
    
    let appDelegate = NSApplication.shared.delegate as! AppDelegate

    init(name: String) {
        self.name = name
        self.id = "F2DA7D69-F4D0-FFB6-9223-051BE4DCC96B"
    }
    
    init(sprintRecord: CKRecord) {
        self.name = sprintRecord["name"]
        self.id = sprintRecord.recordID.recordName
        self.appDelegate.onObjectiveDescriptionChanged = self.checkObjectiveStatus        
    }
    
    func retrieveSprintInfo(studentsByID:[String: Student], onSuccess success: @escaping () -> Void) -> Void {
        self.studentsByID = studentsByID
        self.retrieveAllTeams {
            self.retrieveStudentSprintRelations {
                print(">>> 10 <<<")
                self.retrieveAllObjectives {
                    print(">>> 20 <<<")
                    success()
                }
//                self.clearObjectivesDatabase {
//                    print(">>> 20 <<<")
//                    success()
//                }
            }
        }
    }
    
    func executeRetrieveObjectivesQuery (queryOperation: CKQueryOperation, onSuccess success: @escaping () -> Void) {
        let defaultContainer = CKContainer.default()
        let database = defaultContainer.privateCloudDatabase
        queryOperation.database = database
        queryOperation.recordFetchedBlock = {
            record in
            let objective = StudentLearningObjective(record: record)
            print("coletou objetivo: \(objective.description)")
            self.learningObjectiveByID[objective.id!] = objective
            if let student = self.studentsByID?[objective.studentID] {
                student.addOriginalObjective(objective: objective)
            }
            if self.learningObjectivesByStudentID[objective.studentID] == nil {
                self.learningObjectivesByStudentID[objective.studentID] = [:]
                self.learningObjectivesByStudentID[objective.studentID]?[objective.id!] = objective
            }else {
                self.learningObjectivesByStudentID[objective.studentID]?[objective.id!] = objective
            }
//            if self.learningObjectivesByStudentID[objective.studentID] == nil {
//                self.learningObjectivesByStudentID[objective.studentID] = []
//                self.learningObjectivesByStudentID[objective.studentID]?.append(objective)
//            }else {
//                self.learningObjectivesByStudentID[objective.studentID]?.append(objective)
//            }
        }
        
        // Assign a completion handler
        queryOperation.queryCompletionBlock = {
            cursor, error in
            guard error==nil else {
                // Handle the error
                return
            }
            if let queryCursor = cursor {
                let queryCursorOperation = CKQueryOperation(cursor: queryCursor)
                self.executeRetrieveObjectivesQuery(queryOperation: queryCursorOperation, onSuccess:success)
            }else {
                //coletou todos os objetivos
                success()
            }
        }
        
        database.add(queryOperation)
    }
    
    func clearObjectivesDatabase(onSuccess success: @escaping () -> Void) -> Void {
        let defaultContainer = CKContainer.default()
        let database = defaultContainer.privateCloudDatabase
//        let sprintRecord = CKRecord(recordType: "CBLSprintRecord", recordID: CKRecord.ID(recordName: self.id!))
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let query = CKQuery(recordType: "StudentLearningObjectiveRecord", predicate: predicate)
        database.perform(query, inZoneWith: nil) {
            record, error in
            
            record?.forEach{
                record in
                database.delete(withRecordID: record.recordID) {
                    recordID, error in
                    print("apaguei registro: \(String(describing: recordID?.recordName))")
                }
            }
        }
        
        let queryStudents = CKQuery(recordType: "StudentRecord", predicate: predicate)
        database.perform(queryStudents, inZoneWith: nil) {
            record, error in
            
            record?.forEach{
                record in
                database.delete(withRecordID: record.recordID) {
                    recordID, error in
                    print("apaguei registro ESTUDANTE: \(String(describing: recordID?.recordName))")
                }
            }
        }

        let queryStudentCourseRelation = CKQuery(recordType: "StudentCourseRelation", predicate: predicate)
        database.perform(queryStudentCourseRelation, inZoneWith: nil) {
            record, error in
            
            record?.forEach{
                record in
                database.delete(withRecordID: record.recordID) {
                    recordID, error in
                    print("apaguei registro REL CURSO: \(String(describing: recordID?.recordName))")
                }
            }
        }
        let queryStudentSprintRelation = CKQuery(recordType: "StudentSprintRelation", predicate: predicate)
        database.perform(queryStudentSprintRelation, inZoneWith: nil) {
            record, error in
            
            record?.forEach{
                record in
                database.delete(withRecordID: record.recordID) {
                    recordID, error in
                    print("apaguei registro REL SPRINT: \(String(describing: recordID?.recordName))")
                }
            }
        }
    }
    
    func retrieveAllObjectives(onSuccess success: @escaping () -> Void) -> Void {
//        let defaultContainer = CKContainer.default()
        let sprintRecord = CKRecord(recordType: "CBLSprintRecord", recordID: CKRecord.ID(recordName: self.id!))
        let reference = CKRecord.Reference(recordID: sprintRecord.recordID, action: .none)
        let predicate = NSPredicate(format: "sprint == %@", reference)
        
        let query = CKQuery(recordType: "StudentLearningObjectiveRecord", predicate: predicate)
        let operation = CKQueryOperation(query: query)

        operation.resultsLimit = 100
        self.executeRetrieveObjectivesQuery(queryOperation: operation, onSuccess: success)
    }
    
    
    //    func retriveAllTeams (_ teams: [Team]?, _ error: Error?) -> Void {
    func retrieveAllTeams(onSuccess success: @escaping () -> Void) -> Void {
        let defaultContainer = CKContainer.default()
        let sprintRecord = CKRecord(recordType: "CBLSprintRecord", recordID: CKRecord.ID(recordName: self.id!))
        let reference = CKRecord.Reference(recordID: sprintRecord.recordID, action: .none)
        let predicate = NSPredicate(format: "sprint == %@", reference)
        let query = CKQuery(recordType: "TeamRecord", predicate: predicate)
        defaultContainer.privateCloudDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print (error?.localizedDescription as Any)
                return
            }
            
            if error == nil {
                records.forEach{record in
                    if let team = Team.fromCKRecord(ckRecord: record) {
                        self.teams[team.name] = team
                        self.teamsByID[team.id!] = team
                        self.appDelegate.topNoteNode.add(CBLNote(course: self.appDelegate.selectedCourse!, sprint: self, team: team))
                    }
                }
                success()
            }
        }
    }
    
    func retrieveStudentSprintRelations(onSuccess success: @escaping () -> Void) -> Void {
        let defaultContainer = CKContainer.default()
        let sprintRecord = CKRecord(recordType: "CBLSprintRecord", recordID: CKRecord.ID(recordName: self.id!))
        let reference = CKRecord.Reference(recordID: sprintRecord.recordID, action: .none)
        let predicate = NSPredicate(format: "sprint == %@", reference)
        let query = CKQuery(recordType: "StudentSprintRelation", predicate: predicate)
        defaultContainer.privateCloudDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print (error?.localizedDescription as Any)
                return
            }
            
            if error == nil {
                records.forEach{record in
//                    if let relat = Team.fromCKRecord(ckRecord: record) {
//                        self.teams[team.name] = team
//                        self.teamsByID[team.id!] = team
//                    }
                    let studentReference = record["student"] as! CKRecord.Reference
                    let teamReference = record["team"] as! CKRecord.Reference
                    let studentID = studentReference.recordID.recordName
                    let teamID = teamReference.recordID.recordName
                    self.teamsByID[teamID]?.addMember(newMember: self.studentsByID![studentID]!)
                }
                success()
            }
        }
    }
    
    func sprint(teamName: String, studentName: String, description: String, level: String, priority: String, status: [Substring]) {
        //Alimentando o dicionário de teams com as informações no CloudKit
//        let studentObjective = StudentLearningObjective(description: description)
//        studentObjective.level = level
//        studentObjective.priority = priority
//        
//        status.forEach{status in
//            if status == "no backlog" {
//                studentObjective.isInBacklog = true
//            }
//            if status == "abandonado" {
//                studentObjective.isAbandoned = true
//            }
//            if status == "experimentando" {
//                studentObjective.isExperimenting = true
//            }
//            if status == "estudando" {
//                studentObjective.isStudying = true
//            }
//            if status == "aplicando no app" {
//                studentObjective.isApplyingInTheSolution = true
//            }
//            if status == "ensinando em workshop" {
//                studentObjective.isTeachingOthers = true
//            }
//        }
//        
////        let defaultContainer = CKContainer.default()
////        let database = defaultContainer.privateCloudDatabase
////        if let recordID = studentObjective.saveToRecord(database: database) {
////            self.studentLearningObjectives[recordID] = studentObjective
////        }
//        
//        if self.studentsDict[studentName] != nil {
//            self.studentsDict[studentName]?.addOriginalObjective(objective: studentObjective)
//        }else {
//            let student = Student()
//            student.name = studentName
//            student.addOriginalObjective(objective: studentObjective)
//            self.studentsDict[studentName] = student
//            let defaultContainer = CKContainer.default()
//            let database = defaultContainer.privateCloudDatabase
//            student.saveToRecord(database: database)
//        }
//        
//        if let team = self.teams[teamName] {
//            team.addMember(newMember: self.studentsDict[studentName]!)
//            if let student = self.studentsDict[studentName] {
//                student.team = team
//            }
//        }else {
//            let team = Team(name: teamName)
//            self.teams[teamName] = team
//        }
    }
    
    func addStudentToBase(student: Student) {
        let defaultContainer = CKContainer.default()
        let database = defaultContainer.privateCloudDatabase
        
        let record = CKRecord(recordType: "StudentRecord")
        record["name"] = student.name
        database.save(record) {
            record, error in
            
            guard let record = record else {
                print(error as Any)
                return
            }
            
            print("record \(record) salvo com sucesso")
        }
    }
    
    func teamWithName(name:String) -> Team? {
        return self.teams[name]
    }
    
    func teamsName() -> [String] {
        return teams.keys.sorted()
    }
    
    func matchStudents(student:Student, objective:StudentLearningObjective) -> [(Student, StudentLearningObjective)] {
        var res = [(Student, StudentLearningObjective)]()
        let studentsIDs = self.studentsByID?.keys.sorted()
        studentsIDs?.forEach{
            id in
            if id != student.id {
                let s = self.studentsByID?[id]!
                let objectives:[StudentLearningObjective] = ((s?.objectivesByTopic(topic: objective.topic, onlyMustHave: true))!)
                objectives.forEach {
                    objective in
                    res.append((s!, objective))
                    print(objective)
                }
            }
        }
        return res
    }
    
    //Esta função verifica as modificações que estão sendo feitas na descrição do objetivo, gerando alertas inteligentes
    func checkObjectiveStatus(selectedObjective:StudentLearningObjective, currentText:String) {
        print(">>> 300 <<<")        
        if currentText == "" {
           //Notifica o usuário que o objetivo será apagado
            NotificationCenter.default.post(name: Notification.Name("didErasedObjectiveDescription"), object: selectedObjective, userInfo: nil)
        }else {
            NotificationCenter.default.post(name: Notification.Name("clearMessages"), object:selectedObjective, userInfo: nil)
        }
    }
}

