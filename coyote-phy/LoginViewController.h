//
//  LoginViewController.h
//  StuentEvaluation
//
//  Created by admin  on 13-12-24.
//  Copyright (c) 2013年 com.seuli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegueStatusListener.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate,SegueStatusListener>

@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;

@end
