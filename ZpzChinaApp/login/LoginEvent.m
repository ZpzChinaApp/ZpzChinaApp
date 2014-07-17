//
//  LoginEvent.m
//  ZpzChinaApp
//
//  Created by Jack on 14-7-16.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import "LoginEvent.h"
#import "FaceppResult.h"
#import "FaceppAPI.h"
#import "HomeViewController.h"
@implementation LoginEvent

-(void)gotoFaceRecoginzer:(UIViewController *)viewController
{
    person_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        //设置拍照后的图片可被编辑
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = sourceType;
        
        [viewController presentViewController:imagePicker animated:YES completion:Nil];
    }else{
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *sourceImage = info[UIImagePickerControllerOriginalImage];
    UIImage *imageToDisplay = [self fixOrientation:sourceImage];
    
    // perform detection in background thread
    [self performSelectorInBackground:@selector(detectWithImage:) withObject:imageToDisplay];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//照片转正
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


-(void) detectWithImage: (UIImage*) image {
    FaceppResult *result = [[FaceppAPI detection] detectWithURL:nil orImageData:UIImageJPEGRepresentation(image, 0.5) mode:FaceppDetectionModeNormal attribute:FaceppDetectionAttributeNone];
    if (result.success) {
        double image_width = [[result content][@"img_width"] doubleValue] *0.01f;
        double image_height = [[result content][@"img_height"] doubleValue] * 0.01f;
        UIGraphicsBeginImageContext(image.size);
        [image drawAtPoint:CGPointZero];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 0, 0, 1.0, 1.0);
        CGContextSetLineWidth(context, image_width * 0.7f);
        // draw rectangle in the image
        NSUInteger face_count = [[result content][@"face"] count];
        for (int i=0; i<face_count; i++) {
            double width = [[result content][@"face"][i][@"position"][@"width"] doubleValue];
            double height = [[result content][@"face"][i][@"position"][@"height"] doubleValue];
            CGRect rect = CGRectMake(([[result content][@"face"][i][@"position"][@"center"][@"x"] doubleValue] - width/2) * image_width,
                                     ([[result content][@"face"][i][@"position"][@"center"][@"y"] doubleValue] - height/2) * image_height,
                                     width * image_width,
                                     height * image_height);
            CGContextStrokeRect(context, rect);
            NSArray *a = [[result content] objectForKey:@"face"];
            for(NSDictionary *item in a){
                if (![[item objectForKey:@"face_id"] isEqualToString:@""]) {
                    if (isLogin==NO ) {
                        [faceIDArray addObject:item];
                    }else if (isLogin==YES ) {
                        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:@"aaa",@"userName",faceIDArray,@"faceIDArray" ,nil];
                        NSMutableDictionary *parameters =[[NSMutableDictionary alloc] init];
                        [parameters setObject:data forKey:@"data"];
                        NSLog(@"1*****************************************%@",parameters);
                        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://192.168.0.78:801/zpzserver/zpzchina.svc/users/FaceLogin" parameters:parameters error:nil];
                        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                        op.responseSerializer = [AFJSONResponseSerializer serializer];
                        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                         {
                             NSLog(@"JSON: %@", responseObject);
                             NSLog(@"注册成功");
                             NSNumber *statusCode = [[[responseObject objectForKey:@"d"] objectForKey:@"status"] objectForKey:@"statusCode"];
                             if([[NSString stringWithFormat:@"%@",statusCode] isEqualToString:@"200"]){
                                 NSLog(@"登录成功");
                             }
                            else{
                                 NSLog(@"登录失败！");
                                 UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                 alert.tag = 1;
                                 [alert show];
                             }
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"Error: %@", error);
                         }];
                        [[NSOperationQueue mainQueue] addOperation:op];
                    }
                }
            }
        }
    } else {
        // some errors occurred
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"error message: %@", [result error].message]
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        
    }
    
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

@end
