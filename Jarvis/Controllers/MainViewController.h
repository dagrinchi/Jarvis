//
//  MainViewController.h
//  Jarvis
//
//  Created by David Almeciga on 5/16/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEFliteController.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OELogging.h>
#import <OpenEars/OEAcousticModel.h>
#import <Slt/Slt.h>
#import <OpenEars/OEEventsObserver.h>
#import "FLAnimatedImage.h"
#import "DeviceStatus.h"
#import <RestKit/RestKit.h>
#import "Webservice.h"
#import "MBProgressHUD.h"

@interface MainViewController : UIViewController <OEEventsObserverDelegate>

@end
