//
//  CBLCouse.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 24/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import CloudKit

class CBLCourse {
    var name: String?
    var id: String?
    var sprint:[CBLSprint] = []
    
    init(courseRecord: CKRecord) {
        self.name = courseRecord["name"]
        self.id = courseRecord.recordID.recordName
    }
}
