//
//  HsBaseFetchedResults.m
//  hospitalcloud_sc
//
//  Created by 王金东 on 14-10-27.
//  Copyright (c) 2014年 chenjiong. All rights reserved.
//

#import "HsBaseFetchedResults.h"

NSString *const HsBaseFetchedResultManagedObjectChangeNotification = @"HsBaseFetchedResultManagedObjectChangeNotification";

@interface HsBaseFetchedResults ()

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation HsBaseFetchedResults{
    BaseFetchedResultDataChangeBlock _changeDataBlock;
}



static NSString *defaultMomdName;//设置文件名称
static NSString *defaultSqliteName;//设置数据库名称 不设置默认为


//设置默认文件名称  也就是momdName不设置会使用该值
+ (void)setDefaultMomdName:(NSString *)momdName {
    defaultMomdName = momdName;
}

//设置默认数据库名称  也就是sqliteName不设置会使用该值
+ (void)setDefaultSqliteName:(NSString *)sqliteName {
    defaultSqliteName = sqliteName;
}

/**
 *
 * 注册一个更改信息后的提示
 */
- (void)registerObjectChange:(BaseFetchedResultDataChangeBlock)changeBlock {
    _changeDataBlock = [changeBlock copy];
}

#pragma mark ------------------增加------------------------
//插入一个实体
- (NSManagedObject *)insertEntity:(NSDictionary *)entityDic {
    NSAssert(self.entityName, @"要先设置entityName名称");
    NSManagedObject *entity = [self buildManagedObjectByName:self.entityName];
    //赋值
    [self setContentDictionary:entityDic toEntity:entity];
    //保存
    NSError *error = [self save];
    if (error == nil) {
        return entity;
    }
    return nil;
}

//插入多个实体
- (NSArray *)insertEntitys:(NSArray *)entityArray {
    NSMutableArray *objectArray = [NSMutableArray array];
    for(NSDictionary *entityDic in entityArray){
        if([entityDic isKindOfClass:[NSDictionary class]]){
            NSManagedObject *entity = [self buildManagedObjectByName:self.entityName];
            //赋值
            [self setContentDictionary:entityDic toEntity:entity];
            [objectArray addObject:entity];
        }else{
            [objectArray addObject:entityDic];
        }
    }
    //保存
    NSError *error = [self save];
    if (error == nil) {
        return objectArray;
    }
    return nil;
}

//扩展方法 将key字符串里面在第一个字母大写
- (NSString *)upHeadString:(NSString *)string {
    return [[[string substringToIndex:1] uppercaseString] stringByAppendingString:[string substringFromIndex:1]];
}

//给entity赋值
- (void)setContentDictionary:(NSDictionary *)dictionary  toEntity:(NSManagedObject *)entity {
    for (NSString *key in [dictionary allKeys])
    {
        id value = [dictionary objectForKey:key];
        
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDate class]]){
            @try {
                [entity setValue:value forKey:key];
            }
            @catch (NSException *exception) {
                NSLog(@"解析基本类型出错了-->%@",exception);
            }
            
        }else if ([value isKindOfClass:[NSDictionary class]]){
            @try {
                NSEntityDescription *entityDescirp = [NSEntityDescription entityForName:NSStringFromClass([entity class]) inManagedObjectContext:self.managedObjectContext];
                NSRelationshipDescription *relationshipDescrip = [entityDescirp.relationshipsByName objectForKey:key];
                NSString *tableName = relationshipDescrip.destinationEntity.name;
                NSManagedObject *object = [self buildManagedObjectByName:tableName];
                //赋值
                [self setContentDictionary:value toEntity:object];
                [entity setValue:object forKey:key];
            }
            @catch (NSException *exception) {
                NSLog(@"解析字典出错了-->%@",exception);
            }
        }else if ([value isKindOfClass:[NSArray class]]){
            
            @try {
                for (NSDictionary *oneJsonObject in value)
                {
                    NSEntityDescription *entiDescirp = [NSEntityDescription entityForName:NSStringFromClass([entity class]) inManagedObjectContext:self.managedObjectContext];
                    NSRelationshipDescription *relationshipDescrip = [entiDescirp.relationshipsByName objectForKey:key];
                    NSString *tableName = relationshipDescrip.destinationEntity.name;
                    NSManagedObject *object = [self buildManagedObjectByName:tableName];
                    SEL addSelector = NSSelectorFromString([NSString stringWithFormat:@"add%@Object:",[self upHeadString:key]]);
                    //赋值
                    [self setContentDictionary:oneJsonObject toEntity:object];
                    SuppressPerformSelectorLeakWarning([entity performSelector:addSelector withObject:object]);
                }
            }
            @catch (NSException *exception) {
                NSLog(@"解析数组出错了-->%@",exception);
            }
        }
    }
}

#pragma mark ------------------删除------------------------
//删除
- (NSError *)deleteEntity:(NSManagedObject *)entity {
    [self.managedObjectContext deleteObject:entity];
    // 保存数据，持久化存储
    return [self save];
}
//删除
- (NSError *)deleteEntitys:(NSArray *)entityArray {
    for (NSManagedObject *entity in entityArray) {
        [self.managedObjectContext deleteObject:entity];
    };
    NSError *error = [self save];
    return error;
}
#pragma mark ------------------修改------------------------
//修改实体
- (NSManagedObject *)updateEntity:(NSManagedObject *)entity  infoDic:(NSDictionary *)entityDic {
    //赋值
   NSManagedObject *object =  [self updateObject:entity infoDic:entityDic];
    //保存
    NSError *error = [self save];
    if (error == nil) {
        return object;
    }
    return nil;
}

//将entityDic字典里面在value赋值给object里面
- (NSManagedObject *)updateObject:(NSManagedObject *)object infoDic:(NSDictionary *)entityDic {
    for (NSString *key in entityDic.allKeys)//遍历
    {
        id value = [entityDic objectForKey:key];
        
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDate class]]){//基本类型
            @try {
                [object setValue:value forKey:key];
            }
            @catch (NSException *exception) {
                NSLog(@"key值出错了-->%@",exception);
            }
        }else if ([value isKindOfClass:[NSDictionary class]]){//里面是字典
            @try {
                NSManagedObject *otherObject = [object valueForKey:key];//查询里面是否有
                if(otherObject){
                    [self updateObject:otherObject infoDic:value];
                }else{//没有，则创建新的object
                    NSEntityDescription *entityDescirp = [NSEntityDescription entityForName:NSStringFromClass([object class]) inManagedObjectContext:self.managedObjectContext];
                    NSRelationshipDescription *relationshipDescrip = [entityDescirp.relationshipsByName objectForKey:key];
                    NSString *tableName = relationshipDescrip.destinationEntity.name;
                    otherObject = [self buildManagedObjectByName:tableName];
                    //赋值
                    [self setContentDictionary:value toEntity:otherObject];
    
                    [object setValue:otherObject forKey:key];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"解析字典出错了-->%@",exception);
            }
        }else if ([value isKindOfClass:[NSArray class]]){//里面是数组
            @try {
                NSArray *objectArray = [[object valueForKey:key] allObjects];
                
                for (int index=0; index<[(NSArray *)value count]; index++)
                {
                    NSDictionary *tempParams = [(NSArray *)value objectAtIndex:index];
                    if (objectArray && index<objectArray.count) {
                        [self updateObject:objectArray[index] infoDic:tempParams];
                    }else{
                        NSEntityDescription *entiDescirp = [NSEntityDescription entityForName:NSStringFromClass([object class]) inManagedObjectContext:self.managedObjectContext];
                        NSRelationshipDescription *relationshipDescrip = [entiDescirp.relationshipsByName objectForKey:key];
                        NSString *tableName = relationshipDescrip.destinationEntity.name;
                        NSManagedObject *tempObject = [self buildManagedObjectByName:tableName];
                        [self setContentDictionary:tempParams toEntity:tempObject];
                        
                        //赋值
                        SEL addSelector = NSSelectorFromString([NSString stringWithFormat:@"add%@Object:",[self upHeadString:key]]);
                        SuppressPerformSelectorLeakWarning([object performSelector:addSelector withObject:tempObject]);
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"解析数组出错了-->%@",exception);
            }
        }
    }
    return object;
}



#pragma mark ------------------查询------------------------
//带上条件 查询实体
- (NSArray *)queryEntityWithPredicate:(NSPredicate *)predicate {
    return [self queryEntityWithPredicate:predicate sortDescriptors:nil actions:nil];
}

//带上条件 查询实体
- (NSArray *)queryEntityWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors actions:(void (^)(NSFetchRequest *request))actions {
    NSAssert(self.entityName, @"要先设置entityName名称");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    //
    if (self.sortDescriptors  && self.sortDescriptors.count) {
        [fetchRequest setSortDescriptors:self.sortDescriptors];
    }
    if (sortDescriptors && sortDescriptors.count) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    actions?actions(fetchRequest):nil;
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"查询出错:%@",error);
    }    
    return result;
}

//保存
- (NSError *)save {
    NSError *error;
    @synchronized(self) {
        if (![self.managedObjectContext save:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    if(error == nil){
        if (_changeDataBlock) {
            _changeDataBlock(YES);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:HsBaseFetchedResultManagedObjectChangeNotification object:nil];
    }else{
        if (_changeDataBlock) {
            _changeDataBlock(NO);
        }
    }
    return error;
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors {
    if (_sortDescriptors != sortDescriptors) {
        _sortDescriptors = sortDescriptors;
    }
}


#pragma mark ------以下是初始化-我是分割线-查询到controller-------
- (NSString *)sqliteName {
    if (_sqliteName == nil) {
        if (self.momdName != nil) {
            _sqliteName = self.momdName;
        }else if (defaultSqliteName == nil) {
            NSString *userId = @"HsCoredata";
            if (!userId) {
                return nil;
            }
            _sqliteName = userId;
        }else{
            _sqliteName = defaultSqliteName;
        }
    }
    return _sqliteName;
}

- (NSString *)momdName {
    if (_momdName == nil) {
        _momdName = defaultMomdName;
    }
    return _momdName;
}

- (NSManagedObject *)buildManagedObjectByName:(NSString *)className {
    NSManagedObject *_object = nil;
    _object = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:self.managedObjectContext];
    return _object;
}

- (NSManagedObject *)buildManagedObjectByClass:(Class)theClass {
    return [self buildManagedObjectByName:NSStringFromClass(theClass)];
}



#pragma mark   -- 获取NSManagedObjectContext对象 阻塞--下面实例都是单例的----------
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    if (self.bundle == nil) {
        self.bundle = [NSBundle mainBundle];
    }
    NSAssert(self.momdName, @"要先设置momdName名称");
    NSURL *modelURL = [self.bundle URLForResource:self.momdName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSAssert(self.sqliteName, @"要先设置sqliteName名称");
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",self.sqliteName]];
    NSLog(@"\n数据库地址\n****************:\n%@\n****************", storeURL.absoluteString);
    NSError *error = nil;
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,
                                       [NSNumber numberWithBool:YES],
                                       NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark  ---------------------context------------------------
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

//清除 推送对象
-(void)cleanContext{
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
}

//获取用户使用目录
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


//#pragma mark ---NSFetchedResultsController和他们的委托类们----------------
//- (NSFetchedResultsController *)fetchedResultsController {
//    NSAssert(self.entityName, @"要先设置entityName名称");
//    NSAssert(self.sortDescriptors, @"要先设置sortDescriptors");
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    // Edit the entity name as appropriate.
//    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    // Set the batch size to a suitable number.
//    [fetchRequest setFetchBatchSize:20];
//    // Edit the sort key as appropriate.
//    if(self.sortDescriptors && self.sortDescriptors.count){
//        [fetchRequest setSortDescriptors:self.sortDescriptors];
//    }
//    if(self.predicate){
//        [fetchRequest setPredicate:self.predicate];
//    }
//    // Edit the section name key path and cache name if appropriate.
//    // nil for section name key path means "no sections".
//    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    aFetchedResultsController.delegate = self;
//    NSError *error = nil;
//    if (![aFetchedResultsController performFetch:&error]) {
//        HSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    return aFetchedResultsController;
//}
//
//
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller
//  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex
//     forChangeType:(NSFetchedResultsChangeType)type {
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        default:break;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller
//   didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath
//     forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath {
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
//}

@end







static NSMutableDictionary *fetchedResultDic;
#pragma mark ------------我是分隔线  managedObject -----------------
@implementation NSManagedObject (coredata)

+ (instancetype)managedObjectInstance {
    return [[self fetchedResults] buildManagedObjectByClass:[self class]];
}

//注册入请求context
+ (void)registerFetchedResults:(HsBaseFetchedResults *)fetchedResults {
    @synchronized(self){
        if (fetchedResultDic == nil) {
            fetchedResultDic = [NSMutableDictionary dictionary];
        }
    }
    fetchedResults.entityName = NSStringFromClass([self class]);
    [fetchedResultDic setValue:fetchedResults forKey:NSStringFromClass([self class])];
}
//注册入请求context
- (void)registerFetchedResults:(HsBaseFetchedResults *)fetchedResults {
    @synchronized(self){
        if (fetchedResultDic == nil) {
            fetchedResultDic = [NSMutableDictionary dictionary];
        }
    }
    fetchedResults.entityName = NSStringFromClass([self class]);
    [fetchedResultDic setValue:fetchedResults forKey:NSStringFromClass([self class])];
}

////得到HsBaseFetchedResults 可以做一些设置
+ (HsBaseFetchedResults *)fetchedResults {
    HsBaseFetchedResults *_fetchedResults = nil;
    if (fetchedResultDic != nil) {
        Class currentClass = [self class];
        while (currentClass != nil) {
            _fetchedResults = [fetchedResultDic valueForKey:NSStringFromClass(currentClass)];
            if (_fetchedResults == nil) {
                if (currentClass == [NSManagedObject class] || currentClass == [NSObject class]) {
                    currentClass = nil;
                }else{
                    currentClass = [currentClass superclass];
                }
            }else{
                break;
            }
        }
    }
    if(_fetchedResults == nil){
        _fetchedResults = [[HsBaseFetchedResults alloc] init];
        [self registerFetchedResults:_fetchedResults];
    }
    return _fetchedResults;
}
//得到HsBaseFetchedResults 可以做一些设置
- (HsBaseFetchedResults *)fetchedResults {
    HsBaseFetchedResults *_fetchedResults = nil;
    if (fetchedResultDic != nil) {
        Class currentClass = [self class];
        while (currentClass != nil) {
            _fetchedResults = [fetchedResultDic valueForKey:NSStringFromClass(currentClass)];
            if (_fetchedResults == nil) {
                if (currentClass == [NSManagedObject class] || currentClass == [NSObject class]) {
                    currentClass = nil;
                }else{
                    currentClass = [currentClass superclass];
                }
            }else{
                break;
            }
        }
    }
    if(_fetchedResults == nil){
        _fetchedResults = [[HsBaseFetchedResults alloc] init];
        [self registerFetchedResults:_fetchedResults];
    }
    return _fetchedResults;
}
//
////获取NSFetchedResultsController 便于给tableview显示
//+ (NSFetchedResultsController *)fetchedResultsControllerWithSortDescriptors:(NSArray *)sortDescriptors {
//    return [self fetchedResultsControllerWithSortDescriptors:sortDescriptors predicate:nil];
//}
////获取NSFetchedResultsController 便于给tableview显示
//+ (NSFetchedResultsController *)fetchedResultsControllerWithSortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate*)predicate{
//    HsBaseFetchedResults *result = [self fetchedResults];
//    result.sortDescriptors = sortDescriptors;
//    result.predicate = predicate;
//    return result.fetchedResultsController;
//}

//插入一个实体
+ (NSManagedObject *)insertEntity:(NSDictionary *)entityDic{
    [self fetchedResults].entityName = NSStringFromClass(self.class);
    return [[self fetchedResults] insertEntity:entityDic];
}

//插入多个实体
+ (NSArray *)insertEntitys:(NSArray *)entityArray {
    [self fetchedResults].entityName = NSStringFromClass(self.class);
    return [[self fetchedResults] insertEntitys:entityArray];
}

//删除
- (NSError *)deleteEntity {
   return  [self.fetchedResults deleteEntity:self];
}

//删除多个
+ (NSError *)deleteEntitys:(NSArray *)entityArray {
    return [[self fetchedResults] deleteEntitys:entityArray];
}

//修改实体
- (NSManagedObject *)updateEntity:(NSDictionary *)entityDic {
    return [self.fetchedResults updateEntity:self infoDic:entityDic];
}

//根据条件查询后修改
+ (NSArray *)updateEntitysWithPredicate:(NSPredicate *)predicate
                                infoDic:(NSDictionary *)entityDic {
    NSString *entityName = NSStringFromClass(self.class);
    //查询数据
    NSArray *queryArr = [self queryEntityWithPredicate:predicate sortDescriptors:nil actions:nil];
    //有匹配的记录时则更新记录
    if(queryArr && queryArr.count){
        for (NSManagedObject *object in queryArr.copy)
        {
            [object updateEntity:entityDic];
        }
    } else //没有匹配的记录时添加记录
    {
        queryArr = @[[NSClassFromString(entityName) insertEntity:entityDic]];
    }
    return queryArr;
}

//带上条件 查询实体
+ (NSArray *)queryEntityWithPredicate:(NSPredicate *)predicate {
    return [self queryEntityWithPredicate:predicate sortDescriptors:nil actions:nil];
}
+ (NSArray *)queryEntityWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors {
    return [self queryEntityWithPredicate:predicate sortDescriptors:sortDescriptors actions:nil];
}

+ (NSArray *)queryEntityWithPredicate:(NSPredicate *)predicate
                      sortDescriptors:(NSArray *)sortDescriptors
                              actions:(void (^)(NSFetchRequest *request))actions {
    [self fetchedResults].entityName = NSStringFromClass(self.class);
    return [[self fetchedResults] queryEntityWithPredicate:predicate sortDescriptors:sortDescriptors actions:actions];
}


#pragma mark ---------------异步---------------

static dispatch_queue_t myCustomQueue;
//插入一个实体
+ (void)insertEntity:(NSDictionary *)entityDic complete:(void (^)(NSManagedObject *object))complete{
    [NSManagedObject asyncQueue:true actions:^{
        __block NSManagedObject *oneObject = [self insertEntity:entityDic];
        if (complete) {
            complete(oneObject);
        }
    }];
}

//插入多个实体
+ (void)insertEntitys:(NSArray *)entityArray complete:(void (^)(NSArray *resultArray))complete {
    [NSManagedObject asyncQueue:true actions:^{
        __block NSArray *resultArray = [self insertEntitys:entityArray];
        if (complete) {
            complete(resultArray);
        }
    }];
}

//删除
- (void)deleteEntity:(void (^)(BOOL success))complete {
    [NSManagedObject asyncQueue:true actions:^{
        NSError *error = [self deleteEntity];
        if (complete) {
            complete(error == nil ? YES : NO);
        }
    }];
}

//删除
+ (void)deleteEntitys:(NSArray *)entityArray complete:(void (^)(BOOL success))complete {
    [NSManagedObject asyncQueue:true actions:^{
        NSError *error = [self deleteEntitys:entityArray];
        if (complete) {
            complete(error == nil ? YES : NO);
        }
    }];
}

//修改实体
- (void)updateEntity:(NSDictionary *)entityDic complete:(void (^)(NSManagedObject *object))complete{
    [NSManagedObject asyncQueue:true actions:^{
        NSManagedObject *object = [self updateEntity:entityDic];
        if (complete) {
            complete(object);
        }
    }];

}

//根据条件查询后修改
+ (void)updateEntitysWithPredicate:(NSPredicate *)predicate infoDic:(NSDictionary *)entityDic complete:(void (^)(NSArray *resultArray))complete {
    [NSManagedObject asyncQueue:true actions:^{
        NSArray *array = [self updateEntitysWithPredicate:predicate infoDic:entityDic];
        if (complete) {
            complete(array);
        }
    }];
}

//带上条件 查询实体
+ (void)queryEntityWithPredicate:(NSPredicate *)predicate complete:(void (^)(NSArray *result))complete {
    [NSManagedObject asyncQueue:true actions:^{
        NSArray *array = [self queryEntityWithPredicate:predicate];
        if (complete) {
            complete(array);
        }
    }];
}

//带上条件 查询实体
+ (void)queryEntityWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors complete:(void (^)(NSArray *result))complete {
    [NSManagedObject asyncQueue:true actions:^{
        NSArray *array = [self queryEntityWithPredicate:predicate sortDescriptors:sortDescriptors actions:nil];
        if (complete) {
            complete(array);
        }
    }];
}

//是否在异步队列中操作数据库
+ (void)asyncQueue:(BOOL)async actions:(void (^)(void))actions {
    static int specificKey;
    if (myCustomQueue == NULL)
    {
        myCustomQueue = dispatch_queue_create("com.hundsun.coredata", DISPATCH_QUEUE_SERIAL); //生成一个串行队列
        
        CFStringRef specificValue = CFSTR("com.hundsun.coredata");
        dispatch_queue_set_specific(myCustomQueue, &specificKey, (void*)specificValue,(dispatch_function_t)CFRelease);
    }
    
    NSString *retrievedValue = (NSString *)CFBridgingRelease(dispatch_get_specific(&specificKey));
    if (retrievedValue && [retrievedValue isEqualToString:@"com.hundsun.coredata"]) {
        actions ? actions() : nil;
    }else{
        if(async){
            dispatch_async(myCustomQueue, ^{
                actions ? actions() : nil;
            });
        }else{
            dispatch_sync(myCustomQueue, ^{
                actions ? actions() : nil;
            });
        }
    }
}

- (NSError *)save {
    //保存
    NSError *error = [[self fetchedResults] save];
    return error;
}

@end
