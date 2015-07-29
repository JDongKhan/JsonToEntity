//
//  HsBaseEntity+entity.m
//  JsonToEntity
//
//  Created by 王金东 on 15/1/1.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import "HsBaseEntity+entity.h"
#import <objc/runtime.h>

@implementation HsBaseEntity (entity)


+ (id)objectWithData:(id)data{
    if([data isKindOfClass:[NSDictionary class]]){
        return [self dictionaryToEntity:data];
    }else if([data isKindOfClass:[NSArray class]]){
        return [self arrayToEntity:data];
    }
    return nil;
}

+ (instancetype)dictionaryToEntity:(NSDictionary *)dictionary{
    id model = [[self alloc] init];
    return [model dictionaryToEntity:dictionary];
}

+ (NSMutableArray *)arrayToEntity:(NSArray *)array{
    NSMutableArray *entityArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dictionary in array) {
        id model = [[self alloc] init];
        [entityArray addObject:[model dictionaryToEntity:dictionary]];
    }
    return entityArray;
}

- (instancetype)dictionaryToEntity:(NSDictionary *)dictionary{
    NSEnumerator *enumerator = [dictionary keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {
        id value = dictionary[key];
        if ([value isKindOfClass:[NSNull class]]) {
            continue;
        }
        if([value isKindOfClass:[NSArray class]]){//判断该属性的值是不是数组
            Class objectClass = nil;
            if([self exsitWithKey:key]){//判断key是否存在
                //处理key
                NSString *keyArray = [key stringByReplacingOccurrencesOfString:self.arraySuffix withString:@""];
                NSString *modelKeyArray = [keyArray capitalizedString];
                //
                objectClass = NSClassFromString(modelKeyArray);
                if (objectClass) {
                    value = [objectClass arrayToEntity:value];
                }else{
                    NSLog(@"%@对应的对象没有找到",modelKeyArray);
                }
            }
            if (objectClass == nil && [self respondsToSelector:@selector(objectClassInArray)]) {
                // 3.处理数组里面有模型的情况
                NSDictionary *objectClassDic = [self performSelector:@selector(objectClassInArray)];
                objectClass = objectClassDic[key];
                if (objectClass) {
                    value = [objectClass arrayToEntity:value];
                }else{
                    NSLog(@"objectClassInArray方法没有返回值");
                }
            }
        }else if ([value isKindOfClass:[NSDictionary class]]) {//判断该属性是否是自定义对象
            Class keyClass = [self classWithKey:key];
            value = [keyClass dictionaryToEntity:value];
        }
        [self setValue:value forKey:key];
    }
    return self;
}

//判断是否存在
- (BOOL)exsitWithKey:(NSString *)key{
    const char *charKey =  [[NSString stringWithFormat:@"_%@",key] UTF8String];
    Ivar ivar = class_getInstanceVariable([self class],charKey);
    if(ivar != nil){
        return YES;
    }
    return NO;
}
//根据key获取字段类型
- (Class)classWithKey:(NSString *)key{
    const char *charKey =  [[NSString stringWithFormat:@"_%@",key] UTF8String];
    Ivar ivar = class_getInstanceVariable([self class],charKey);
    NSString *code = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
    // 去掉@"和"，截取中间的类型名称
    code = [code substringFromIndex:2];
    code = [code substringToIndex:code.length - 1];
    return NSClassFromString(code);
}



@end
