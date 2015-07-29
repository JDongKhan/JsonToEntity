//
//  HsBaseEntity.h
//  JsonToEntity
//
//  Created by 王金东 on 15/1/1.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HsBaseEntity : NSObject

//设置数组变量后缀
@property (nonatomic,strong) NSString *arraySuffix;

//测试用
@property (nonatomic,assign) NSInteger pageSize;

@end
