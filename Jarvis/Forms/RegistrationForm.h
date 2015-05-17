//
//  RegistrationForm.h
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>
#import "SubmitButtonCell.h"

@interface RegistrationForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *repeatPassword;
@property (nonatomic, copy) NSString *email;


@end
