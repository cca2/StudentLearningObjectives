//
//  IntelligentFeedbackController.swift
//  StudentLearningObjectives
//
//  Created by Cristiano Araújo on 07/11/18.
//  Copyright © 2018 Cristiano Araújo. All rights reserved.
//

import Cocoa

class IntelligentFeedbackController: NSPageController {
    
    @IBOutlet weak var studentMatchByObjectiveList: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.studentMatchByObjectiveList.dataSource = self
        self.studentMatchByObjectiveList.delegate = self
        
        self.studentMatchByObjectiveList.register(NSNib(nibNamed: "StudentMatchByObjectiveCellView", bundle: .main), forIdentifier: NSUserInterfaceItemIdentifier("StudentMatchByObjectiveCellID"))
    }
    
}

extension IntelligentFeedbackController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100.0
    }
}

extension IntelligentFeedbackController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableView == self.studentMatchByObjectiveList) {
            let cellIdentifier = "StudentMatchByObjectiveCellID"
            
            if tableColumn == tableView.tableColumns[0] {
//                if let objective = self.elementsToDisplay[row].objective {
//                    cellIdentifier = "ObjectiveCellID"
                    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as?  StudentMatchByObjectiveCellView {
//                        cell.fitForObjective(objective: objective)
                        return cell
                    }
//                }
            }
        }
        return nil
    }

}
