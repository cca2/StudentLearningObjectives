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
    var id: String?
    var courseID:String?
    var sprintID:String?
    var teamID:String?
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
    var tagsListString: String?
    
    init(description:String) {
        self.description = description
        let objectiveRecord = CKRecord(recordType: "StudentLearningObjective")
        print("novo objetivo: \(objectiveRecord.recordID)")
    }
    
    init (record: CKRecord) {
        self.id = record.recordID.recordName
        
        let courseReference = record["course"] as? CKRecord.Reference
        self.courseID = courseReference?.recordID.recordName
        
        let sprintReference = record["sprint"] as? CKRecord.Reference
        self.sprintID = sprintReference?.recordID.recordName
        
        let teamReference = record["team"] as? CKRecord.Reference
        self.teamID = teamReference?.recordID.recordName
        
        self.description = record["description"]!
        let studentReference = record["student"] as! CKRecord.Reference
        self.studentID = studentReference.recordID.recordName
        self.priority = record["priority"]!
        self.level = record["level"]!
        self.isInBacklog = record["isInBacklog"]!
        self.isAbandoned = record["isAbandoned"]!
        self.isStudying = record["isStudying"]!
        self.isExperimenting = record["isExperimenting"]!
        self.isApplyingInTheSolution = record["isApplyingInTheSolution"]!
        self.isTeachingOthers = record["isTeachingOthers"]!
    }
    
    func savetoDatabase(database: CKDatabase) -> String? {
        return ""
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

