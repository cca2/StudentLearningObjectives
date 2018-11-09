//
//  StudentLearningObjective.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 25/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation

class StudentLearningObjective {
    var description = ""
    var priority = "none"
    var level = "none"
    var area = "none"
    var topic = "none"
    var tags: [(tag:String, value:String)] = []
    
    init(description:String) {
        self.description = description
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

