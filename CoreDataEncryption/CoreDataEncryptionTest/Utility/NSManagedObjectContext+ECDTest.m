//
//  NSManagedObjectContext+ECDTest.m
//  CoreDataEncryptionTest
//
//  Created by Ravi Prakash on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//

#import "NSManagedObjectContext+ECDTest.h"

@implementation NSManagedObjectContext (ECDTest)
+ (NSManagedObjectContext *)mainContextWithCoordinate:(NSPersistentStoreCoordinator *)coordinator {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:coordinator];
    });
    return context;
}
@end
