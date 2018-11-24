//
//  CBLCouse.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 24/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import CloudKit
import Cocoa

class CBLCourse {
    var name: String?
    var id: String?
    var sprints:[CBLSprint] = []
    let delegate = NSApplication.shared.delegate as! AppDelegate

    init(courseRecord: CKRecord) {
        self.name = courseRecord["name"]
        self.id = courseRecord.recordID.recordName
        
        let database = CKContainer.default().privateCloudDatabase
        let reference = CKRecord.Reference(recordID: courseRecord.recordID, action: .none)
        let predicate = NSPredicate(format: "belongToCourse == %@", reference)
        let query = CKQuery(recordType: "CBLSprintRecord", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) {
            results, error in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if let results = results {
                    results.forEach{
                        record in
                        let sprint = CBLSprint(sprintRecord: record)
                        self.sprints.append(sprint)
                    }
                    self.delegate.selectedCourseSprintsFetched()
                }
            }
        }
    }
}
