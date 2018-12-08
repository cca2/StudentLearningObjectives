//
//  LinkedList.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 08/12/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Foundation

class Node<T>: NSObject {
    var value: T?
    var next: Node?
    
    override init() {
        super.init()
    }
    
    convenience init(value: T, next: Node? = nil) {
        self.init()
        self.value = value
        self.next = next
    }
}

class LinkedList<T> {
    var parentNode: Node<T>?
    var lastNode: Node<T>?
    
    convenience init(withElements elements: [T]) {
        self.init()
        createLinkedListWithElements(elements: elements)
    }
    
    private func createLinkedListWithElements(elements:[T]) {
        for i in 0..<elements.count {
            if parentNode == nil {
                parentNode = Node.init(value: elements[i], next: nil)
                lastNode = parentNode
            }else {
                lastNode?.next = Node.init(value: elements[i], next: nil)
                lastNode = lastNode?.next
            }
        }
    }
    
    func appendElements(elements:[T]) {
        createLinkedListWithElements(elements: elements)
    }
    
    func appendElement(element:T) {
        let elements:[T] = [element]
        createLinkedListWithElements(elements: elements)
    }
}

class ObjectiveLinkedList:LinkedList<StudentLearningObjective> {
    
    func index(indexFor objective:StudentLearningObjective) -> Int {
        if parentNode == nil {
            return -1
        }
        
        var index = 0
        var tempLastNode = parentNode
        
        while(true) {
            if let value = tempLastNode?.value {
                if value === objective {
                    return index
                }else {
                    index = index + 1
                    tempLastNode = tempLastNode?.next
                }
            }
            
            if (tempLastNode === lastNode) {
                return -1
            }
        }
    }
}
