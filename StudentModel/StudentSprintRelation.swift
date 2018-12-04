//
//  StudentSprintRelation.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 24/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation

class StudentSprintRelation {
    var student:Student?
    var course: CBLCourse?
    var sprint:CBLSprint?
    var team:Team?
//    var originalObjectives:[StudentLearningObjective] = []
    var classifiedObjectives:Dictionary = [String:[StudentLearningObjective]]()
}

class StudentCourseRelation {
    var sprints:[StudentSprintRelation] = []
    var course:CBLCourse?
    var student:Student?
}
