//
//  HsBaseEntity.m
//  JsonToEntity
//
//  Created by 王金东 on 15/1/1.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import "HsBaseEntity.h"

@implementation HsBaseEntity

- (instancetype)init{
    self = [super init];
    if (self) {
        //建议统一后缀
        self.arraySuffix = @"Array";
        //如果后缀不同意，变量前缀是一个不存在的对象 则建议使用objectClassInArray方法，自己用映射
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if([key isEqualToString:@"id"]){
        [self setValue:value forKey:@"ID"];
    }else{
        NSLog(@"undefinedKey");
    }
}

- (NSDictionary *)objectClassInArray{
    return nil;
}


@end
