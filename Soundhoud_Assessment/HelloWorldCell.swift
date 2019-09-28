//
//  HelloWorldCell.swift
//  Soundhoud_Assessment
//
//  Created by Saim Zahid on 2019-09-27.
//  Copyright © 2019 Saim Zahid. All rights reserved.
//

import UIKit

class HelloWorldCell: UITableViewCell {
    @IBOutlet weak var helleWorldLabel: UILabel!
    
    func setCellToBoldIfRequired(_ isFontBolded: Bool) {
        DispatchQueue.main.async {
            if isFontBolded {
                self.helleWorldLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            } else {
                self.helleWorldLabel?.font = UIFont.systemFont(ofSize: 16.0)
            }
        }
    }
    
}
