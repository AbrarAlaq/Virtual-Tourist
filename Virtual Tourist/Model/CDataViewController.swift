//
//  CDataViewController.swift

//
//  Created by ابرار on ٢٧ جما١، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Udacity. All rights reserved.

import Foundation
import CoreData

class CDataViewController{
    let PVContainer:NSPersistentContainer
    
    var Context:NSManagedObjectContext {
        return PVContainer.viewContext
    }
    
    var backgroundContext:NSManagedObjectContext!
    
    init(modelName:String) {
        PVContainer = NSPersistentContainer(name: modelName)
        
    }
    
    func setContext(){
        backgroundContext = PVContainer.newBackgroundContext()
        
        Context.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
      Context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func loadingContext(completion: (() -> Void)? = nil) {
        PVContainer.loadPersistentStores {
            storeDescripation , error in
            guard error == nil else {
                fatalError(error as! String)
            }
            self.SaveContexts()
            self.setContext()
            completion?()
        }
    }
    
    
    func SaveContexts(interval:TimeInterval = 30){
        
        guard interval > 0 else {
            return
        }
        if Context.hasChanges {
            try? Context.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.SaveContexts(interval: interval)
        }
    }
}




