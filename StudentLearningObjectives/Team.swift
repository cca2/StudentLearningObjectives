//
//  Team.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 15/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation

class Team {
    var name: String
    var members: [String:Student] = [:]
    var bigIdea: String?
    var essentialQuestion: String?
    var challenge: String?
    
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
