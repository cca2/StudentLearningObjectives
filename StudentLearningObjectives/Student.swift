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

class Student {
    var name = ""
    var originalObjectives:[StudentLearningObjective] = []
    var classifiedObjectives:Dictionary = [String:[StudentLearningObjective]]()
    
    init() {
        self.classifiedObjectives["innovation"] = []
        self.classifiedObjectives["programming"] = []
        self.classifiedObjectives["appdev"] = []
        self.classifiedObjectives["design"] = []
        self.classifiedObjectives["success skills"] = []
        self.classifiedObjectives["none"] = []
    }
    
    func addOriginalObjective(objective:StudentLearningObjective) -> Void {
        self.originalObjectives.append(objective)
    }
    
    func prepareToClassify() {
        self.classifiedObjectives["innovation"] = []
        self.classifiedObjectives["programming"] = []
        self.classifiedObjectives["appdev"] = []
        self.classifiedObjectives["design"] = []
        self.classifiedObjectives["success skills"] = []
        self.classifiedObjectives["none"] = []
    }
        
    func toString() -> String {
        var res = ""
        res = "Objetivos de \(name)"
        let keys = self.classifiedObjectives.keys
        keys.forEach{
            key in
            res.append("\n\(key)")
            let objectives = classifiedObjectives[key]
            objectives?.forEach{
                objective in
                if objective.tags.count > 0 {
                    res.append("\n")
                    objective.tags.forEach {tag in
                        if tag.0 == "TOPIC" {
                            res.append("\(tag.value) ")
                        }
                    }
                }
            }
        }
        return res
    }
}
