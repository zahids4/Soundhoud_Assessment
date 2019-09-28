//
//  HelloWorldTableViewController.swift
//  Soundhoud_Assessment
//
//  Created by Saim Zahid on 2019-09-27.
//  Copyright © 2019 Saim Zahid. All rights reserved.
//

import UIKit

class HelloWorldTableViewController: UITableViewController {
    fileprivate var helloWorldTextArray = [HelloWorldText]()
    fileprivate let operations = CpuExtensiveOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildIntialData()
    }
    
    fileprivate func buildIntialData() {
        helloWorldTextArray = [HelloWorldText](repeating: HelloWorldText(), count: 100)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helloWorldTextArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helloWorldCell", for: indexPath) as! HelloWorldCell
        
        let helloWorldText = helloWorldTextArray[indexPath.row]
        
        cell.setCellToBoldIfRequired(helloWorldText.isTextBolded)

        if !helloWorldText.isTextBolded && !tableView.isDragging && !tableView.isDecelerating {
            startCpuExtensiveOperation(for: helloWorldText, at: indexPath)
        }
        
        return cell
    }
    
    
    fileprivate func startCpuExtensiveOperation(for text: HelloWorldText, at indexPath: IndexPath) {
        guard operations.operationsInProgress[indexPath] == nil else {
            return
        }
        
        let operation = CpuExtensiveOperation(helloWorldTextArray[indexPath.row])
        
        operation.completionBlock = {
            if operation.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.helloWorldTextArray[indexPath.row].isTextBolded = operation.helloWorldText.isTextBolded
                self.operations.operationsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    
        operations.operationsInProgress[indexPath] = operation
        operations.operationQueue.addOperation(operation)
    }
}


//This is not needed but makes it much more efficient when scrolling.
extension HelloWorldTableViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        shoudSuspendOperations(true)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            resumeOperationsForVisibleCells()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resumeOperationsForVisibleCells()
    }
    
    fileprivate func resumeOperationsForVisibleCells() {
        performTaskOnlyForVisibleCells()
        shoudSuspendOperations(false)
    }
    
    fileprivate func shoudSuspendOperations(_ isSuspended: Bool) {
        operations.operationQueue.isSuspended = isSuspended
    }
    
    fileprivate func performTaskOnlyForVisibleCells() {
        if let indexPathsForVisibleCells = tableView.indexPathsForVisibleRows {
            let allPendingOperations = Set(operations.operationsInProgress.keys)
        
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(indexPathsForVisibleCells)
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingOperation = operations.operationsInProgress[indexPath] {
                    pendingOperation.cancel()
                }
                
                operations.operationsInProgress.removeValue(forKey: indexPath)
            }
            
            for indexPath in toBeStarted {
                let text = helloWorldTextArray[indexPath.row]
                startCpuExtensiveOperation(for: text, at: indexPath)
            }
        }
    }
}

