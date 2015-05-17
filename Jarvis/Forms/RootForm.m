//
//  RootForm.m
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import "RootForm.h"

@implementation RootForm

- (NSDictionary *)loginField {
    return @{ FXFormFieldHeader: @"Sign In",
              FXFormFieldInline: @YES };
}

- (NSDictionary *)registrationField {
    return @{ FXFormFieldHeader: @"¿Dont have account?",
              FXFormFieldTitle: @"Register",
              @"textLabel.font": [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0]};
}


@end
