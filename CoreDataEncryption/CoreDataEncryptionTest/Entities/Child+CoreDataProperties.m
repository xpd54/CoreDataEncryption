//
//  Child+CoreDataProperties.m
//  CoreDataEncryptionTest
//
//  Created by Prakash Ravi on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//
//

#import "Child+CoreDataProperties.h"

@implementation Child (CoreDataProperties)

+ (NSFetchRequest<Child *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Child"];
}

@dynamic age;
@dynamic name;
@dynamic father;

@end
