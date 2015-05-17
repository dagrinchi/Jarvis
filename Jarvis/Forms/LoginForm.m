//
//  LoginForm.m
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import "LoginForm.h"

@implementation LoginForm

- (NSArray *)fields {
    return @[@{FXFormFieldKey: @"email",
               FXFormFieldTitle: @"Email",
               @"textLabel.font": [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0]},
             @{FXFormFieldKey: @"password",
               FXFormFieldTitle: @"Password",
               @"textLabel.font": [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0]}];
}

- (NSArray *)extraFields
{
    return @[@{FXFormFieldHeader: @"",
               FXFormFieldTitle: @"LogIn",
               FXFormFieldCell: [SubmitButtonCell class],
               FXFormFieldAction: @"submitLoginForm:"}];
}

@end
