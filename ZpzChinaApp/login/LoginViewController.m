//
//  LoginViewController.m
//  ZpzChinaApp
//
//  Created by Jack on 14-7-16.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor blueColor];
    UIButton *faceLogBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [[NSUserDefaults standardUserDefaults] setObject:@"hanhailong" forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    faceLogBtn.frame = CGRectMake(130, 130, 60, 60);
    [faceLogBtn setTitle:@"脸部识别登录" forState:UIControlStateNormal];
    [faceLogBtn addTarget:self action:@selector(beginFaceRecoginzer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:faceLogBtn];
    
    
}
-(void)beginFaceRecoginzer:(UIButton *)button
{
    event = [[LoginEvent alloc] init];
    [event gotoFaceRecoginzer:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
