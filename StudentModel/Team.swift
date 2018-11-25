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
        guard let name = ckRecord["name"] as? String,
        let bigIdea = ckRecord["bigIdea"] as? String,
        let essentialQuestion = ckRecord["essentialQuestion"] as? String,
        let challenge = ckRecord["challenge"] as? String,
        let concept = ckRecord["concept"] as? String else {
            return nil
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
