//
//  Child+CoreDataProperties.h
//  CoreDataEncryptionTest
//
//  Created by Prakash Ravi on 10/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//
//

#import "Child+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Child (CoreDataProperties)

+ (NSFetchRequest<Child *> *)fetchRequest;

@property (nonatomic) int32_t age;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) Person *father;

@end

NS_ASSUME_NONNULL_END
