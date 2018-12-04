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
    
//    var tempObjectives:[StudentLearningObjective] = []
    var currentStudent: Student?
//    let areaModelURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesAreaClassifier.mlmodel")
    let areaModelURL:URL
    var areaClassifierModel: NLModel

//    let topicsModelURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesTopicsClassifier.mlmodel")
    let topicsModelURL = Bundle.main.url(forResource:"LearningObjectivesTopicsClassifier", withExtension:"mlmodelc")!
    var topicsClassifierModel: NLModel

//    let trainingFileURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesClassifierTraining.csv")
    let trainingFileURL = Bundle.main.url(forResource:"LearningObjectivesClassifierTraining", withExtension: "csv")!

    let studentsData:MLDataTable?
    
    init() {
        self.areaModelURL = Bundle.main.url(forResource:"LearningObjectivesAreaClassifier", withExtension:"mlmodelc")!
        self.areaClassifierModel = try! NLModel(contentsOf: areaModelURL)

//        if let areaCompiledUrl = try? MLModel.compileModel(at: areaModelURL) {
//            self.areaClassifierModel = try! NLModel(contentsOf: areaCompiledUrl)
//        }
        
        self.studentsData = try? MLDataTable(contentsOf: self.trainingFileURL)
        self.objectivesTagger = NLTagger(tagSchemes: [.lexicalClass])
        self.learningObjectiveTagger = LearningObjetiveTagger()
        
//        if let topicsCompiledURL = try? MLModel.compileModel(at: topicsModelURL) {
//            self.topicsClassifierModel = try? NLModel(contentsOf: topicsCompiledURL)
//        }else {
//            self.topicsClassifierModel = nil
//        }
        self.topicsClassifierModel = try! NLModel(contentsOf: topicsModelURL)
        
     }
    
    func classifyStudentObjectives(student: Student) {
        self.currentStudent = student
        var tempObjectives:[StudentLearningObjective] = []
        student.classifiedObjectives = [:]
        student.prepareToClassify()
        if let originalObjectives = self.currentStudent?.originalObjectives {
            originalObjectives.keys.forEach{
                id in
                let objective = originalObjectives[id]
                tempObjectives = organizeAndClassifyObjective(objective: objective!)
                tempObjectives.forEach{
                    objective in
                    student.classifiedObjectives[objective.area]?.append(objective)
                }
            }
        }
    }
    
    func organizeAndClassifyObjective(objective:StudentLearningObjective) -> [StudentLearningObjective]{
        var res = [StudentLearningObjective]()
        if self.areaClassifierModel == nil {
            self.trainAreaClassifier()
        }
        
//        if self.topicsClassifierModel == nil {
//            self.trainTopicsClassifier()
//            if let topicsCompiledURL = try? MLModel.compileModel(at: topicsModelURL) {
//                self.topicsClassifierModel = try! NLModel(contentsOf: topicsCompiledURL)
//            }else {
//                self.topicsClassifierModel = nil
//            }
//        }
        let sentence = String(objective.description)
        let areaClassification:String? = self.areaClassifierModel.predictedLabel(for: sentence)
        let topicClassification:String? = self.topicsClassifierModel.predictedLabel(for: sentence)
        objective.area = areaClassification!
        objective.topic = areaClassification!
        self.learningObjectiveTagger.tagLearningObjetive(objective: objective)
        res.append(objective)
        
        //Aqui é um código que tenta quebrar os objetivos em sentenças
//        let description = objective.description
//        self.objectivesTagger?.string = description
//        self.objectivesTagger?.enumerateTags(in: description.startIndex..<description.endIndex, unit: .sentence, scheme: .lexicalClass, options: [.omitPunctuation, .omitWhitespace, .joinNames]) {
//            (tag, tokenRange) -> Bool in
//            let sentence = String(description[tokenRange])
//            let areaClassification:String? = self.areaClassifierModel.predictedLabel(for: sentence)
//            let topicClassification:String? = self.topicsClassifierModel.predictedLabel(for: sentence)
//
//            let newObjective = StudentLearningObjective(description:sentence)
//            newObjective.isTeachingOthers = objective.isTeachingOthers
//            newObjective.isApplyingInTheSolution = objective.isApplyingInTheSolution
//            newObjective.isStudying = objective.isStudying
//            newObjective.isExperimenting = objective.isExperimenting
//            newObjective.isAbandoned = objective.isAbandoned
//            newObjective.isInBacklog = objective.isInBacklog
//
//            if areaClassification != nil {
//                newObjective.area = areaClassification!
//            }
//
//            if topicClassification != nil {
//                newObjective.topic = topicClassification!
//            }
//
//            newObjective.level = objective.level
//            newObjective.priority = objective.priority
//
//            self.learningObjectiveTagger.tagLearningObjetive(objective: newObjective)
//            tempObjectives.append(newObjective)
//            return true
//        }
        return res
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
