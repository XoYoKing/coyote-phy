//
//  LoginViewController.m
//  StuentEvaluation
//
//  Created by admin  on 13-12-24.
//  Copyright (c) 2013年 com.seuli. All rights reserved.
//

#import "LoginViewController.h"
#import "QuestionViewController.h"
#import "ASIFormDataRequest.h"
#import "ProgressHUD.h"
#import "Toolkit.h"
#import "JSONKit.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface LoginViewController ()


@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(void)dealloc
{
    [_nameTextField release];
    [_passwordTextField release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self addLoginView];
}

-(void)addLoginView
{
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = self.view.bounds;
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:@"Start_Background" ofType:@"jpg"];
    [imageView setImage:[UIImage imageWithContentsOfFile: imagePath]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:imageView];
    [imageView release];
    
    _nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(600, 400, 180, 40)];
    _nameTextField.placeholder = @"10101010";
    _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_nameTextField];
    
    _passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(600, 480, 180, 40)];
    _passwordTextField.placeholder = @"123456";
    _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_passwordTextField];
    
    
    UIButton *button = [[UIButton alloc]init];
    button.frame = CGRectMake(826, 378, 155, 155);
    [button setBackgroundImage:[UIImage imageNamed:@"BtnStart_1.jpg"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"BtnStart_2.jpg"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button release];
    
    //观察者模式实现委托的功能
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateView) name:@"updateView" object:nil];
}

#pragma mark init

-(NSString*) getValidURL
{
    if (false) {
        //TODO: 从系统的配置文件中读取，然后自动将可以用的url返回给所需函数
    }
    
    // TODO: 可以做一个独立的类来管理全部的配置参数，代码形式如下
    /*
     MyConfig * config = [MyConfig init];
     NSString * value =  [config getUserLoginURL];
     [config release];
     
     // 或者用类方法来写
     NSString * value = [MyConfig getUserLoginURL];
     */
    return [NSString stringWithFormat:@"%@/apps/coyotes/post_answer1.php?",[Toolkit getTestUrl]];

}


//登录
-(void)login
{
    [Toolkit saveUserName:@"lixiang"];
    
    [self performSegueWithIdentifier:@"LoginToQuestion" sender:self];
    
    /*
    if ([_nameTextField.text isEqualToString:@""] || [_passwordTextField.text isEqualToString:@""]) {
        [ProgressHUD showError:@"用户名或密码为空"];
        return;
    }
    
    [ProgressHUD show:@"登录中..."];
    
    NSString *urlstr = [self getValidURL];
    NSURL *myurl = [NSURL URLWithString:urlstr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:myurl];
    //设置表单提交项
    [request setPostValue:_nameTextField.text forKey:@"user"];
    [request setPostValue:_passwordTextField.text forKey:@"pass"];
    
    [request setCompletionBlock:^{
        NSLog(@"responseString = %@",request.responseString);
        
        NSDictionary *dic = [request.responseString objectFromJSONString];
        NSLog(@"dic %@",dic);
        if ([[dic objectForKey:@"success"] boolValue] == 1) {
            
            //[ProgressHUD dismiss];
            [Toolkit saveUserName:_nameTextField.text];
            [ProgressHUD showSuccess:@"登陆成功"];
            [self.view addSubview:_choiceView];
        }
        else{
            //[ProgressHUD dismiss];
            [ProgressHUD showError:@"输入的账户信息有误"];
        }
        
    }];
    [request setFailedBlock:^{
        
        NSLog(@"asi error: %@",request.error.debugDescription);
        
    }];
    
    [request startAsynchronous];
     
     */
}

//该三个函数未实现
- (void)transitionAwayFrom {
    
}

- (void)beginTransition:(id)sender {
}

- (void)finishedTransition:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
