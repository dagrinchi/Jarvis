//
//  RootForm.h
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginForm.h"
#import "RegistrationFormViewController.h"

@interface RootForm : NSObject <FXForm>

@property (nonatomic, strong) LoginForm * login;
@property (nonatomic, strong) RegistrationFormViewController * registration;

@end
