//
//  Team.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 15/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import CloudKit

class Team {
    enum InfoTypes {
        case BigIdea
        case EssentialQuestion
        case Challenge
        case Concept
    }

    var id: String?
    var name: String
    var members: [String:Student] = [:]
    var bigIdea: String?
    var essentialQuestion: String?
    var challenge: String?
    var concept: String?
    
    init(name: String) {
        self.name = name
    }
    
    static func fromCKRecord(ckRecord: CKRecord) -> Team? {
        guard let name = ckRecord["name"] as? String else {
            return nil
        }
        
        var bigIdea = ckRecord["bigIdea"] as? String
        if bigIdea == nil {
            bigIdea = ""
        }
        var essentialQuestion = ckRecord["essentialQuestion"] as? String
        if essentialQuestion == nil {
            essentialQuestion = ""
        }
        var challenge = ckRecord["challenge"] as? String
        if challenge == nil {
            challenge = ""
        }
        var concept = ckRecord["concept"] as? String
        if concept == nil {
            concept = ""
        }
        
        let team = Team(name: name)
        team.id = ckRecord.recordID.recordName
        team.bigIdea = bigIdea
        team.essentialQuestion = essentialQuestion
        team.challenge = challenge
        team.concept = concept
        return team
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
