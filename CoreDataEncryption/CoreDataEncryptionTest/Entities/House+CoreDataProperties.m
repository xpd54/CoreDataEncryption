//
//  House+CoreDataProperties.m
//  CoreDataEncryptionTest
//
//  Created by Prakash Ravi on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//
//

#import "House+CoreDataProperties.h"

@implementation House (CoreDataProperties)

+ (NSFetchRequest<House *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"House"];
}

@dynamic houseColor;
@dynamic houseNumber;
@dynamic address;
@dynamic owner;

@end
