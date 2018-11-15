//
//  StudentLearningObjectiveTagger.swift
//  LearningObjectives
//
//  Created by Cristiano Araújo on 26/10/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import CoreML
import CreateML
import NaturalLanguage

class LearningObjetiveTagger {
    let learningObjectiveTagScheme = NLTagScheme("LearningObjective")
    let topicTag = NLTag("TOPIC")
    let genericTopicTag = NLTag("GENERIC_TOPIC")
    let actionTag = NLTag("ACTION")
    let genericActionTag = NLTag("GENERIC_ACTION")
    let deviceTag = NLTag("DEVICE")
    let noneTag = NLTag("NONE")
    let nonActionTag = NLTag("NON_ACTION")
    
    let options:NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    let tags: [NLTag]
    
    let taggerModelURL:URL?
    var learningObjectiveTaggerModel: NLModel
    
    let learningObjectiveTagger: NLTagger
    
    init() {
        self.tags = [.personalName, .organizationName, topicTag, actionTag, nonActionTag, genericActionTag, genericTopicTag, deviceTag, noneTag]
//        self.taggerModelURL = URL(fileURLWithPath: "./TrainingData/LearningObjectivesTagger.mlmodel")
//        let compiledUrl = try! MLModel.compileModel(at: self.taggerModelURL!)
        
        self.taggerModelURL = Bundle.main.url(forResource:"LearningObjectivesTagger", withExtension:"mlmodelc")!
        self.learningObjectiveTaggerModel = try! NLModel(contentsOf: taggerModelURL!)
//        let mlModel = try! MLModel(contentsOf: compiledUrl)
        

//        self.learningObjectiveTaggerModel = try! NLModel(mlModel: mlModel)
        self.learningObjectiveTagger = NLTagger(tagSchemes: [.nameType, learningObjectiveTagScheme])
        self.learningObjectiveTagger.setModels([learningObjectiveTaggerModel], forTagScheme: learningObjectiveTagScheme)
    }
    
    func tagText(text: String) -> [String: [String]] {
        var res:[String: [String]] = ["tokens":[],"labels":[]]
        self.learningObjectiveTagger.string = text
        self.learningObjectiveTagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: learningObjectiveTagScheme, options: options) { (tag, tokenRange) -> Bool in
                        
            if let tag = tag, tags.contains(tag) {
                res["tokens"]?.append(String(text[tokenRange]))
                res["labels"]?.append(String(tag.rawValue))
            }
            return true
        }
        return res
    }

    func updateModel() {
        let compiledUrl = try! MLModel.compileModel(at: self.taggerModelURL!)
        let mlModel = try! MLModel(contentsOf: compiledUrl)
        self.learningObjectiveTaggerModel = try! NLModel(mlModel: mlModel)
        self.learningObjectiveTagger.setModels([learningObjectiveTaggerModel], forTagScheme: learningObjectiveTagScheme)
    }
    
    func tagLearningObjetive(objective:StudentLearningObjective) -> Void {
        let text = objective.description
        self.learningObjectiveTagger.string = text
        self.learningObjectiveTagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: learningObjectiveTagScheme, options: options) { (tag, tokenRange) -> Bool in
            
            if let tag = tag, tags.contains(tag) {
                objective.tags.append((tag.rawValue, String(text[tokenRange])))
            }
            return true
        }
    }
}
