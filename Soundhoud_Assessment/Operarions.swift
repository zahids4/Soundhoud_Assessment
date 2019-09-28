//
//  Operarions.swift
//  Soundhoud_Assessment
//
//  Created by Saim Zahid on 2019-09-27.
//  Copyright © 2019 Saim Zahid. All rights reserved.
//

import Foundation

fileprivate typealias voidClosure = () -> ()
fileprivate let sleepTime: useconds_t = 2000000

class CpuExtensiveOperations {
    lazy var operationsInProgress: [IndexPath: CpuExtensiveOperation] = [:]
    lazy var operationQueue = OperationQueue()
}

class CpuExtensiveOperation: Operation {
    var helloWorldText: HelloWorldText
    
    init(_ helloWorldText: HelloWorldText) {
        self.helloWorldText = helloWorldText
    }
    
    override func main() {
        if isCancelled { return }

        performTask() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.isCancelled { return }
                self.helloWorldText.isTextBolded = true
            }
        }
    }
    
    fileprivate func performTask(closure: @escaping voidClosure) {
        usleep(sleepTime)
        closure()
    }
}
