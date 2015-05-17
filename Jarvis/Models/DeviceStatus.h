//
//  DeviceStatus.h
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DeviceStatus : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * identification;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * created;

@end
