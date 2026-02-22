//
//  PersistenceController.swift
//  Sunny
//
//  Created by Josh Bourke on 21/2/2026.
//

import CoreData

struct PersistenceController {

    // MARK: - Shared Instances

    static let shared = PersistenceController()

    static let preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    // MARK: - Container

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Init

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SunnyDataModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData failed to load store: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save

    func save(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? container.viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            print("[PersistenceController] Save error: \(error.localizedDescription)")
        }
    }

    // MARK: - Background Context

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
}
