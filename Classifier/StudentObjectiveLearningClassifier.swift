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
    let objectivesTagger: NLTagger?
    let learningObjectiveTagger: LearningObjetiveTagger!
    
    var tempObjectives:[StudentLearningObjective] = []
    var currentStudent: Student?
    let areaModelURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesAreaClassifier.mlmodel")
    var areaClassifierModel: NLModel?

    let topicsModelURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesTopicsClassifier.mlmodel")
    let topicsClassifierModel: NLModel?

    let trainingFileURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesClassifierTraining.csv")
    let studentsData:MLDataTable?
    
    init() {
        
        let areaCompiledUrl = try? MLModel.compileModel(at: areaModelURL)
        
        if areaCompiledUrl != nil {
            self.areaClassifierModel = try! NLModel(contentsOf: areaCompiledUrl!)
        }
        
        self.studentsData = try? MLDataTable(contentsOf: self.trainingFileURL)
        self.objectivesTagger = NLTagger(tagSchemes: [.lexicalClass])
        self.learningObjectiveTagger = LearningObjetiveTagger()
        
        if let topicsCompiledURL = try? MLModel.compileModel(at: topicsModelURL) {
            self.topicsClassifierModel = try? NLModel(contentsOf: topicsCompiledURL)
        }else {
            self.topicsClassifierModel = nil
        }
     }
    
    func classifyStudentObjectives(student: Student) {
        if self.areaClassifierModel == nil {
            self.trainAreaClassifier()
        }
        
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
            let areaClassification:String? = self.areaClassifierModel?.predictedLabel(for: sentence)
            let topicClassification:String? = self.topicsClassifierModel?.predictedLabel(for: sentence)
            
            let newObjective = StudentLearningObjective(description:sentence)
            
            if areaClassification != nil {
                newObjective.area = areaClassification!
            }
            
            if topicClassification != nil {
                newObjective.topic = topicClassification!
            }
            
            newObjective.level = objective.level
            newObjective.priority = objective.priority

            self.learningObjectiveTagger.tagLearningObjetive(objective: newObjective)
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
        trainAreaClassifier()
        trainTopicsClassifier()
    }
    
    func trainTopicsClassifier() -> Void {
        let data = try? MLDataTable(contentsOf: trainingFileURL)
        let (trainingData, testingData) = (data?.randomSplit(by: 0.9, seed: 5))!
        let topicsClassifier = try! MLTextClassifier(trainingData: trainingData, textColumn: "Descrição", labelColumn: "Tópico")
        
        // Training accuracy as a percentage
        let trainingAccuracy = (1.0 - topicsClassifier.trainingMetrics.classificationError) * 100
        
        // Validation accuracy as a percentage
        let validationAccuracy = (1.0 - topicsClassifier.validationMetrics.classificationError) * 100
        
        let evaluationMetrics = topicsClassifier.evaluation(on: testingData)
        
        print("Precisão do treinamento \(trainingAccuracy):\(validationAccuracy)")
        print("Métricas de avaliação \(evaluationMetrics.classificationError)")
        
        let metadata = MLModelMetadata(author: "Cristiano Araújo",
                                       shortDescription: "Um modelo para se classificar os tópicos de aprendizado dos objetivos de aprendizado",
                                       version: "1.0")
        
        try? topicsClassifier.write(to: self.topicsModelURL,
                                  metadata: metadata)
    }
    
    func trainAreaClassifier() -> Void {
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
        
        try? areaClassifier.write(to: self.areaModelURL,
                                  metadata: metadata)
    }
}
