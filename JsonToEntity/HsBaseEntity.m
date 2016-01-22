//
//  HsBaseEntity.m
//  hospitalcloud_sdzy
//
//  Created by wjd on 14-6-13.
//  Copyright (c) 2014年 wjd. All rights reserved.
//

#import "HsBaseEntity.h"
#import <objc/runtime.h>

@implementation HsBaseEntity


- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if([@"id" isEqualToString:key]){
        [self setValue:value forKey:@"ID"];
    }else{
    #ifdef DEBUG
        NSLog(@"%@： undefinedKey:%@",NSStringFromClass([self class]),key);
    #endif
    }
}
- (id)valueForUndefinedKey:(NSString *)key{
    #ifdef DEBUG
        NSLog(@"%@ undefinedKey:%@",NSStringFromClass([self class]),key);
    #endif
    return nil;
}
//- (NSString *)descriptionWithLocale:(id)locale
//{
//    return @"";
//}
- (NSString *)description {
    return [self descriptionPrivate];
}
- (NSString *)debugDescription {
    return [self descriptionPrivate];
}
- (NSString *)descriptionPrivate {
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"{\t\n "];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id value= [self valueForKey:key];
        [str appendFormat:@"\t \"%@\" = %@,\n",key, value];
    }
    [str appendString:@"}"];
    free(properties);
    return str;
}

- (void)dealloc {
}
@end
