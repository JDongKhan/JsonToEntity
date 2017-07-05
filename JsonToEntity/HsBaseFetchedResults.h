//
//  HsBaseFetchedResults.h  1.0版本
//  hospitalcloud_sc
// 首先给managedObject 调用registerFetchedResults方法 注入HsBaseFetchedResults实例，设置managedObjectContext，便于使用
//  用法：只需要使用NSManagedObject的insertEntity:fetchedResults:、deleteEntityWithFetchedResults、updateEntity:fetchedResults、queryEntityWithPredicate:fetchedResults 方法即可完成object的增删改查

//  可继承HsBaseFetchedResults对方法进行重写，增加些许业务逻辑
//  在applicationWillTerminate 调用 [[HsBaseFetchedResults shareInstance] saveContext];

//  Created by 王金东 on 14-10-27.
//  Copyright (c) 2014年 王金东. All rights reserved.
//
//     HsBaseFetchedResults *result = [[HsBaseFetchedResults alloc] init];
//     result.tableView = self.tableView;
//     result.momdName = @"Model";
//     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age" ascending:NO];
//    NSArray *sortDescriptors = @[sortDescriptor];
//    给User注入修改coredata的功能
//    [User registerFetchedResults:result];
//    下面是查询显示用的
//    self.fetchedResult = [User fetchedResultsControllerWithSortDescriptors:sortDescriptors];
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)


typedef void(^BaseFetchedResultDataChangeBlock)(BOOL changed);

@interface HsBaseFetchedResults : NSObject

//排序条件
@property (nonatomic, copy) NSArray *sortDescriptors;
//过滤条件
@property (nonatomic, strong) NSPredicate *predicate;

//coreData 文件名称
@property (nonatomic, copy) NSString *momdName;
@property (nonatomic, strong) NSBundle *bundle;

//数据库名称
@property (nonatomic, copy) NSString *sqliteName;

//实体名称
@property (nonatomic, copy) NSString *entityName;

//设置默认文件名称  也就是momdName不设置会使用该值
+ (void)setDefaultMomdName:(NSString *)momdName;

//设置默认数据库名称  也就是sqliteName不设置会使用该值
+ (void)setDefaultSqliteName:(NSString *)sqliteName;


/**
 *
 * 注册一个更改信息后的提示
 */
- (void)registerObjectChange:(BaseFetchedResultDataChangeBlock)changeBlock;

#pragma mark ---方法--可重写，不过要调用super的方法-

/**
 *	@brief	插入一个实体
 *	@param 	entityDic 	要插入的数据源
 *	@return	已插入的实体
 */
- (NSManagedObject *)insertEntity:(NSDictionary *)entityDic;


/**
 *	@brief	插入多个实体
 *	@param 	entityArray 	要插入的数据源数组
 *	@return	已插入的实体数组
 */
- (NSArray *)insertEntitys:(NSArray *)entityArray;



/**
 *	@brief	删除
 *	@param 	entity 	要删除的实体
 *	@return	错误信息
 */
- (NSError *)deleteEntity:(NSManagedObject *)entity;


/**
 *	@brief	删除
 *	@param 	entityArray 	要删除的实体数组
 *	@return	错误信息
 */
- (NSError *)deleteEntitys:(NSArray *)entityArray;


/**
 *	@brief	修改实体
 *	@param 	entity 	要修改的实体
 *	@param 	entityDic 	修改的数据源
 *	@return	修改后的实体
 */
- (NSManagedObject *)updateEntity:(NSManagedObject *)entity  infoDic:(NSDictionary *)entityDic;



/**
 *	@brief	带上条件 查询实体
 *	@param 	predicate 	查询条件
 *	@return	结果集
 */
- (NSArray *)queryEntityWithPredicate:(NSPredicate *)predicate;



/**
 *	@brief	保存数据
 *	@return
 */
- (void)saveContext;



/**
 *	@brief	清除 推送对象
 *	@return
 */
-(void)cleanContext;



@end














#pragma mark ----------------我是分割线------------------------------
@interface NSManagedObject (coredata)

//注册入请求context
+ (void)registerFetchedResults:(HsBaseFetchedResults *)fetchedResults;
- (void)registerFetchedResults:(HsBaseFetchedResults *)fetchedResults;

//得到HsBaseFetchedResults 可以做一些设置
+ (HsBaseFetchedResults *)fetchedResults;
- (HsBaseFetchedResults *)fetchedResults;

/**
 *  @author wangjindong, 15-07-15 10:07:17
 *
 *  @brief  实力化对象 不能用alloc来
 *
 *  @return
 *
 *  @since
 */
+ (instancetype)managedObjectInstance;


#pragma mark -----------同步------------------
/**
 *	@brief	插入一个实体
 *	@param 	entityDic 要插入的字典
 *  @return 返回添加后的数据
 */
+ (NSManagedObject *)insertEntity:(NSDictionary *)entityDic;

/**
 *	@brief	插入多个实体
 *	@param 	entityArray 要插入的数组
 *  @return 返回添加后的数据
 */

+ (NSArray *)insertEntitys:(NSArray *)entityArray;

/**
 *	@brief	删除一个实体
 *  @return 返回错误信息
 */
- (NSError *)deleteEntity;

/**
 *	@brief	删除多个实体
 *	@param 	entityArray 要删除的数组
 *  @return 返回错误信息
 */
+ (NSError *)deleteEntitys:(NSArray *)entityArray;

/**
 *	@brief	修改一个实体
 *	@param 	entityDic 要修改的字典
 *  @return 返回一个修改后的对象
 */
- (NSManagedObject *)updateEntity:(NSDictionary *)entityDic;

/**
 *	@brief	根据条件查询后修改
 *	@param 	predicate 查询条件
 *	@param 	entityDic 要修改的字典
 *  @return 返回一个修改后的对象
 */
+ (NSArray *)updateEntitysWithPredicate:(NSPredicate *)predicate infoDic:(NSDictionary *)entityDic;

/**
 *	@brief	带上条件 查询实体
 *	@param 	predicate 	查询条件
 */
+ (NSArray *)queryEntityWithPredicate:(NSPredicate *)predicate;

/**
 *	@brief	带上条件 查询实体
 *	@param 	predicate 	查询条件
*	@param 	sortDescriptors  排序条件
 */
+ (NSArray *)queryEntityWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;



#pragma mark ---------------异步---------------

/**
 *	@brief	插入一个实体
 *	@param 	entityDic 要插入的字典
 *	@param  complete 完成后回调
 */
+ (void)insertEntity:(NSDictionary *)entityDic complete:(void (^)(NSManagedObject *object))complete;

/**
 *	@brief	插入多个实体
 *	@param 	entityArray 要插入的数组
 *	@param  complete 完成后回调
 */

+ (void)insertEntitys:(NSArray *)entityArray complete:(void (^)(NSArray *resultArray))complete;

/**
 *	@brief	删除
 *	@param  complete 完成后回调
 */
- (void)deleteEntity:(void (^)(BOOL success))complete;

/**
 *	@brief	删除
 *	@param 	entityArray 要删除的数组
 *	@param  complete 完成后回调
 */
+ (void)deleteEntitys:(NSArray *)entityArray complete:(void (^)(BOOL success))complete;

/**
 *	@brief	修改
 *	@param 	entityDic 	修改的值
 *	@param  complete 完成后回调
 */
- (void)updateEntity:(NSDictionary *)entityDic complete:(void (^)(NSManagedObject *object))complete;

/**
 *	@brief	根据条件查询后修改
 *	@param 	predicate 	查询条件
 *	@param 	entityDic 	修改的值
 *	@param  complete 完成后回调
 */
+ (void)updateEntitysWithPredicate:(NSPredicate *)predicate infoDic:(NSDictionary *)entityDic complete:(void (^)(NSArray *resultArray))complete;


/**
 *	@brief	查询实体
 *	@param 	predicate 	查询条件
 *	@param  complete 完成后回调
 */
+ (void)queryEntityWithPredicate:(NSPredicate *)predicate complete:(void (^)(NSArray *result))complete;

/**
 *	@brief	查询实体
 *	@param 	predicate 	查询条件
 *	@param 	sortDescriptors 	排序条件
 *	@param  complete 完成后回调
 */
+ (void)queryEntityWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors complete:(void (^)(NSArray *result))complete;


/**
 *  @author wangjindong, 15-07-15 10:07:03
 *
 *  @brief  保存
 *
 *  @since
 */
- (NSError *)save;



@end

extern NSString *const HsBaseFetchedResultManagedObjectChangeNotification;
