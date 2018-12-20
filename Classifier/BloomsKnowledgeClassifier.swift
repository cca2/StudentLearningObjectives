import Foundation
import NaturalLanguage
import CoreML
import CreateML

protocol BloomsRevisedTaxonomyClassifierProtocol {
    func checkForMeasurableVerb(objective:String, onCheked checked: @escaping (String, BloomsRevisedTaxonomyClassifier.MeasurableVertStatus, [String]) -> Void) -> Void
    func checkForLearningTopics(objective:String, onCheked checked: @escaping (String, [String]) -> Void) -> Void
    func checkForTopics(objective:String, onCheked checked: @escaping (String, [String]) -> Void) -> Void
}

struct TaggedDescription: Encodable {
    var tokens:[String] = []
    var tags:[String] = []
}

class BloomsRevisedTaxonomyClassifier {
    //    https://tips.uark.edu/using-blooms-taxonomy/
    //    https://teachonline.asu.edu/2012/07/writing-measurable-learning-objectives/
    let topicsTagsDataURL = URL(fileURLWithPath: "/Users/cristianoaraujo/Downloads/topics_tags_data.json")
    var taggedObjectives:[TaggedDescription] = []
    enum Level {case Remember, Understand, Apply, Analyze, Evaluate, Create}
    enum MeasurableVertStatus {case NoVerb, OneVerb, MoreThanOneVerb}
    
    let meausrableVerbsURL = Bundle.main.url(forResource:"measurable_verbs", withExtension: "csv")!
//    let measurableVerbsTable:MLDataTable?
    var measurableVerbsList:[String] = []
    
//    let learningTopicsURL = Bundle.main.url(forResource:"learning_topics", withExtension: "csv")!
//    let learningTopicsTable:MLDataTable?
    var learningTopicsList:[String] = []
    
    init() {
//        self.measurableVerbsTable = try? MLDataTable(contentsOf: self.meausrableVerbsURL)
//        self.learningTopicsTable = try? MLDataTable(contentsOf: self.learningTopicsURL)
//
//        self.measurableVerbsTable?.rows.forEach{
//            row in
//            let verb:String = (row.values.first?.stringValue)!
//            measurableVerbsList.append(verb)
//        }
//        self.learningTopicsTable?.rows.forEach{
//            row in
//            let verb:String = (row.values.first?.stringValue)!
//            learningTopicsList.append(verb)
//        }
    }
    
    func tagObjective(description:String, tokens:[String], tags:[String])  {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        let options: NLTagger.Options = []
        var taggedDescription = TaggedDescription()
        tagger.string = description
        tagger.enumerateTags(in: description.startIndex..<description.endIndex, unit: .word, scheme: .lexicalClass, options: options) {
            tag, tokenRange in
            if tag != nil {
                let token = String(description[tokenRange])
                var i = 0
                var tokenFound = false
                tokens.forEach{
                    t in
                    if t == token {
                        taggedDescription.tags.append(tags[i])
                        tokenFound = true
                    }
                    i = i + 1
                }
                if !tokenFound {
                    taggedDescription.tags.append("NONE")
                }
                taggedDescription.tokens.append(token)
            }
            return true
        }
        
        self.taggedObjectives.append(taggedDescription)
        
    }
    
    func saveTaggedObjectivesToJSON() {
        let jsonEnconder = JSONEncoder()
        if let newJsonData = try? jsonEnconder.encode(self.taggedObjectives) {
            try? newJsonData.write(to: topicsTagsDataURL)
        }
    }
}

extension BloomsRevisedTaxonomyClassifier: BloomsRevisedTaxonomyClassifierProtocol {
    func checkForTopics(objective: String, onCheked checked: @escaping (String, [String]) -> Void) {
        var topics:[String] = []
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .language])
        tagger.string = objective
        
        let options: NLTagger.Options = []
        //        let tags: [NLTag] = [.noun]
        
        // 3
        tagger.enumerateTags(in: objective.startIndex..<objective.endIndex, unit: .word, scheme: .language, options: options) {
            tag, tokenRange in
            if let tag = tag {
                let topic = String(objective[tokenRange])
                //                print(">>> TOPIC LANGUAGE: \(objective[tokenRange]) \(tag.rawValue)")
                if self.learningTopicsList.contains(topic) {
                    topics.append(topic)
                }
            }
            return true
        }
        checked(objective, topics)
    }
    
    func checkForLearningTopics(objective: String, onCheked checked: @escaping (String, [String]) -> Void) {
        var res:[String] = []
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = objective
        
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        let tags: [NLTag] = [.noun, .verb]
        
        // 3
        tagger.enumerateTags(in: objective.startIndex..<objective.endIndex, unit: .word, scheme: .lexicalClass, options: options) {
            tag, tokenRange in
            if let noun = tag, tags.contains(noun) {
                let topic = String(objective[tokenRange])
                print(">>> TOPIC: \(topic) \(noun.rawValue)")
                if self.learningTopicsList.contains(topic) {
                    res.append(topic)
                }
            }
            return true
        }
        checked(objective, res)
        
    }
    
    func checkForMeasurableVerb(objective:String, onCheked checked: @escaping (String, BloomsRevisedTaxonomyClassifier.MeasurableVertStatus, [String]) -> Void) -> Void {
        var res:[String] = []
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma])
        tagger.string = objective
        
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        //        let tags: [NLTag] = [.verb]
        
        // 3
        tagger.enumerateTags(in: objective.startIndex..<objective.endIndex, unit: .word, scheme: .lemma, options: options) {
            tag, tokenRange in
            if let lemma = tag?.rawValue {
                //                print(">>> LEMMA: \(lemma)")
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
            print("Ação: \(res.first!)")
        }else if res.count > 1 {
            status = MeasurableVertStatus.MoreThanOneVerb
        }
        checked(objective, status, res)
    }
}

