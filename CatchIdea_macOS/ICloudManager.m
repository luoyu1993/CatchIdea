//
//  ICloudManager.m
//  CatchIdea
//
//  Created by Lin,Shiwei on 2017/7/7.
//  Copyright © 2017年 Linsw. All rights reserved.
//

#import "ICloudManager.h"
#import "CatchIdea_macOS-Swift.h"

//enum CKAlertLocationKey {
//    Create,
//    Update,
//    Delete
//};


//recordName is uuidString

@interface ICloudManager ()

@property CKDatabase *privateDataBase;

@end
@implementation ICloudManager

+ (instancetype)shared{
    static ICloudManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _privateDataBase = [[CKContainer defaultContainer] privateCloudDatabase];
        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.persistentContainer.viewContext;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
        
    }
    return self;
}

- (void)save{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[[NSUUID UUID] UUIDString]];
    CKRecord *ideaItemRecord = [[CKRecord alloc] initWithRecordType:ICloudDashBoardKey.recordType recordID:recordID];
    ideaItemRecord[@"addingDate"] = [NSDate date];
    ideaItemRecord[@"markColorIndex"] = [NSNumber numberWithInteger:0];
    ideaItemRecord[@"content"] = @"";
    ideaItemRecord[@"isDelete"] = false;
    ideaItemRecord[@"isFinish"] = false;
    ideaItemRecord[@"notificationDate"] = nil;
    ideaItemRecord[@"header"] = @"newnew";
//    ideaItemRecord[@"uuidString"] = [[NSUUID UUID] UUIDString];
    CKContainer *myContainer = [CKContainer defaultContainer];
    CKDatabase *privateDataBase = [myContainer privateCloudDatabase];
    
    [privateDataBase saveRecord:ideaItemRecord completionHandler:^(CKRecord *re,NSError *err){
        if (err) {
            
            return;
        }
        
        
    }];
}

- (void)subscriptionWithRecordType:(NSString *)type {
    NSPredicate *precidate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQuerySubscription *updateSub = [[CKQuerySubscription alloc] initWithRecordType:type predicate:precidate options:CKQuerySubscriptionOptionsFiresOnRecordUpdate];
    CKNotificationInfo *updateInfo = [CKNotificationInfo new];
    updateInfo.alertLocalizationKey = ICloudDashBoardKey.notificationUpdate;
    updateInfo.shouldBadge = true;
    updateSub.notificationInfo = updateInfo;
    [_privateDataBase saveSubscription:updateSub completionHandler:^(CKSubscription*sub, NSError *err){
        if (err) {
            NSLog(@"%@",err);
            return;
        }
        
    }];
    
    CKQuerySubscription *createSub = [[CKQuerySubscription alloc] initWithRecordType:type predicate:precidate options:CKQuerySubscriptionOptionsFiresOnRecordCreation];
    CKNotificationInfo *createInfo = [CKNotificationInfo new];
    createInfo.alertLocalizationKey = ICloudDashBoardKey.notificationCreate;
    createInfo.shouldBadge = true;
    createSub.notificationInfo = createInfo;
    [_privateDataBase saveSubscription:createSub completionHandler:^(CKSubscription*sub, NSError *err){
        if (err) {
            NSLog(@"%@",err);

            return;
        }
        
    }];
    CKQuerySubscription *deleteSub = [[CKQuerySubscription alloc] initWithRecordType:type predicate:precidate options:CKQuerySubscriptionOptionsFiresOnRecordDeletion];
    CKNotificationInfo *deleteInfo = [CKNotificationInfo new];
    deleteInfo.alertLocalizationKey = ICloudDashBoardKey.notificationDelete;
    deleteInfo.shouldBadge = true;
    deleteSub.notificationInfo = deleteInfo;
    [_privateDataBase saveSubscription:deleteSub completionHandler:^(CKSubscription*sub, NSError *err){
        if (err) {
            NSLog(@"%@",err);

            return;
        }
        
    }];
}

- (void)createWithRecordType:(NSString *)type contentDictionary:(NSDictionary *)dic{
    NSString *recordName = [dic valueForKey:CoreDataModelKey.uuidString];
    if (recordName == nil) {
        return;
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dictionary removeObjectForKey:CoreDataModelKey.uuidString];
    //    [dic remove]
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordName];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:type recordID:recordID];
    for(NSString *key in [dictionary allKeys]){
        record[key] = [dictionary objectForKey:key];
    }
    [_privateDataBase saveRecord:record completionHandler:^(CKRecord *re,NSError *err){
        if (err) {
            
            return;
        }
        
        
    }];
}

- (void)saveWithRecordType:(NSString *)type contentDictionary:(NSDictionary *)dic{
    NSString *recordName = [dic valueForKey:CoreDataModelKey.uuidString];
    if (recordName == nil) {
        return;
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dictionary removeObjectForKey:CoreDataModelKey.uuidString];
//    [dic remove]
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordName];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:type recordID:recordID];
    for(NSString *key in [dictionary allKeys]){
        record[key] = [dictionary objectForKey:key];
    }
    
    CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:record recordIDsToDelete:nil];
    [operation start];
    
    [_privateDataBase saveRecord:record completionHandler:^(CKRecord *re,NSError *err){
        if (err) {
            
            return;
        }
        
        
    }];
}

- (void)deleteWithRecordName:(NSString *)uuidString{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:uuidString];
    [_privateDataBase deleteRecordWithID:recordID completionHandler:^(CKRecordID *reID,NSError *err){
        if (err) {
            
            return;
        }
        
        
    }];
}

- (void)getIdeaItemDictionaryWithRecordID:(CKRecordID *)recordID withCompletion:(void (^)(NSDictionary *, BOOL))completion {
    if (!recordID) {
        completion(nil,false);
    }
    [_privateDataBase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error){
        if (error) {
            return;
        }
        NSDictionary *dic = [NSMutableDictionary dictionary];
        if (record) {
            for (NSString *key in record.allKeys) {
                [dic setValue:[record valueForKey:key] forKey:key];
            }
            [dic setValue:[[record recordID] recordName] forKey:CoreDataModelKey.uuidString];
        }
        if ([dic count] > 0) {
            NSLog(@"Fetch item from icloud with %lu keys",(unsigned long)[dic count]);
            completion(dic,true);
        }else{
            NSLog(@"Fail to fetch item from icloud");
            completion(nil,false);
        }
    }];
    
}

- (void)handleDataModelChange:(NSNotification *)note
{
    NSSet *updatedObjects = [[note userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];
    
    for (NSManagedObject *obj in updatedObjects) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [obj valueForKey:CoreDataModelKey.addingDate],CoreDataModelKey.addingDate,
                             [obj valueForKey:CoreDataModelKey.content],CoreDataModelKey.content,
                             [obj valueForKey:CoreDataModelKey.header],CoreDataModelKey.header,
                             [obj valueForKey:CoreDataModelKey.isDelete],CoreDataModelKey.isDelete,
                             [obj valueForKey:CoreDataModelKey.isFinish],CoreDataModelKey.isFinish,
                             [obj valueForKey:CoreDataModelKey.markColorIndex],CoreDataModelKey.markColorIndex,
                             [obj valueForKey:CoreDataModelKey.uuidString],CoreDataModelKey.uuidString,
                             [obj valueForKey:CoreDataModelKey.notificationDate],CoreDataModelKey.notificationDate
                             , nil];
        [self saveWithRecordType:ICloudDashBoardKey.recordType contentDictionary:dic];
    }
    
    for (NSManagedObject *obj in insertedObjects) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [obj valueForKey:CoreDataModelKey.addingDate],CoreDataModelKey.addingDate,
                             [obj valueForKey:CoreDataModelKey.content],CoreDataModelKey.content,
                             [obj valueForKey:CoreDataModelKey.header],CoreDataModelKey.header,
                             [obj valueForKey:CoreDataModelKey.isDelete],CoreDataModelKey.isDelete,
                             [obj valueForKey:CoreDataModelKey.isFinish],CoreDataModelKey.isFinish,
                             [obj valueForKey:CoreDataModelKey.markColorIndex],CoreDataModelKey.markColorIndex,
                             [obj valueForKey:CoreDataModelKey.uuidString],CoreDataModelKey.uuidString,
                             [obj valueForKey:CoreDataModelKey.notificationDate],CoreDataModelKey.notificationDate
                             , nil];
        [self saveWithRecordType:ICloudDashBoardKey.recordType contentDictionary:dic];
    }
    
    for (NSManagedObject *obj in deletedObjects) {
        NSString *recordName = [obj valueForKey:CoreDataModelKey.uuidString];
        if (recordName) {
            [self deleteWithRecordName:recordName];
        }
    }
    
//    let dic = Dictionary<String,Any>(dictionaryLiteral: ("addingDate",addingDate!),("content",content!),("header",header!),("isDelete",isDelete),("isFinish",isFinish),("markColorIndex",markColorIndex),("uuidString",uuidString!))
//    ICloudManager.shared().save(withRecordType: "IdeaItem", contentDictionary: dic)
    
}
@end
