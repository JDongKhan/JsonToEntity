//
//  User.h
//  JsonToEntity
//
//  Created by 王金东 on 15/1/1.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dept.h"
#import "HsBaseEntity.h"

@interface User : HsBaseEntity

@property (nonatomic,assign) int ID;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *sexString;

@property (nonatomic,assign) int sex;

@property (nonatomic,assign) BOOL isRegister;

@property (nonatomic,strong) Dept *dept;

@end
