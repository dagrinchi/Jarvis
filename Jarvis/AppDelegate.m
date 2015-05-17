//
//  AppDelegate.m
//  Jarvis
//
//  Created by David Almeciga on 5/16/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:21.0], NSFontAttributeName, nil]];
    
    NSError *error = nil;
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    //REGISTRATION REQUEST MAPPING
    RKObjectMapping *registrationRqMapping = [RKObjectMapping requestMapping];
    [registrationRqMapping addAttributeMappingsFromDictionary:@{@"email"         :@"Email",
                                                                @"password"      :@"Password",
                                                                @"repeatPassword":@"ConfirmPassword"}];
    
    //REGISTRATION RESPONSE MAPPING
    RKObjectMapping *registrationRpMapping = [RKObjectMapping mappingForClass:[Registration class]];
    [registrationRpMapping addAttributeMappingsFromDictionary:@{@"email"         :@"Email"}];
    
    //DEVICE STATUS RESPONSE MAPPING
    RKObjectMapping *deviceStatusRpMapping = [RKObjectMapping mappingForClass:[Registration class]];
    [registrationRpMapping addAttributeMappingsFromDictionary:@{@"identification"   :@"Identification",
                                                                @"status"           :@"Status",
                                                                @"created"          :@"Created"}];
    
    //LOGIN REQUEST MAPPING
    RKObjectMapping *loginRqMapping = [RKObjectMapping requestMapping];
    [loginRqMapping addAttributeMappingsFromDictionary:@{@"grantType":@"grant_type",
                                                         @"username" :@"username",
                                                         @"password" :@"password"}];
    
    //TOKEN RESPONSE MAPPING
    RKEntityMapping *tokenMapping = [RKEntityMapping mappingForEntityForName:@"Token" inManagedObjectStore:managedObjectStore];
    [tokenMapping addAttributeMappingsFromDictionary:@{@"access_token"  :@"accessToken",
                                                       @"token_type"    :@"tokenType",
                                                       @"expires_in"    :@"expiresIn",
                                                       @"userName"      :@"userName",
                                                       @".issued"       :@"expiresAt",
                                                       @".expires"      :@"issuedAt"}];
    
    // CORE DATA INITIALIZATION
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Agronegocios.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (! persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    
    [managedObjectStore createManagedObjectContexts];
    [managedObjectStore startIndexingPersistentStoreManagedObjectContext];
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
//    objectManager.managedObjectStore = managedObjectStore;
    
    // RESPONSE DESCRIPTORS
    NSArray *responseDescriptors = @[[RKResponseDescriptor responseDescriptorWithMapping:registrationRpMapping
                                                                                  method:RKRequestMethodPOST
                                                                             pathPattern:REGISTER_PATH
                                                                                 keyPath:nil
                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
                                     [RKResponseDescriptor responseDescriptorWithMapping:deviceStatusRpMapping
                                                                                  method:RKRequestMethodPOST
                                                                             pathPattern:DEVICE_STATUS_PATH
                                                                                 keyPath:nil
                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
                                     [RKResponseDescriptor responseDescriptorWithMapping:tokenMapping
                                                                                  method:RKRequestMethodPOST
                                                                             pathPattern:TOKEN_PATH
                                                                                 keyPath:nil
                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    [objectManager addResponseDescriptorsFromArray:responseDescriptors];
    
    // REQUEST DESCRIPTOR
    NSArray *requestDescriptors = @[[RKRequestDescriptor requestDescriptorWithMapping:registrationRqMapping
                                                                          objectClass:[Registration class]
                                                                          rootKeyPath:nil
                                                                               method:RKRequestMethodPOST],
                                    [RKRequestDescriptor requestDescriptorWithMapping:loginRqMapping
                                                                          objectClass:[Login class]
                                                                          rootKeyPath:nil
                                                                               method:RKRequestMethodPOST]];
    [objectManager addRequestDescriptorsFromArray:requestDescriptors];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

@end
