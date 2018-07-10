//
//  CoreDataMigrationTest.m
//  CoreDataEncryptionTest
//
//  Created by Ravi Prakash on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataEncryption.h"
#import "Header.h"
#import "NSManagedObjectContext+ECDTest.h"
static NSString *DATABASE_NAME = @"database";
static NSString *DATABASE_EXTENTION = @"sqlite";
static NSString *ENCRYPTED_DATABASE_FILE_NAME = @"Encrypted.sqlite";

@interface CoreDataMigrationTest : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;
@end

@implementation CoreDataMigrationTest

- (void)setUp {
    [super setUp];
    // Delete document directory for old database before start test

    NSURL *documentDirectory = [self urlOfFileInDocumentDirectory:[self databaseFileName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentDirectory.path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:documentDirectory.path error:&error];
        NSAssert(!error, @"There was an error while cleaning document directory");
    }

    // Delete encrypted database as well if that exist

    NSURL *encyptedDatabaseUrl = [self urlOfFileInDocumentDirectory:ENCRYPTED_DATABASE_FILE_NAME];
    if ([[NSFileManager defaultManager] fileExistsAtPath:encyptedDatabaseUrl.path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:encyptedDatabaseUrl.path error:&error];
        NSAssert(!error, @"There was an error while cleaning encrypted database");
    }

}

- (void)tearDown {
    [super tearDown];
}


/**
 There is preloaded sqlite database, which later get copied in document directory.
 That preloaded sqlite database will get migrated into encrypted store.
 Preloaded database have 200K tables.
 */
- (void)testECDMigration {

    // copy big dataBase to document directory before start testing
    CoreDataEncryption *encryptor = [[CoreDataEncryption alloc] init];
    encryptor.fetchLimit = 10000;
    NSError *error = nil;
    // Do migration for database
    [encryptor migrateToEncryptedCoreDataWithModel:[self manageObjectModel]
                                fromOldDatabaseUrl:[self copyDataIfRequired]
                                   newDatabaseName:ENCRYPTED_DATABASE_FILE_NAME
                                     passphraseKey:@"test"
                                             error:error];

    //get Encrypted store coordinator
    NSPersistentStoreCoordinator *storeCoordinator = [encryptor encryptedStoreCoordinatorWithModel:[self manageObjectModel]
                                                                                      databaseName:ENCRYPTED_DATABASE_FILE_NAME
                                                                                  andPassphraseKey:@"test"];

    // get Encrypted Context for coordinator
    NSManagedObjectContext *encryptedContext = [NSManagedObjectContext mainContextWithCoordinate:storeCoordinator];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOfChild=2 && age>30 && age<100"];

    NSFetchRequest *encryptedRequst = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    [encryptedRequst setPredicate:predicate];
    encryptedRequst.fetchBatchSize = 50;

    // sort the result according to age
    encryptedRequst.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    NSArray *enryptedResult = [encryptedContext executeFetchRequest:encryptedRequst error:&error];

    // get main context for plain coordinator
    NSManagedObjectContext *context = [self getMainContextWithCoordinate:[self storeCoordinator]];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    [request setPredicate:predicate];

    // sort the result according to age
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    request.fetchBatchSize = 50;
    NSArray *result = [context executeFetchRequest:request error:&error];


    NSAssert(enryptedResult.count == result.count, @"Both fetched result counts are not equal");

    NSString * (^assertBlock)(NSString *, NSInteger) = ^NSString *(NSString *entityName, NSInteger index) {
        return [NSString stringWithFormat:@"Both Person %@ is not equal for row %ld", entityName, index];
    };


    // if they are all sorted both attribute value should be equal
    for (NSInteger i = 0; i < result.count; i++) {
        Person *encryptedPerson = [enryptedResult objectAtIndex:i];
        Person *plainPerson = [result objectAtIndex:i];

        NSAssert(encryptedPerson.age == plainPerson.age, assertBlock(@"age", i));
        NSAssert([encryptedPerson.name isEqualToString:plainPerson.name], assertBlock(@"person", i));
        NSAssert(encryptedPerson.numberOfChild == plainPerson.numberOfChild, assertBlock(@"numberOfChild", i));
    }

}


- (NSString *)databaseFileName {
    return [NSString stringWithFormat:@"%@.%@", DATABASE_NAME, DATABASE_EXTENTION];
}

-(NSManagedObjectContext *)getMainContextWithCoordinate:(NSPersistentStoreCoordinator *)storeCoordinator {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:storeCoordinator];
    });
    return context;
}

#pragma mark Test Data generator
// Keeping this method here to create huge database for later update of testing data.
- (void)setupDataBigDataBase {
    [self setUpContext];
    NSManagedObjectContext *backgroundContext = self.backgroundContext;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContextSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    [self.backgroundContext performBlockAndWait:^{
        for (int32_t i = 0; i < 200000; i++) {
            @autoreleasepool {
                Person *person = [[Person alloc] initWithContext:backgroundContext];
                House *house = [[House alloc] initWithContext:backgroundContext];
                Address *address = [[Address alloc] initWithContext:backgroundContext];

                // populate data
                person.age = i;
                person.name = [NSString stringWithFormat:@"Name %d", i];
                int32_t childCount = i % 3;
                person.numberOfChild = childCount;
                for(int32_t counter = 1; counter <= childCount; counter++) {
                    Child *child = [[Child alloc] initWithContext:backgroundContext];
                    child.age = i % 3;
                    child.name = [NSString stringWithFormat:@"Child %d", child.age];
                    child.father = person;
                    [person addChildObject:child];
                }
                address.city = [NSString stringWithFormat:@"City Number %d", i];
                address.country = [NSString stringWithFormat:@"Country Number %d", i];
                address.streetNumber = i;
                [address addHousesObject:house];

                house.houseColor = [NSString stringWithFormat:@"%dth Shades Red", i];
                house.houseNumber = [NSString stringWithFormat:@"House number %@", [NSDate date]];
                house.owner = person;
                house.address = address;

                if (i % 1000 == 0) {
                    [self saveBackgroundContext];
                    NSLog(@"%d", i);
                }
            }
        }

        [self saveBackgroundContext];
    }];
}

- (void)saveBackgroundContext {
    NSError *error = nil;
    if (![self.backgroundContext save:&error]) {
        NSLog(@"Unresolved error for first manageObject %@, %@", error, error.userInfo);
        abort();
    }
    [self.backgroundContext reset];
}

- (void)handleContextSaved:(NSNotification *)notification {
    NSManagedObjectContext *sender = (NSManagedObjectContext *)notification.object;
    if ([sender isEqual:self.backgroundContext]) {
        [self.mainContext performBlockAndWait:^{
            [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
            NSError *error = nil;
            [self.mainContext save:&error];
            NSLog(@"Merge to main");
        }];
    }
}

- (void)setUpContext {
    self.mainContext = [self contextForDataBase];
    self.backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.backgroundContext.parentContext = self.mainContext;
    self.mainContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
}

- (NSManagedObjectContext *)contextForDataBase {
    return [NSManagedObjectContext mainContextWithCoordinate:[self storeCoordinator]];
}

- (NSPersistentStoreCoordinator *)storeCoordinator {
    NSError *error = nil;
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self manageObjectModel]];
    NSURL *databaseStore = [self copyDataIfRequired];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:databaseStore
                                    options:nil
                                      error:&error];
    if (error) {
        // log error message
        return nil;
    }
    NSLog(@"Database URL %@", databaseStore);
    return coordinator;
}

- (NSURL *)copyDataIfRequired  {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *urlForDatabase = [bundle URLForResource:DATABASE_NAME withExtension:DATABASE_EXTENTION];
    NSAssert(urlForDatabase, @"Test db in bundle is missing");
    NSURL *documentDirectory = [self urlOfFileInDocumentDirectory:[self databaseFileName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentDirectory.path]) {
        NSError *error = nil;
        if ([[NSFileManager defaultManager] copyItemAtURL:urlForDatabase toURL:documentDirectory error:&error]) {
            return documentDirectory;
        }
        NSAssert(!error, @"Error happened while copying testDatabase");
    } else {
        // file already exist in documentDirectory
        return documentDirectory;
    }
    return nil;
}

- (NSManagedObjectModel *)manageObjectModel {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *modelResource = [testBundle URLForResource:@"TestModel" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelResource];
}

- (NSURL *)urlOfFileInDocumentDirectory:(NSString *)fileName {
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                    inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:fileName];
}

@end
