//
//  BloomsKnowledgeClassifier.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 14/12/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation
import NaturalLanguage
import CoreML
import CreateML

protocol BloomsKnowledgeClassifierProtocol {
    func checkForMeasurableVerb(objective:String, onCheked checked: @escaping (BloomsKnowledgeClassifier.MeasurableVertStatus, [String]) -> Void) -> Void
}

class BloomsKnowledgeClassifier {
    //https://tips.uark.edu/using-blooms-taxonomy/
    enum Level {case Remember, Understand, Apply, Analyze, Evaluate, Create}
    enum MeasurableVertStatus {case NoVerb, OneVerb, MoreThanOneVerb}
    
    let meausrableVerbsURL = Bundle.main.url(forResource:"measurable_verbs", withExtension: "csv")!
    
    let measurableVerbsTable:MLDataTable?
    var measurableVerbsList:[String] = []
    
    init() {
        self.measurableVerbsTable = try? MLDataTable(contentsOf: self.meausrableVerbsURL)
        self.measurableVerbsTable?.rows.forEach{
            row in
            let verb:String = (row.values.first?.stringValue)!
            measurableVerbsList.append(verb)
        }
    }
}

extension BloomsKnowledgeClassifier: BloomsKnowledgeClassifierProtocol {
    func checkForMeasurableVerb(objective:String, onCheked checked: @escaping (BloomsKnowledgeClassifier.MeasurableVertStatus, [String]) -> Void) -> Void {
        var res:[String] = []
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma])
        tagger.string = objective
        
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
//        let tags: [NLTag] = [.verb]
        
        // 3
        tagger.enumerateTags(in: objective.startIndex..<objective.endIndex, unit: .word, scheme: .lemma, options: options) {
            tag, tokenRange in
            if let lemma = tag?.rawValue {
                print(">>> LEMMA: \(lemma)")
                if self.measurableVerbsList.contains(lemma) {
                    res.append(lemma)
                }
            }
            return true
        }
        var status:MeasurableVertStatus!
        if res.count == 0 {
            status = MeasurableVertStatus.NoVerb
        }else if res.count == 1 {
            status = MeasurableVertStatus.OneVerb
        }else if res.count > 1 {
            status = MeasurableVertStatus.MoreThanOneVerb
        }
        checked(status, res)
    }
}
