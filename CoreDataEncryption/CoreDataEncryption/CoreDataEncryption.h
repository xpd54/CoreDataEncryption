//
//  CoreDataEncryption.h
//  CoreDataEncryption
//
//  Created by Ravi Prakash on 9/7/2018.
//  Copyright © 2018 Ravi Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface CoreDataEncryption : NSObject
/**
 Set a fetchLimit for when trasfering the data from old store to new store.
 This limit defines how many entry migration context will hold before it
 save the context.
 */
@property (nonatomic, assign) NSInteger fetchLimit;

- (instancetype)init;

/**
 Setup EncryptedCoredata Stack and get working manageObjectContext.

 @param model Instance of manage object model
 @param databaseName sqlite file name with file extension.
 @param passphraseKey passphraseKey to encrypt sqlite database file.
 @return instance of manageObjectContext to read write.
 */
- (NSPersistentStoreCoordinator *)encryptedStoreCoordinatorWithModel:(NSManagedObjectModel *)model
                                                        databaseName:(NSString *)databaseName
                                                    andPassphraseKey:(NSString *)passphraseKey;

/**
 Migrate old database to encrypted coreData.

 @param model Instance of manage object model.
 @param oldDatabaseUrl old database sqlite file url.
 @param newDatabaseName new sqlite file name with extension.
 @param passphraseKey passphrasekey to encrypt sqlite database file.
 @param error instance of error if error happen during migration or setup.
 @return instance of persistentStoreCoordinator for encrypted coredata.
 */
- (NSPersistentStoreCoordinator *)migrateToEncryptedCoreDataWithModel:(NSManagedObjectModel *)model
                                                   fromOldDatabaseUrl:(NSURL *)oldDatabaseUrl
                                                      newDatabaseName:(NSString *)newDatabaseName
                                                        passphraseKey:(NSString *)passphraseKey
                                                                error:(NSError *)error;
@end
NS_ASSUME_NONNULL_END
