//
//  CBLNotesNode.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 14/12/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation

class CBLNotesNode {
    enum Level {case Top, Course, Sprint, Team, Objectives, Note}
    let subLevels:[Level:Level] = [.Top:.Course, .Course:.Sprint, .Sprint:.Objectives, .Objectives:.Team, .Team:.Note]
    
    var label = ""
    var level = Level.Top
    var children = [CBLNotesNode]()
    var note: CBLNote! = nil
    
    func add(_ note:CBLNote) {
        var subLabel = ""
        switch level {
        case .Top: subLabel = note.course.name!
        case .Course: subLabel = note.sprint.name!
        case .Sprint: subLabel = "Objetivos"
        case .Objectives: subLabel = note.team.name
        case .Note: self.note = note
            return
        default:
            return
        }
        
        var subNode:CBLNotesNode! = children.first{$0.label == subLabel}
        if subNode == nil {
            subNode = CBLNotesNode()
            subNode.level = subLevels[level]!
            subNode.label = subLabel
            children.append(subNode)
        }
        subNode.add(note)
    }
}

class CBLNote {
    let course:CBLCourse!
    let sprint: CBLSprint!
    let team: Team!
    
    init(course: CBLCourse, sprint: CBLSprint, team: Team) {
        self.course = course
        self.sprint = sprint
        self.team = team
    }
}

