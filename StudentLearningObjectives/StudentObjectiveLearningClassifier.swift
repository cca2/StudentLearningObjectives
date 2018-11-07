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
    func trainClassifier() -> Void
}

class StudentObjectiveClassifier {
    let classifierModel: NLModel?
    let objectivesTagger: NLTagger?
    let learningObjectiveTagger: LearningObjetiveTagger!
    
    var tempObjectives:[StudentLearningObjective] = []
    var currentStudent: Student?
    
    init() {
        let modelURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesClassifier.mlmodel")
        let compiledUrl = try! MLModel.compileModel(at: modelURL)
        self.classifierModel = try! NLModel(contentsOf: compiledUrl)
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
    
    func trainClassifier() -> Void {
        let trainingFileURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesClassifierTraining.csv")
        let data = try? MLDataTable(contentsOf: trainingFileURL)
        let (trainingData, testingData) = (data?.randomSplit(by: 0.9, seed: 5))!
        let areaClassifier = try! MLTextClassifier(trainingData: trainingData, textColumn: "Descrição", labelColumn: "Area")
        
        // Training accuracy as a percentage
        let trainingAccuracy = (1.0 - areaClassifier.trainingMetrics.classificationError) * 100
        
        // Validation accuracy as a percentage
        let validationAccuracy = (1.0 - areaClassifier.validationMetrics.classificationError) * 100
        
        let evaluationMetrics = areaClassifier.evaluation(on: testingData)
        
        print("Precisão do treinamento \(trainingAccuracy):\(validationAccuracy)")
        print("Métricas de avaliação \(evaluationMetrics.classificationError)")
        
        let metadata = MLModelMetadata(author: "Cristiano Araújo",
                                       shortDescription: "Um modelo para se classificar as áreas de aprendizado dos objetivos de aprendizado",
                                       version: "1.0")
        
        try? areaClassifier.write(to: URL(fileURLWithPath: "./TrainingData/LearningObjectivesClassifier.mlmodel"),
                                      metadata: metadata)
    }
}
