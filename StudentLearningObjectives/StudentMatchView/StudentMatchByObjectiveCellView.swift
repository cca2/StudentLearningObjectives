//
//  StudentMatchByObjectiveCellView.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 07/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa

class StudentMatchByObjectiveCellView: NSTableCellView {
    @IBOutlet weak var studentName: NSTextField!
    
    @IBOutlet weak var objectiveDescription: NSTextField!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
