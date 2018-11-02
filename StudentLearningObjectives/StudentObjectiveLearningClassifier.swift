//
//  StudentObjectiveLearningClassifier.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 25/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import NaturalLanguage
import CoreML
import CreateML

protocol StudentObjectiveClassifierDelegate {
    func taggerModelUpdated() -> Void
}

class StudentObjectiveClassifier {
    let classifierModel: NLModel?
    let objectivesTagger: NLTagger?
    let learningObjectiveTagger: LearningObjetiveTagger!
    
    var tempObjectives:[StudentLearningObjective] = []
    var currentStudent: Student?
    
    init() {
        let modelURL = Bundle.main.url(forResource: "LearningObjectivesClassifier", withExtension: "mlmodelc")!
        self.classifierModel = try! NLModel(contentsOf: modelURL)
        self.objectivesTagger = NLTagger(tagSchemes: [.lexicalClass])
        self.learningObjectiveTagger = LearningObjetiveTagger()
    }
    
    func classifyStudentObjectives(student: Student) {
        self.currentStudent = student
        tempObjectives = []
        self.currentStudent?.originalObjectives.forEach{
            objective in
            organizeAndClassifyObjective(objective: objective)
        }
        student.prepareToClassify()
        tempObjectives.forEach{
            objective in
            student.classifiedObjectives[objective.area]?.append(objective)
        }
    }
    
    func organizeAndClassifyObjective(objective:StudentLearningObjective) {
        let description = objective.description
        self.objectivesTagger?.string = description
        self.objectivesTagger?.enumerateTags(in: description.startIndex..<description.endIndex, unit: .sentence, scheme: .lexicalClass, options: [.omitPunctuation, .omitWhitespace, .joinNames]) {
            (tag, tokenRange) -> Bool in
            let sentence = String(description[tokenRange])
            let classification = self.classifierModel?.predictedLabel(for: sentence)
            
            let newObjective = StudentLearningObjective(description:sentence)
            newObjective.level = objective.level
            newObjective.priority = objective.priority
            
            self.learningObjectiveTagger.tagLearningObjetive(objective: newObjective)
            newObjective.area = classification!
            newObjective.level = objective.level
            newObjective.priority = objective.priority
            tempObjectives.append(newObjective)
            return true
        }
    }
}

extension StudentObjectiveClassifier: StudentObjectiveClassifierDelegate {
    func taggerModelUpdated() {
        self.learningObjectiveTagger.updateModel()
    }
}
