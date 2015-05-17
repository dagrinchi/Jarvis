//
//  RegistrationFormViewController.m
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import "RegistrationFormViewController.h"

@interface RegistrationFormViewController ()

@end

@implementation RegistrationFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.registrationForm = [[RegistrationForm alloc] init];
    self.formController.form = self.registrationForm;
    
    UIColor *bgColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.tableView.backgroundView.backgroundColor = bgColor;
    self.tableView.backgroundColor = bgColor;
    self.view.backgroundColor = bgColor;
    
    self.title = @"SignUp";
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.tableView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.82 alpha:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


- (void)submitRegistrationForm:(UITableViewCell<FXFormFieldCell> *)cell {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.detailsLabelText = @"¡Register in progress!";
    hud.color = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0.5];
    
    
        [hud show:YES];
        
        Registration *registration = [Registration new];
        registration.email = self.registrationForm.email;
        registration.password = self.registrationForm.password;
        registration.repeatPassword = self.registrationForm.repeatPassword;
        
        [[RKObjectManager sharedManager] postObject:registration
                                               path:REGISTER_PATH
                                         parameters:nil
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                hud.detailsLabelText = @"¡Success!";
                                                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                                                hud.mode = MBProgressHUDModeCustomView;

                                                [self performSelector:@selector(returnToLogin:) withObject:hud afterDelay:1.5];
                                                
                                            }
                                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                ShowAlertWithError(error.localizedDescription);
                                                [hud hide:YES];
                                            }];
}

-(void)returnToLogin:(MBProgressHUD *) hud {
    [hud hide:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

static void ShowAlertWithError(NSString *error)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
