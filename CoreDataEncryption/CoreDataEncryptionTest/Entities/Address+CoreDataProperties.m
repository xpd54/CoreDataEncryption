//
//  Address+CoreDataProperties.m
//  CoreDataEncryptionTest
//
//  Created by Prakash Ravi on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//
//

#import "Address+CoreDataProperties.h"

@implementation Address (CoreDataProperties)

+ (NSFetchRequest<Address *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Address"];
}

@dynamic city;
@dynamic country;
@dynamic streetNumber;
@dynamic houses;

@end
