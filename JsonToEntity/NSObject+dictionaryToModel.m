//
//  NSObject+dictionaryToModel.m
//  HsCore
//
//  Created by 王金东 on 15/7/13.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import "NSObject+dictionaryToModel.h"
#import <objc/runtime.h>
#import "HsBaseFetchedResults.h"

static const void *keyModelForArray = &keyModelForArray;
static const void *keyModelForMapping = &keyModelForMapping;

@implementation NSObject (dictionaryToModel)

- (void)setDefaultArraySuffix:(NSString *)defaultArraySuffix {
    objc_setAssociatedObject(self, keyModelForArray, defaultArraySuffix, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)defaultArraySuffix {
    NSString *arraySuffix = objc_getAssociatedObject(self, keyModelForArray);
    if (arraySuffix == nil) {
        return @"Array";
    }
    return arraySuffix;
}

- (void)setObjectClassInMapping:(NSDictionary *)objectClassInMapping {
    objc_setAssociatedObject(self, keyModelForMapping, objectClassInMapping, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)objectClassInMapping {
    return objc_getAssociatedObject(self, keyModelForMapping);
}
#pragma mark --------------------------解析------------------------------

+ (id)objectWithData:(id)data{
    if([data isKindOfClass:[NSDictionary class]]){
        return [self dictionaryToEntity:data];
    }else if([data isKindOfClass:[NSArray class]]){
        return [self arrayToEntity:data];
    }
    return [self newObjectInstance];
}

+ (void)objectWithData:(id)data completionBlock:(void(^)(id result))completionBlock{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id result = [self objectWithData:data];
        if(completionBlock != nil){
            dispatch_async( dispatch_get_main_queue(), ^{
                completionBlock(result);
            } );
        }
    } );
}

+ (instancetype)newObjectInstance {
    id model = nil;
    if ([self isSubclassOfClass:[NSManagedObject class]]) {
        id clazz = self;
        model = [clazz managedObjectInstance];
    }else{
        model = [[self alloc] init];
    }
    return model;
}

+ (instancetype)dictionaryToEntity:(NSDictionary *)dictionary{
    id model = [self newObjectInstance];
    return [model transformDictionaryToEntity:dictionary];
}

+ (NSMutableArray *)arrayToEntity:(NSArray *)array{
    NSMutableArray *entityArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dictionary in array) {
        [entityArray addObject:[self dictionaryToEntity:dictionary]];
    }
    return entityArray;
}

- (instancetype)transformDictionaryToEntity:(NSDictionary *)dictionary{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key,id value,BOOL *stop){
        if ([value isKindOfClass:[NSNull class]]) {
            return;
        }

        if([value isKindOfClass:[NSArray class]]){//判断该属性的值是不是数组
            Class objectClass = nil;
            if([self exsitWithKey:key]){//判断key是否存在
                //获取配置
                NSString *arraySuffix = self.defaultArraySuffix;
                //处理key
                NSString *keyArray = [key stringByReplacingOccurrencesOfString:arraySuffix withString:@""];
                NSString *firstLetterCap=[[keyArray substringToIndex:1] capitalizedString];
                NSString *modelKeyArray=[keyArray stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLetterCap];
                
                objectClass = NSClassFromString(modelKeyArray);
                if (objectClass) {
                    value = [objectClass arrayToEntity:value];
                }
            }
            if (objectClass == nil){
                //处理数组里面有模型的情况
                NSDictionary *objectClassDic = self.objectClassInMapping;
                if(objectClassDic)
                    objectClass = objectClassDic[key];
                
                if (objectClass)
                    value = [objectClass arrayToEntity:value];
            }
            
        }else if ([value isKindOfClass:[NSDictionary class]]) {//判断该属性是否是自定义对象
            if([self exsitWithKey:key]){
                Class keyClass = [self classWithKey:key];
                value = [keyClass dictionaryToEntity:value];
            }
        }
        @try {
            [self setValue:value forKey:key];
        }
        @catch (NSException *exception) {
            NSLog(@"字段set%@方法出错",key);
        }
        @finally {
            
        }
    }];
    
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
