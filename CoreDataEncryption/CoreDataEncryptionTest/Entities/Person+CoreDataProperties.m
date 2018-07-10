//
//  Person+CoreDataProperties.m
//  CoreDataEncryptionTest
//
//  Created by Prakash Ravi on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//
//

#import "Person+CoreDataProperties.h"

@implementation Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Person"];
}

@dynamic age;
@dynamic name;
@dynamic numberOfChild;
@dynamic child;
@dynamic house;

@end
