//
//  User.m
//  JsonToEntity
//
//  Created by 王金东 on 15/1/1.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import "User.h"

@implementation User

- (void)setSex:(int)sex{
    _sex = sex;
    if (sex == 0) {
        self.sexString = @"男";
    }else{
        self.sexString = @"女";
    }
}

- (void)replaceObjectInIDAtIndex:(NSInteger)index withObject:(id)object{
    NSLog(@"");
}

@end
