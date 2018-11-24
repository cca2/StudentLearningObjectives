//
//  StudentLearningObjective.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 25/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import CloudKit

class StudentLearningObjective {
    var sprintID = ""
    var teamID = ""
    var studentID = ""
    var description = ""
    var priority = "none"
    var level = "none"
    var area = "none"
    var topic = "none"
    var tags: [(tag:String, value:String)] = []
    var isAbandoned = false
    var isStudying = false
    var isExperimenting = false
    var isApplyingInTheSolution = false
    var isTeachingOthers = false
    var isInBacklog = false
    
    init(description:String) {
        self.description = description
    }
    
    init (record: CKRecord) {
        self.description = record["description"]!
    }
    
    func saveToRecord(sprintID: String, studentID: String, teamID: String, database: CKDatabase) -> String? {
        let record = CKRecord(recordType: "StudentLearningObjectiveRecord")
        record["area"] = self.area
        record["description"] = self.description
        record["isAbandoned"] = self.isAbandoned
        record["isInBacklog"] = self.isInBacklog
        record["isStudying"] = self.isStudying
        record["isApplyingInTheSolution"] = self.isApplyingInTheSolution
        record["isTeachingOthers"] = self.isTeachingOthers
        
        var res: String?
        
        database.save(record) {
            record, error in
            
            if let record = record {
                print("objetivo \(self.description) salvo com sucesso")
                res = record.recordID.recordName
            }
        }
        return res
    }

    func isClear() -> Bool {
        var objectiveIsClear = false
        tags.forEach{
            tag in
            if (tag.tag != "NONE") {
                objectiveIsClear = true
            }
        }
        return objectiveIsClear
    }
}

