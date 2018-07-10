//
//  Address+CoreDataProperties.h
//  CoreDataEncryptionTest
//
//  Created by Prakash Ravi on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//
//

#import "Address+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Address (CoreDataProperties)

+ (NSFetchRequest<Address *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *country;
@property (nonatomic) int32_t streetNumber;
@property (nullable, nonatomic, retain) NSSet<House *> *houses;

@end

@interface Address (CoreDataGeneratedAccessors)

- (void)addHousesObject:(House *)value;
- (void)removeHousesObject:(House *)value;
- (void)addHouses:(NSSet<House *> *)values;
- (void)removeHouses:(NSSet<House *> *)values;

@end

NS_ASSUME_NONNULL_END
