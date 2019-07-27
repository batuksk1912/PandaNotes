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
    
    func createNewNote(title: String, date: Date, text: String, lat: Double, lng: Double, noteCategory: NoteCategory) -> Note {
        let context = persistentContainer.viewContext
        
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
        
        newNote.title = title
        newNote.text = text as! NSData
        newNote.date = date
        newNote.lat = lat
        newNote.lng = lng
        newNote.noteCategory = noteCategory
        
        do {
            try context.save()
            return newNote
        } catch let err {
            print("Failed to save new note folder:",err)
            return newNote
        }
    }
    
    func fetchNotes(from categoryData: NoteCategory) -> [Note] {
        guard let categoryNotes = categoryData.notes?.allObjects as? [Note] else { return [] }
        return categoryNotes
    }
    
    func deleteNote(note: Note) -> Bool {
        let context = persistentContainer.viewContext
        
        context.delete(note)
        
        do {
            try context.save()
            return true
        } catch let err {
            print("Error deleting note entity instance",err)
            return false
        }
    }
    
    func saveUpdatedNote(note: Note, newText: NSData, newLat: Double, newLng: Double) {
        let context = persistentContainer.viewContext
        
        note.title = "Deneme"
        note.text = newText
        note.date = Date()
        note.lat = newLat
        note.lng = newLng
        
        do {
            try context.save()
        } catch let err {
            print("Error updating note",err)
        }
        
    }
    
    func checkIfCategoryExist(title: String) -> Bool {
        
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NoteCategory>(entityName: "NoteCategory")
        fetchRequest.fetchLimit =  1
        fetchRequest.predicate = NSPredicate(format: "title == %@" ,title)
        do {
            let count = try managedContext.count(for: fetchRequest)
            if count > 0 {
                return true
            }else {
                return false
            }
        }catch let error as NSError {
            print("Could not fetch categories. \(error), \(error.userInfo)")
            return false
        }
    }
}

