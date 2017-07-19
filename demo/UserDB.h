//
//  UserDB.h
//  JsonToEntity
//
//  Created by 王金东 on 2017/6/30.
//  Copyright © 2017年 王金东. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface UserDB : NSManagedObject

@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, copy) NSString *name;


@end
