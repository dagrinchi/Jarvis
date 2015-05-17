//
//  RegistrationFormViewController.h
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FXForms.h"
#import "RegistrationForm.h"
#import <RestKit/RestKit.h>
#import "Registration.h"
#import "MBProgressHUD.h"
#import "Webservice.h"

@interface RegistrationFormViewController : FXFormViewController

@property (nonatomic, strong) RegistrationForm *registrationForm;

@end
