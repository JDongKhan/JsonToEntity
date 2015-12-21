# JsonToEntity

超级简单的json转Model 核心代码就10来行，支持异步,支持coreData,使用时一个方法搞定(objectWithData:),喜欢用自己能看得懂的代码人的最爱，超级简单，入门就能看懂，如果你有好的建议请联系我:419591321@qq.com

简单使用 pod 'JsonToEntity' '1.0.0'

例子
一、
--------------------------------
```c
NSDictionary *dic = @{
    @"id":@"1234",
    @"name":@"金融"
};

Dept *dept = [Dept objectWithData:dic];
NSLog(@"%@",dept.name);
```
二、
--------------------------------
```c
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
```
三、
--------------------------------
```c
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
```
