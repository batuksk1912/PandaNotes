//
//  CoreDataManager.swift
//  PandaNotes
//
//  Created by Baturay Kayatürk on 2019-07-24.
//  Copyright © 2019 Lambton College. All rights reserved.
//

import CoreData

struct CoreDataManager {

    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PandaNotes")
        container.loadPersistentStores(completionHandler: { (storeDescription, err) in
            if let err = err {
                fatalError("Loading of data failed: \(err)")
            }
        })
        return container
    }()
    
    func createNoteCategory(title: String) -> NoteCategory {
        let context = persistentContainer.viewContext
        
        let newNoteCategory = NSEntityDescription.insertNewObject(forEntityName: "NoteCategory", into: context) as! NoteCategory
        
        newNoteCategory.title = title
        //newNoteCategory.setValue(title, forKey: "title")
        
        do {
            try context.save()
            return newNoteCategory
        } catch let err {
            print("Failed to save new note category:",err)
            return newNoteCategory
        }
    }
    
    func fetchNoteCategories() -> [NoteCategory] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NoteCategory>(entityName: "NoteCategory")
        
        do {
            let noteCategory = try context.fetch(fetchRequest)
            return noteCategory
        } catch let err {
            print("Failed to fetch more note category:",err)
            return []
        }
    }
    
    func deleteNoteCategories(noteCategory: NoteCategory) -> Bool {
        let context = persistentContainer.viewContext
        
        context.delete(noteCategory)
        
        do {
            try context.save()
            return true
        } catch let err {
            print("Error deleting note category entity instance",err)
            return false
        }
    }
    
   
    
    

}

