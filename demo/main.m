//
//  main.m
//  JsonToEntity
//
//  Created by 王金东 on 15/1/1.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dept.h"
#import "User.h"
#import "Compay.h"
#import "NSObject+dictionaryToModel.h"


void test1()
{
    NSDictionary *dic = @{
                          @"id":@"1234",
                          @"name":@"金融"
                          };
    
    Dept *dept = [Dept objectWithData:dic];
    NSLog(@"%@",dept.name);
}

void test2(){
    NSDictionary *dic = @{
                          @"id":@"123",
                          @"name":@"wjd",
                          @"isRegister":@1,
                          @"sex":@"0",
                          @"dept":@{
                                  @"name":@"金融"
                                  }
                          };
    
    User *user = [User objectWithData:dic];
    NSLog(@"id:%d,sex:%@,name:%@ ,isRegister:%d, deptName:%@",user.ID,user.sexString,user.name,user.isRegister,user.dept.name);
    
    BOOL isRegister = user.isRegister;
    BOOL isRegister1 = user.isRegister;
}

void test3(){
    NSDictionary *dic = @{
                          @"compayName":@"hs",
                          @"userArray":@[
                                   @{@"name":@"wjd1",@"sex":@"0",@"dept":@{@"name":@"通信"}},
                                   @{@"name":@"wjd2",@"sex":@"1",@"dept":@{@"name":@"金融"}},
                                   @{@"name":@"wjd3",@"sex":@"0",@"dept":@{@"name":@"通信"}},
                                   @{@"name":@"wjd4",@"sex":@"1",@"dept":@{@"name":@"时光飞逝"}}
                                  ]
                          };
    
    Compay *compay = [Compay objectWithData:dic];
    User *user = compay.userArray[0];
    
    NSLog(@"copmayName:%@,第一个用户信息：name-%@,sex-%@,deptname:%@",compay.compayName,user.name,user.sexString,user.dept.name);
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        test1();
 //       test2();
       test3();
    }
    return 0;
}




