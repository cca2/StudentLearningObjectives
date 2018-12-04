//
//  StudentLearningObjectives.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 21/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import NaturalLanguage
import CoreML
import CreateML
import CloudKit

class Student {
    var name = ""
    var id = ""
//    var courses:[CBLCourse] = []
    var originalObjectives:[String:StudentLearningObjective] = [:]
    var classifiedObjectives:Dictionary = [String:[StudentLearningObjective]]()
//    var team: Team?
    var teamID: String?
    
    init() {
        self.classifiedObjectives["innovation"] = []
        self.classifiedObjectives["programming"] = []
        self.classifiedObjectives["appdev"] = []
        self.classifiedObjectives["design"] = []
        self.classifiedObjectives["success skills"] = []
        self.classifiedObjectives["none"] = []
    }
    
    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.name = record["name"]!
        self.classifiedObjectives["innovation"] = []
        self.classifiedObjectives["programming"] = []
        self.classifiedObjectives["appdev"] = []
        self.classifiedObjectives["design"] = []
        self.classifiedObjectives["success skills"] = []
        self.classifiedObjectives["none"] = []
//        self.activeTeam = record["activeTeam"]? as? Team
    }
    
    func saveToRecord(database: CKDatabase) {
        let studentRecord = CKRecord(recordType: "StudentRecord")
        studentRecord["name"] = self.name
//        record["activeTeam"] = self.activeTeam?.id
        database.save(studentRecord) {
            record, error in
        }
    }
    
    func addOriginalObjective(objective:StudentLearningObjective) -> Void {
//        self.originalObjectives.append(objective)
        self.originalObjectives[objective.id!] = objective
    }
    
    func prepareToClassify() {
        self.classifiedObjectives["innovation"] = []
        self.classifiedObjectives["programming"] = []
        self.classifiedObjectives["appdev"] = []
        self.classifiedObjectives["design"] = []
        self.classifiedObjectives["success skills"] = []
        self.classifiedObjectives["none"] = []
    }
        
    func objectivesByTopic(topic: String, onlyMustHave:Bool) -> [StudentLearningObjective] {
        var res = [StudentLearningObjective]()
        let areas = self.classifiedObjectives.keys
        areas.forEach{
            area in
            self.classifiedObjectives[area]?.forEach{
                objective in
                if objective.topic == topic {
                    if onlyMustHave {
                        if objective.priority == "must-have" {
                            res.append(objective)
                        }
                    }else {
                        res.append(objective)
                    }
                }
            }
        }
        return res
    }
}
