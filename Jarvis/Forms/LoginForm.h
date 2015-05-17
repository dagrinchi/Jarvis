//
//  LoginForm.h
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubmitButtonCell.h"
#import "RegistrationFormViewController.h"

@interface LoginForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

@end
