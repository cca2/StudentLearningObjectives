//
//  LearningObjectivesTrainer.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 25/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import CreateML
import CoreML

class LearningObjectivesTrainer {
    let taggerFileURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesTaggerTraining.json")
    let taggerModelURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesTagger.mlmodel")
    var trainingData = TrainingData(dataSet: [])

    func organizeTrainingData() {
        var trainingData:TrainingData = TrainingData(dataSet: [])
        let tagger = LearningObjetiveTagger()
        
        //Adiciona a coluna de texto
        let objectivesInCSVFileURL = Bundle.main.url(forResource:"ObjetivosTeste", withExtension:"csv")
        let trainingTable = try! MLDataTable(contentsOf: objectivesInCSVFileURL!)
        trainingTable.rows.forEach{
            row in
            var objective = Objective(tokens: [], labels: [], description: "", areaClassification: "", topicClassification: "")
            objective.description = (row["Descrição"]?.stringValue)!
            objective.areaClassification = (row["Area"]?.stringValue)!
            objective.topicClassification = "NONE"
            
            let taggerRes:[String: [String]] = tagger.tagText(text: objective.description)
            objective.tokens = taggerRes["tokens"]!
            objective.labels = taggerRes["labels"]!
            
            trainingData.dataSet.append(objective)
        }
        
        let jsonEnconder = JSONEncoder()
        if let newJsonData = try? jsonEnconder.encode(trainingData.dataSet) {
            let fileURL = URL(fileURLWithPath: "/Users/cristianoaraujo/Desktop/LearningObjectivesTaggerTraining.json")
            try? newJsonData.write(to: fileURL)
        }
    }

    func updateTaggerModel() {
        let trainingTable = try! MLDataTable(contentsOf: taggerFileURL)
        let model = try! MLWordTagger(trainingData: trainingTable, tokenColumn: "tokens", labelColumn: "labels")
        
        let metadata = MLModelMetadata(author: "Cristiano Araujo", shortDescription: "Um tagger NLP para identificar tokens relevantes para identificar os tópicos e ações dos objetivos de aprendizado", license: "MIT", version: "1.0")
        try? model.write(to: URL(fileURLWithPath: "./TrainingData/LearningObjectivesTagger.mlmodel"), metadata: metadata)
    }
    
//    func updateTrainingData(newDataForTraining:[Dictionary<String, [String]>]) {
    func updateTrainingData(newDataForTraining: [StudentLearningObjective]) {
        if let data = try? Data(contentsOf: taggerFileURL) {
            //Ler os dados de treinamento salvos em arquivo
            let decoder = JSONDecoder()
            if let jsonData = try? decoder.decode([Objective].self, from: data) {
                jsonData.forEach{
                    newData in
                    let newObjective = Objective(tokens: newData.tokens, labels: newData.labels, description: newData.description, areaClassification: newData.areaClassification, topicClassification: newData.topicClassification)
                    trainingData.dataSet.append(newObjective)
                }
                
                //Adiciona os novos dados de treinamento
                newDataForTraining.forEach{
                    newData in
//                    let newObjective = Objective(tokens: newData["tokens"]!, labels: newData["labels"]!, description:newData["description"], areaClassification: newData["areaClassification"]!, topicClassification:newData["topicClassification"]!)
                    var tokens:[String] = []
                    var labels:[String] = []
                    newData.tags.forEach{
                        tag in
                        tokens.append(tag.value)
                        labels.append(tag.tag)
                    }
                    let newObjective = Objective(tokens: tokens, labels: labels, description: newData.description, areaClassification: newData.area, topicClassification: "NONE")
                    trainingData.dataSet.append(newObjective)
                }
                
                let jsonEnconder = JSONEncoder()
                if let newJsonData = try? jsonEnconder.encode(trainingData.dataSet) {
                    try? newJsonData.write(to: taggerFileURL)
                }
            }
        }
        updateTaggerModel()
    }
}

struct TrainingData: Decodable, Encodable {
    var dataSet: [Objective]
}

struct Objective: Decodable, Encodable {
    var tokens: [String]
    var labels: [String]
    var description: String
    var areaClassification: String
    var topicClassification: String
}
