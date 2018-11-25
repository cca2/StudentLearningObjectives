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

class CBLSprint {
    var id: String?
    var name:String?
    var teams:Dictionary = [String:Team]()
    var studentsDict:Dictionary = [String:Student]()
    var studentLearningObjectives = [String: StudentLearningObjective]()
    
    var selectedTeam:Team?
    var selectedStudent: Student?
    let studentObjectiveClassifier = StudentObjectiveClassifier()

    init(name: String) {
        self.name = name
        self.id = "F2DA7D69-F4D0-FFB6-9223-051BE4DCC96B"
    }
    
    init(sprintRecord: CKRecord) {
        self.name = sprintRecord["name"]
        self.id = sprintRecord.recordID.recordName
    }
    
    func retrieveAllObjectives(onSuccess sucess: @escaping () -> Void) -> Void {
        let defaultContainer = CKContainer.default()
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "StudentLearningObjectiveRecord", predicate: predicate)
        defaultContainer.privateCloudDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print (error)
                return
            }
            
            print("coletei: \(records.count)")
            
            records.forEach{
                record in
                let objective = StudentLearningObjective(record: record)
            }
            //Apagando todos os registros de estudantes
//            records.forEach{
//                record in
//                defaultContainer.privateCloudDatabase.delete(withRecordID: record.recordID){
//                    (recordID, error) -> Void in
//
//                    guard let recordID = recordID else {
//                        print("erro ao deletar registro")
//                        return
//                    }
//                    print("registro \(recordID) deletado com sucesso")
//                }
//            }
        }
        sucess()
    }
    
    func retrieveAllStudents(onSucess success: @escaping () -> Void) -> Void {
        let defaultContainer = CKContainer.default()
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "StudentRecord", predicate: predicate)
        defaultContainer.privateCloudDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print (error)
                return
            }
            records.forEach{
                record in
//                let student = Student(record: record)
//                if self.studentsDict[student.name] == nil {
//                    self.studentsDict[student.name] = student
//                }
            }
            
            success()
            //Apagando todos os registros de estudantes
            records.forEach{
                record in
                defaultContainer.privateCloudDatabase.delete(withRecordID: record.recordID){
                    (recordID, error) -> Void in

                    guard let recordID = recordID else {
                        print("erro ao deletar registro")
                        return
                    }
                    print("registro \(recordID) deletado com sucesso")
                }
            }
        }
    }
    
    //    func retriveAllTeams (_ teams: [Team]?, _ error: Error?) -> Void {
    func retrieveAllTeams(onSuccess success: @escaping () -> Void) -> Void {
        let defaultContainer = CKContainer.default()
        let teamRecord = CKRecord(recordType: "CBLSprintRecord", recordID: CKRecord.ID(recordName: self.id!))
        let reference = CKRecord.Reference(recordID: teamRecord.recordID, action: .none)
        let predicate = NSPredicate(format: "sprint == %@", reference)
        let query = CKQuery(recordType: "TeamRecord", predicate: predicate)
        defaultContainer.privateCloudDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print (error)
                return
            }
            
            if error == nil {
                records.forEach{record in
                    if let team = Team.fromCKRecord(ckRecord: record) {
                        self.teams[team.name] = team
                    }                    
                }
                success()
            }
        }
    }

    func sprint(teamName: String, studentName: String, description: String, level: String, priority: String, status: [Substring]) {
        //Alimentando o dicionário de teams com as informações no CloudKit
        let studentObjective = StudentLearningObjective(description: description)
        studentObjective.level = level
        studentObjective.priority = priority
        
        status.forEach{status in
            if status == "no backlog" {
                studentObjective.isInBacklog = true
            }
            if status == "abandonado" {
                studentObjective.isAbandoned = true
            }
            if status == "experimentando" {
                studentObjective.isExperimenting = true
            }
            if status == "estudando" {
                studentObjective.isStudying = true
            }
            if status == "aplicando no app" {
                studentObjective.isApplyingInTheSolution = true
            }
            if status == "ensinando em workshop" {
                studentObjective.isTeachingOthers = true
            }
        }
        
//        let defaultContainer = CKContainer.default()
//        let database = defaultContainer.privateCloudDatabase
//        if let recordID = studentObjective.saveToRecord(database: database) {
//            self.studentLearningObjectives[recordID] = studentObjective
//        }
        
        if self.studentsDict[studentName] != nil {
            self.studentsDict[studentName]?.addOriginalObjective(objective: studentObjective)
        }else {
            let student = Student()
            student.name = studentName
            student.addOriginalObjective(objective: studentObjective)
            self.studentsDict[studentName] = student
            let defaultContainer = CKContainer.default()
            let database = defaultContainer.privateCloudDatabase
            student.saveToRecord(database: database)
        }
        
        if let team = self.teams[teamName] {
            team.addMember(newMember: self.studentsDict[studentName]!)
            if let student = self.studentsDict[studentName] {
                student.activeTeam = team
            }
        }else {
            let team = Team(name: teamName)
            self.teams[teamName] = team
        }
    }
    
    func addStudentToBase(student: Student) {
        let defaultContainer = CKContainer.default()
        let database = defaultContainer.privateCloudDatabase
        
        let record = CKRecord(recordType: "StudentRecord")
        record["name"] = student.name
        database.save(record) {
            record, error in
            
            guard let record = record else {
                print(error)
                return
            }
            
            print("record salvo com sucesso")
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
        let names = self.studentsDict.keys.sorted()
        names.forEach{
            name in
            if name != student.name {
                let s = self.studentsDict[name]!
                let objectives:[StudentLearningObjective] = (s.objectivesByTopic(topic: objective.topic, onlyMustHave: true))
                objectives.forEach {
                    objective in
                    res.append((s, objective))
                    print(objective)
                }
            }
        }
        return res
    }
    
    
}

