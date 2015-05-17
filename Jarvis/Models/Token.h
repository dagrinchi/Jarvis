//
//  Token.h
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Token : NSManagedObject

@property (nonatomic, retain) NSString * accessToken;
@property (nonatomic, retain) NSDate * expiresAt;
@property (nonatomic, retain) NSNumber * expiresIn;
@property (nonatomic, retain) NSDate * issuedAt;
@property (nonatomic, retain) NSString * tokenType;
@property (nonatomic, retain) NSString * userName;

@end
