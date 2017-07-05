//
//  NSObject+dictionaryToModel.h
//  HsCore
//
//  Created by 王金东 on 15/7/13.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (dictionaryToModel)

/**
 *  @author wangjindong, 15-07-06 15:07:43
 *
 *  @brief  数组字段的后缀 比如 arraySuffix = @"s" 代表数组字段后缀是user(s)
 *
 */

@property (nonatomic, copy) NSString *defaultArraySuffix;

/**
 *  @author wangjindong, 15-07-06 15:07:08
 *
 *  @brief  内部对象映射
 *
 *  @return @{@"key":[NSObject class]}
 *
 *  @since
 */
@property (nonatomic, copy) NSDictionary *objectClassInMapping;

/**
 *	@brief	同步解析
 *	@param 	data 	可是Array 也可是Dictionary
 *	@return
 */
+ (id)objectWithData:(id)data;


/**
 *	@brief	异步解析，在主线程回调
 *	@param 	data 	可是Array 也可是Dictionary
 *	@return
 */
+ (void)objectWithData:(id)data completionBlock:(void(^)(id result))completionBlock;


@end
