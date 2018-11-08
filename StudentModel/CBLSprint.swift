//
//  CBLSprint.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 07/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation

class CBLSprint {
    var teams:Dictionary = [String:Team]()
    var studentsDict:Dictionary = [String:Student]()
    var selectedTeam:Team?
    var selectedStudent: Student?
    
    init() {
        
    }
    
    func sprint(teamName: String, studentName: String, description: String, level: String, priority: String) {
        let studentObjective = StudentLearningObjective(description: description)
                
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
//        if teamObjectivesDict[teamName] == nil {
//            teamObjectivesDict[teamName] = [:]
//            teamObjectivesDict[teamName]?[studentName] = self.cblSprint.studentsDict[studentName]
//            self.teamsPopUp.addItem(withTitle: teamName)
//        }else {
//            teamObjectivesDict[teamName]?[studentName] = self.cblSprint.studentsDict[studentName]
//        }
    }
    
    func addTeam(newTeam:Team) {
        self.teams[newTeam.name] = newTeam
    }
    
    func teamWithName(name:String) -> Team? {
        return self.teams[name]
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
