//
//  CBLSprint.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 07/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import CreateML

class CBLSprint {
    var teams:Dictionary = [String:Team]()
    var studentsDict:Dictionary = [String:Student]()
    var selectedTeam:Team?
    var selectedStudent: Student?
    let studentObjectiveClassifier = StudentObjectiveClassifier()

    init() {
        let studentsData = self.studentObjectiveClassifier.studentsData
        
        guard let rows = studentsData?.rows else {return}
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
            let priority = row.values[priorityIndex].stringValue!
            let expertiseLevel = row.values[expertiseLevelIndex].stringValue!
            
            let studentObjective = StudentLearningObjective(description: description)
            studentObjective.level = expertiseLevel
            studentObjective.priority = priority
            
            self.sprint(teamName: teamName, studentName: studentName, description: description, level: expertiseLevel, priority: priority)
        }
        
        self.studentsDict.keys.forEach{
            name in
            let student = self.studentsDict[name]
            self.studentObjectiveClassifier.classifyStudentObjectives(student: student!)
        }
    }
    
    func sprint(teamName: String, studentName: String, description: String, level: String, priority: String) {
        let studentObjective = StudentLearningObjective(description: description)
        studentObjective.level = level
        studentObjective.priority = priority
        
        if self.studentsDict[studentName] != nil {
            self.studentsDict[studentName]?.addOriginalObjective(objective: studentObjective)
        }else {
            let student = Student()
            student.name = studentName
            student.addOriginalObjective(objective: studentObjective)
            self.studentsDict[studentName] = student
        }
        
        if (self.teams[teamName] != nil) {
            self.teams[teamName]?.addMember(newMember: self.studentsDict[studentName]!)
        }else {
            let team = Team(name: teamName)
            self.teams[teamName] = team
        }
    }
    
    func addTeam(newTeam:Team) {
        self.teams[newTeam.name] = newTeam
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

class Team {
    var name: String
    var members: [String:Student] = [:]
    
    init(name: String) {
        self.name = name
    }
    
    func addMember(newMember:Student) {
        self.members[newMember.name] = newMember
    }
    
    func memberWithName(name: String) -> Student? {
        return self.members[name]
    }
    
    func membersNames() -> [String] {
        return members.keys.sorted()
    }
}
