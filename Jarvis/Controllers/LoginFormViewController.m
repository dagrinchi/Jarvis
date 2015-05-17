//
//  LoginFormViewController.m
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import "LoginFormViewController.h"

@interface LoginFormViewController ()

@end

@implementation LoginFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formController.form = [[RootForm alloc] init];
    UIColor *bgColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.tableView.backgroundView.backgroundColor = bgColor;
    self.tableView.backgroundColor = bgColor;
    self.view.backgroundColor = bgColor;
    
    self.title = @"LogIn";
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


- (void)submitLoginForm:(UITableViewCell<FXFormFieldCell> *)cell
{
    LoginForm *form = cell.field.form;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = @"Login in progress!";
    hud.color = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0.5];
    
        [hud show:YES];
        
        Login *login = [Login new];
        login.grantType = GRANT_TYPE;
        login.username = form.email;
        login.password = form.password;
        
        [[RKObjectManager sharedManager] postObject:login
                                               path:TOKEN_PATH
                                         parameters:nil
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                hud.labelText = @"Ready!";
                                                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                                                hud.mode = MBProgressHUDModeCustomView;
                                                
                                                NSString *path  = [[NSBundle mainBundle] pathForResource:@"button-3" ofType:@"wav"];
                                                NSURL *pathURL = [NSURL fileURLWithPath : path];
                                                
                                                SystemSoundID audioEffect;
                                                AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
                                                AudioServicesPlaySystemSound(audioEffect);
                                                
                                                [self performSelector:@selector(goApp:) withObject:hud afterDelay:1.5];
                                            }
                                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                //RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
                                                ShowAlertWithError(@"Invalid email or password!");
                                                [hud hide:YES];
                                            }];
}


-(void) goApp:(MBProgressHUD *)hud {
    [hud hide:YES];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.navigationController pushViewController:[storyBoard instantiateViewControllerWithIdentifier:@"MainView"] animated:TRUE];
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
