//
//  LoginEvent.h
//  ZpzChinaApp
//
//  Created by Jack on 14-7-16.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LoginEvent : NSObject<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
    UIImage *userFaceImage;
    NSString *person_id;
    NSMutableArray *faceIDArray;
    BOOL isLogin;
}
-(void)gotoFaceRecoginzer:(UIViewController *)viewController;

@end
