//
//  NSManagedObjectContext+ECDTest.h
//  CoreDataEncryptionTest
//
//  Created by Ravi Prakash on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (ECDTest)
+ (NSManagedObjectContext *)mainContextWithCoordinate:(NSPersistentStoreCoordinator *)coordinator;
@end
