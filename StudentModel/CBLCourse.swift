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
    var studentsByID:[String: Student] = [:]
    
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
    
    func retrieveAllStudents(onSucess success: @escaping () -> Void) -> Void {
        let defaultContainer = CKContainer.default()
        let courseRecord = CKRecord(recordType: "CBLCourseRecord", recordID: CKRecord.ID(recordName: self.id!))
        let reference = CKRecord.Reference(recordID: courseRecord.recordID, action: .none)
        let predicate = NSPredicate(format: "SELF.courses contains %@", reference.recordID)
        let query = CKQuery(recordType: "StudentRecord", predicate: predicate)
        defaultContainer.privateCloudDatabase.perform(query, inZoneWith: nil) {
            (records, error) in
            guard let records = records else {
                print (error)
                return
            }
            records.forEach{
                record in
                let student = Student(record: record)
                self.studentsByID[student.id] = student
                print(student.name)
            }
            
            
            //Apagando todos os registros de estudantes
//            records.forEach{
//                record in
//                defaultContainer.privateCloudDatabase.delete(withRecordID: record.recordID){
//                    (recordID, error) -> Void in
//                    
//                    guard let recordID = recordID else {
//                        print("erro ao deletar registro")
//                        return
//                    }
//                    print("registro \(recordID) deletado com sucesso")
//                }
//            }
        }
    }

}
