//
//  MainViewController.h
//  Jarvis
//
//  Created by David Almeciga on 5/16/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEFliteController.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OELogging.h>
#import <OpenEars/OEAcousticModel.h>
#import <Slt/Slt.h>
#import <OpenEars/OEEventsObserver.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MainViewController : UIViewController <OEEventsObserverDelegate>

@end