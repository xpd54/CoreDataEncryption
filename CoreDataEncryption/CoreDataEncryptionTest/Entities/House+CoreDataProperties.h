//
//  House+CoreDataProperties.h
//  CoreDataEncryptionTest
//
//  Created by Prakash Ravi on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//
//

#import "House+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface House (CoreDataProperties)

+ (NSFetchRequest<House *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *houseColor;
@property (nullable, nonatomic, copy) NSString *houseNumber;
@property (nullable, nonatomic, retain) Address *address;
@property (nullable, nonatomic, retain) Person *owner;

@end

NS_ASSUME_NONNULL_END
