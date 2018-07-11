//
//  Person+CoreDataProperties.h
//  CoreDataEncryptionTest
//
//  Created by Prakash Ravi on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//
//

#import "Person+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest;

@property (nonatomic) int32_t age;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int32_t numberOfChild;
@property (nullable, nonatomic, retain) NSSet<Child *> *child;
@property (nullable, nonatomic, retain) NSSet<House *> *house;

@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addChildObject:(Child *)value;
- (void)removeChildObject:(Child *)value;
- (void)addChild:(NSSet<Child *> *)values;
- (void)removeChild:(NSSet<Child *> *)values;

- (void)addHouseObject:(House *)value;
- (void)removeHouseObject:(House *)value;
- (void)addHouse:(NSSet<House *> *)values;
- (void)removeHouse:(NSSet<House *> *)values;

@end

NS_ASSUME_NONNULL_END
