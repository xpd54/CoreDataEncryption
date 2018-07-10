//
//  CoreDataEncryption.m
//  CoreDataEncryption
//
//  Created by Ravi Prakash on 9/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//

#import "CoreDataEncryption.h"
#import "EncryptedStore.h"

@interface CoreDataEncryption()
@property (nonatomic, strong) NSMutableDictionary *lookupTable;
@property (nonatomic, strong) NSManagedObjectContext *nonEncryptedContext;
@property (nonatomic, strong) NSManagedObjectContext *encryptedContext;
@end

@implementation CoreDataEncryption

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _lookupTable = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSPersistentStoreCoordinator *)encryptedStoreCoordinatorWithModel:(NSManagedObjectModel *)model
                                                        databaseName:(NSString *)databaseName
                                                    andPassphraseKey:(NSString *)passphraseKey {
    return [self persistentStoreCoordinatorForManageObjectModel:model
                                                   databaseName:databaseName
                                               andPassphraseKey:passphraseKey];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorForManageObjectModel:(NSManagedObjectModel *)model
                                                                    databaseName:(NSString *)databaseName
                                                                andPassphraseKey:(NSString *)passphraseKey {
    NSURL *storeUrl = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                               inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:databaseName];
    NSDictionary *options =  @{EncryptedStorePassphraseKey: passphraseKey,
                               EncryptedStoreDatabaseLocation: storeUrl
                               };
    NSPersistentStoreCoordinator *coordinator = nil;
    if (model) {
        coordinator = [EncryptedStore makeStoreWithOptions:options managedObjectModel:model];
    }
    return coordinator;
}

- (NSPersistentStoreCoordinator *)migrateToEncryptedCoreDataWithModel:(NSManagedObjectModel *)model
                                                   fromOldDatabaseUrl:(NSURL *)oldDatabaseUrl
                                                      newDatabaseName:(NSString *)newDatabaseName
                                                        passphraseKey:(NSString *)passphraseKey
                                                                error:(NSError *)error {
    // get coordinator for old DatabaseUrl
    NSPersistentStoreCoordinator *oldStoreCoordinator = [self persistentCoordinatorForDatabaseUrl:oldDatabaseUrl
                                                                            andManagedObjectModel:model];

    // get encrypted Store coordinate with newDatabaseName and passphraseKey
    NSPersistentStoreCoordinator *encryptedStoreCoordinator = [self encryptedStoreCoordinatorWithModel:model
                                                                                          databaseName:newDatabaseName
                                                                                      andPassphraseKey:passphraseKey];
    return  [self moveDataFromNonEncryptedCoordinator:oldStoreCoordinator
                               toEncryptedCoordinator:encryptedStoreCoordinator
                                       forObjectModel:model
                                                error:error];

}


- (NSPersistentStoreCoordinator *)moveDataFromNonEncryptedCoordinator:(NSPersistentStoreCoordinator *)nonEncryptedCoordinator
                                               toEncryptedCoordinator:(NSPersistentStoreCoordinator *)encryptedStoreCoordinator
                                                       forObjectModel:(NSManagedObjectModel *)model
                                                                error:(NSError *)error {
    // get context for old database store
    self.nonEncryptedContext = [self contextForNonEncryptedCoordinator:nonEncryptedCoordinator];
    self.encryptedContext = [self contextForEncryptedCoordinator:encryptedStoreCoordinator];
    self.encryptedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    self.encryptedContext.retainsRegisteredObjects = YES;
    NSArray *entities = [model entitiesByName].allKeys;
    for (NSString *entity in entities) {
        @autoreleasepool {
            NSInteger loopThrough = 0;
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entity];
            NSInteger fetchCount = self.fetchLimit;
            request.fetchLimit = fetchCount;
            NSArray *result = nil;

            while ((result = [self.nonEncryptedContext executeFetchRequest:request error:&error]) && result.count > 0) {
                loopThrough++;
                // exicuting fetch request made error whole data move gonna be crupted even if we save
                // So stop moving here and return nil
                if (error) {
#warning Add Log error here.
                    // Log Error here
                    return nil;
                }

                for(NSManagedObject *child in result) {
                    [self copyObject:child toContext:self.encryptedContext withParentEntityName:entity];
                }
                [self saveEncryptedContext:self.encryptedContext withError:error];
                [self.nonEncryptedContext reset];
                // error already happen while saving, no need to move further.
                if (error) {
#warning Add Log error here.
                    return nil;
                }
                request.fetchOffset = fetchCount * loopThrough;
            }
        }
    }

    // No error everything goes well and data have been move to encrypted data store
    if (error) {
#warning Add Log error here.
        return nil;
    } else {
        return encryptedStoreCoordinator;
    }
}

- (NSPersistentStoreCoordinator *)persistentCoordinatorForDatabaseUrl:(NSURL *)databaseUrl
                                                andManagedObjectModel:(NSManagedObjectModel *)model {
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:databaseUrl.path]) {
        NSURL *docUrl = [databaseUrl URLByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:docUrl.path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:databaseUrl
                                    options:nil
                                      error:&error];
    if (error) {
        // log error message
        return nil;
    }
    return coordinator;
}

- (NSManagedObjectContext *)contextForEncryptedCoordinator:(NSPersistentStoreCoordinator *)coordinator {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:coordinator];
    });
    return context;
}

- (NSManagedObjectContext *)contextForNonEncryptedCoordinator:(NSPersistentStoreCoordinator *)coordinator {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:coordinator];
    });
    return context;
}

- (void)saveEncryptedContext:(NSManagedObjectContext *)encryptedContext withError:(NSError *)error {
    if ([encryptedContext hasChanges] && ![encryptedContext save:&error]) {
        NSLog(@"Unresolved error for second manageObject%@, %@", error, error.userInfo);
        abort();
    }
    [encryptedContext reset];
}

// Recursively copy object into manageObjectContext
// This is based on graph travel algo
// where we copy the object recursively in manageObjectContext.
- (NSManagedObject*)copyObject:(NSManagedObject *)object
                     toContext:(NSManagedObjectContext *)manageObjectContext
          withParentEntityName:(NSString *)parentEntityName {

    NSString *entityName = [[object entity] name];

    NSManagedObject *newObject = nil;

    // before creating new object check for lookuptable if that is already got into context.
    NSManagedObject *lookUpObject = [[self lookupTable] objectForKey:[object objectID]];
    if (lookUpObject) {
        return lookUpObject;
    }

    newObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                              inManagedObjectContext:manageObjectContext];
    [[self lookupTable] setObject:newObject forKey:[object objectID]];
    NSArray *attributeKeys = [[[object entity] attributesByName] allKeys];
    NSDictionary *attributes = [object dictionaryWithValuesForKeys:attributeKeys];

    // set all attribute data in new object
    [newObject setValuesForKeysWithDictionary:attributes];

    id oldDestinationObject = nil;
    id temp = nil;
    NSDictionary *relationships = [[object entity] relationshipsByName];
    for (NSString *key in [relationships allKeys]) {

        NSRelationshipDescription *description = [relationships valueForKey:key];
        NSString *destinationEntityName = [[description destinationEntity] name];

        //Already reach made a circle in graph and reach to same entity
        if ([destinationEntityName isEqualToString:parentEntityName])
            continue;

        // This is one to many relationship, get all the value for this relationship
        if ([description isToMany]) {
            // If it's a one to many relationship then it's gonna be a set of values.
            NSMutableSet *newDestinationSet = [NSMutableSet set];

            for (oldDestinationObject in [object valueForKey:key]) {

                // check in lookup table to avoid duplicates
                temp = [[self lookupTable] objectForKey:[oldDestinationObject objectID]];
                if (!temp) {
                    // if it's not in lookup table then we have to go through all of it's relations and attributes.
                    temp = [self copyObject:oldDestinationObject
                                  toContext:manageObjectContext
                       withParentEntityName:entityName];
                }
                [newDestinationSet addObject:temp];
            }

            // Set new Destinationset, which include all it's relationships data sets.
            [newObject setValue:newDestinationSet forKey:key];
        } else {

            oldDestinationObject = [object valueForKey:key];

            // if oldDestinationObject is nil, then no relationship data exist.
            if (!oldDestinationObject)
                continue;

            // check if it's alreay in lookup table, if it's there then we already have been through this.
            temp = [[self lookupTable] objectForKey:[oldDestinationObject objectID]];

            // As manageObject context is week pointer to object.
            // It can loose context for object if that happen recover from existing context
            if (![temp managedObjectContext] && temp) {
                temp = [manageObjectContext objectWithID:[temp objectID]];
            }
            // If it's not in lookup table then recursively copy into context.
            if (!temp && ![destinationEntityName isEqualToString:parentEntityName]) {
                temp = [self copyObject:oldDestinationObject
                              toContext:manageObjectContext
                   withParentEntityName:entityName];
            }

            [newObject setValue:temp forKey:key];
        }
    }
    return newObject;
}
@end
