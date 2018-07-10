//
//  CoreDataEncryptionTest.m
//  CoreDataEncryptionTest
//
//  Created by Ravi Prakash on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataEncryption.h"
#import "NSManagedObjectContext+ECDTest.h"
#import "Header.h"

@interface CoreDataEncryptionTest : XCTestCase

@end

static NSString *encryptedCoreDataName = @"com.xpd54.encryptedCoredata.sqlite";
static NSString *passphraseKey = @"com.xpd54.passphrase";

@implementation CoreDataEncryptionTest


- (void)setUp {
    [super setUp];
    // delete encryptedCoreDataName store for testSetupOfEncryptedCoreDataMode
    NSURL *storeUrl = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                               inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:encryptedCoreDataName];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:storeUrl.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error];
        if (error) {
            NSLog(@"🛑 ➡️ Error Have been occured when clean up store Error :- %@", error.description);
        }
    }
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetupOfEncryptedCoreDataModel {
    CoreDataEncryption *encryptor  = [[CoreDataEncryption alloc] init];
    NSPersistentStoreCoordinator *encryptedCordinator = [encryptor encryptedStoreCoordinatorWithModel:[self manageObjectModel]
                                                                                         databaseName:encryptedCoreDataName
                                                                                     andPassphraseKey:passphraseKey];

    NSManagedObjectContext *mainContext = [NSManagedObjectContext mainContextWithCoordinate:encryptedCordinator];
    // Test context with pushing some data and pulling it back for correctness of it's setup method
    Person *person = [[Person alloc] initWithContext:mainContext];
    Child *child = [[Child alloc] initWithContext:mainContext];
    Address *address = [[Address alloc] initWithContext:mainContext];
    House *house = [[House alloc] initWithContext:mainContext];

    NSString *name = @"test Name";
    int32_t age = 25;
    int32_t numberOfChild = 1;

    NSString *childName = @"test child";
    int32_t childAge = 5;
    NSString *houseColor = @"red";
    NSString *houseNumber = @"Ten";

    NSString *city = @"test city";
    NSString *country = @"test country";
    int32_t streetNumber = 23;



    person.name = name;
    person.age = age;
    person.numberOfChild = numberOfChild;

    child.name = childName;
    child.age = childAge;
    child.father = person;

    [person addChildObject:child];

    house.houseColor = houseColor;
    house.houseNumber = houseNumber;
    house.owner = person;

    address.city = city;
    address.country = country;
    address.streetNumber = streetNumber;
    [address addHousesObject:house];

    house.address = address;
    NSError *error = nil;
    [mainContext save:&error];
    NSAssert(!error, @"Saving main context in encrypted database cause error");

    // continue test case as save didn't created any error

    // fetch data and match with original set data

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    NSArray *result = [mainContext executeFetchRequest:request error:&error];
    // result here suppose to be holding only one
    NSAssert((result.count == 1), @"Only one result suppose to be here");
    Person *personObject = [result firstObject];
    NSSet <Child *> *children = person.child;

    // we have pushed only one child anyobject will be only one
    Child *childObject = children.anyObject;
    NSAssert((children.count == numberOfChild), @"child count should be 1 cause we added only one");
    NSString * (^assertBlock)(NSString *, NSString *) = ^NSString *(NSString *entity, NSString *attribute) {
        return [NSString stringWithFormat:@"Pulled out data from %@ %@ should be same", entity, attribute];
    };

    NSAssert([personObject.name isEqualToString:name], assertBlock(@"Person", @"name"));
    NSAssert((personObject.age == age), assertBlock(@"Person", @"age"));
    NSAssert([childObject.name isEqualToString:childName], assertBlock(@"Child", @"name"));
    NSAssert([[childObject.father objectID] isEqual:[person objectID]], @"Both child father and person should be pointing to same object");
}

- (NSManagedObjectModel *)manageObjectModel {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *modelResource = [testBundle URLForResource:@"TestModel" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelResource];
}

@end
