//
//  RegistrationForm.m
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import "RegistrationForm.h"

@implementation RegistrationForm

- (NSArray *)fields {
    return @[@{FXFormFieldKey: @"email",
               @"textLabel.font": [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0],
               FXFormFieldTitle: @"E-mail"},
             @{FXFormFieldKey: @"password",
               @"textLabel.font": [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0],
               FXFormFieldTitle: @"Password",
               @"textLabel.font": [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0],
               FXFormFieldHeader: @"Use at least 6 digits"},
             @{FXFormFieldKey: @"repeatPassword",
               @"textLabel.font": [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0],
               FXFormFieldTitle: @"Password Confirm"}];
}

- (NSArray *)extraFields
{
    return @[@{FXFormFieldTitle: @"Send",
               FXFormFieldHeader: @"",
               FXFormFieldCell: [SubmitButtonCell class],
               FXFormFieldAction: @"submitRegistrationForm:"}];
}

@end
