//
//  MainViewController.m
//  Jarvis
//
//  Created by David Almeciga on 5/16/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UITextField *outLevelLabel;
@property (strong, nonatomic) IBOutlet UITextField *inLevelLabel;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;

@property (nonatomic, strong) Slt *slt;

@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) OEFliteController *fliteController;

@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedDictionary;
@property (nonatomic, copy) NSString *pathToSecondDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToSecondDynamicallyGeneratedDictionary;

@property (nonatomic, strong) 	NSTimer *uiUpdateTimer;

@property (nonatomic, assign) BOOL usingStartingLanguageModel;
@property (nonatomic, assign) int restartAttemptsDueToPermissionRequests;
@property (nonatomic, assign) BOOL startupFailedDueToLackOfPermissions;

@property (strong, nonatomic) IBOutlet UIButton *keyButton;
@property (strong, nonatomic) IBOutlet UIButton *powerButton;

@end

@implementation MainViewController

#define kLevelUpdatesPerSecond 10000000
#define kGetNbest

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fliteController = [[OEFliteController alloc] init];
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    self.slt = [[Slt alloc] init];
    
    self.restartAttemptsDueToPermissionRequests = 0;
    self.startupFailedDueToLackOfPermissions = FALSE;
    
    [OELogging startOpenEarsLogging];
    [OEPocketsphinxController sharedInstance].verbosePocketSphinx = TRUE;
    
    [self.openEarsEventsObserver setDelegate:self];
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    
    NSArray *firstLanguageArray = @[@"OPEN", @"CLOSE", @"START", @"STOP"];
    
//    NSDictionary *firstLanguageDict = @{
//                                        ThisWillBeSaidOnce : @[
//                                                @{ OneOfTheseCanBeSaidOnce : @[@"HELLO JARVIS", @"JARVIS"]},
//                                                @{ OneOfTheseWillBeSaidOnce : @[@"START", @"OPEN", @"CLOSE", @"SCAN", @"READ"]},
//                                                @{ OneOfTheseWillBeSaidOnce : @[@"THE CAR", @"MY WINDOW", @"MY CHAIR", @"MY DOOR", @"THE INSTRUMENTS"]}
//                                        ]};
    
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    
    languageModelGenerator.verboseLanguageModelGenerator = TRUE;
    
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:firstLanguageArray withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
//    NSError *error = [languageModelGenerator generateGrammarFromDictionary:firstLanguageDict withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    } else {
        self.pathToFirstDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
        self.pathToFirstDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
    }
    
    self.usingStartingLanguageModel = TRUE;
    
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    }	else {
        
        self.pathToSecondDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"SecondOpenEarsDynamicLanguageModel"];
        self.pathToSecondDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"SecondOpenEarsDynamicLanguageModel"];
        
        
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
        
        if(![OEPocketsphinxController sharedInstance].isListening) {
            [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
        }
        
        [self startDisplayingLevels];
        
        self.startButton.enabled = FALSE;
        self.stopButton.enabled = FALSE;
    }

    NSURL *imgPath = [[NSBundle mainBundle] URLForResource:@"wave" withExtension:@"gif"];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:imgPath]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = CGRectMake(0.0, 0.0, 320, 320.0);
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    
    NSLog(@"Local callback: The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DeviceStatus" inManagedObjectContext:context];
    DeviceStatus *deviceStatus = [[DeviceStatus alloc]initWithEntity:entity insertIntoManagedObjectContext:context];
    
    deviceStatus.id = @1;
    deviceStatus.identification = @"DEV001";
    deviceStatus.created = @12311231;
    
    if([hypothesis containsString:@"OPEN"]) {
        deviceStatus.status = @1;
    } else if ([hypothesis containsString:@"CLOSE"]) {
        deviceStatus.status = @2;
    } else if ([hypothesis containsString:@"START"]) {
        deviceStatus.status = @3;
    } else if ([hypothesis containsString:@"STOP"]) {
        deviceStatus.status = @4;
    }
    [self putDeviceStatus:deviceStatus];
    [self.fliteController say:[NSString stringWithFormat:@"Command %@ in progress", hypothesis] withVoice:self.slt];
}

#ifdef kGetNbest
- (void) pocketsphinxDidReceiveNBestHypothesisArray:(NSArray *)hypothesisArray {
    NSLog(@"Local callback:  hypothesisArray is %@",hypothesisArray);
}
#endif

- (void) audioSessionInterruptionDidBegin {
    NSLog(@"Local callback:  AudioSession interruption began.");
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) {
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error) NSLog(@"Error while stopping listening in audioSessionInterruptionDidBegin: %@", error);
    }
}


- (void) audioSessionInterruptionDidEnd {
    NSLog(@"Local callback:  AudioSession interruption ended.");
    
    if(![OEPocketsphinxController sharedInstance].isListening){
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
    }
}


- (void) audioInputDidBecomeUnavailable {
    NSLog(@"Local callback:  The audio input has become unavailable");
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening){
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        
        if(error) NSLog(@"Error while stopping listening in audioInputDidBecomeUnavailable: %@", error);
    }
}


- (void) audioInputDidBecomeAvailable {
    NSLog(@"Local callback: The audio input is available");

    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
    }
}

- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
    NSLog(@"Local callback: Audio route change. The new audio route is %@", newRoute);
    
    NSError *error = [[OEPocketsphinxController sharedInstance] stopListening];
    
    if(error)NSLog(@"Local callback: error while stopping listening in audioRouteDidChangeToRoute: %@",error);
    
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
    }
}


- (void) pocketsphinxRecognitionLoopDidStart {
    
    NSLog(@"Local callback: Pocketsphinx started.");
}


- (void) pocketsphinxDidStartListening {
    
    NSLog(@"Local callback: Pocketsphinx is now listening.");
    
    self.startButton.enabled = FALSE;
    self.stopButton.enabled = TRUE;
}


- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Local callback: Pocketsphinx has detected speech.");
}


- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Local callback: Pocketsphinx has detected a second of silence, concluding an utterance.");
    [self stopButtonAction];
}



- (void) pocketsphinxDidStopListening {
    NSLog(@"Local callback: Pocketsphinx has stopped listening.");
}


- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Local callback: Pocketsphinx has suspended recognition.");
}


- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Local callback: Pocketsphinx has resumed recognition.");
}


- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Local callback: Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}


- (void) fliteDidStartSpeaking {
    NSLog(@"Local callback: Flite has started speaking");
}

- (void) fliteDidFinishSpeaking {
    NSLog(@"Local callback: Flite has finished speaking");
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Local callback: Setting up the continuous recognition loop has failed for the reason %@, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Local callback: Tearing down the continuous recognition loop has failed for the reason %@, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure);
    
}

- (void) testRecognitionCompleted {
    NSLog(@"Local callback: A test file which was submitted for direct recognition via the audio driver is done.");
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) {
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error) NSLog(@"Error while stopping listening in testRecognitionCompleted: %@", error);
    }
    
}

- (void) pocketsphinxFailedNoMicPermissions {
    NSLog(@"Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.");
    self.startupFailedDueToLackOfPermissions = TRUE;
    if([OEPocketsphinxController sharedInstance].isListening){
        NSError *error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error) NSLog(@"Error while stopping listening in micPermissionCheckCompleted: %@", error);
    }
}


- (void) micPermissionCheckCompleted:(BOOL)result {
    if(result) {
        self.restartAttemptsDueToPermissionRequests++;
        if(self.restartAttemptsDueToPermissionRequests == 1 && self.startupFailedDueToLackOfPermissions) {
            
            if(![OEPocketsphinxController sharedInstance].isListening) {
                [[OEPocketsphinxController sharedInstance]
                 startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel
                 dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary
                 acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]
                 languageModelIsJSGF:FALSE]; // Start speech recognition.
                
                self.startupFailedDueToLackOfPermissions = FALSE;
            }
        }
    }
}


- (IBAction) suspendListeningButtonAction {
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
    
    self.startButton.enabled = FALSE;
    self.stopButton.enabled = TRUE;
    //self.suspendListeningButton.hidden = TRUE;
    //self.resumeListeningButton.hidden = FALSE;
}

- (IBAction) resumeListeningButtonAction {
    [[OEPocketsphinxController sharedInstance] resumeRecognition];
    
    self.startButton.enabled = FALSE;
    self.stopButton.enabled = TRUE;
}

- (void) startDisplayingLevels {
    [self stopDisplayingLevels];
    self.uiUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/kLevelUpdatesPerSecond target:self selector:@selector(updateLevelsUI) userInfo:nil repeats:YES];
}
- (IBAction)stopButtonAction {
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) {
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
    }
    self.startButton.enabled = TRUE;
    self.stopButton.enabled = FALSE;
}

- (void) stopDisplayingLevels {
    if(self.uiUpdateTimer && [self.uiUpdateTimer isValid]) {
        [self.uiUpdateTimer invalidate];
        self.uiUpdateTimer = nil;
    }
}

- (void) updateLevelsUI {
    
    self.inLevelLabel.text = [NSString stringWithFormat:@"%f",[[OEPocketsphinxController sharedInstance] pocketsphinxInputLevel]];
    if(self.fliteController.speechInProgress) {
        self.outLevelLabel.text = [NSString stringWithFormat:@"%f",[self.fliteController fliteOutputLevel]];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)powerButtonAction:(id)sender {
//    DeviceStatus *deviceStatus = [DeviceStatus new];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DeviceStatus" inManagedObjectContext:context];
    DeviceStatus *deviceStatus = [[DeviceStatus alloc]initWithEntity:entity insertIntoManagedObjectContext:context];
    
    deviceStatus.id = @1;
    deviceStatus.identification = @"DEV002";
    deviceStatus.created = @0;
    
    if([sender isSelected]){
        deviceStatus.status = @3;
        [sender setSelected:NO];
    } else {
        deviceStatus.status = @4;
        [sender setSelected:YES];
    }
    
    
    [self putDeviceStatus:deviceStatus];
}

- (IBAction)keyButtonAction:(id)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DeviceStatus" inManagedObjectContext:context];
    DeviceStatus *deviceStatus = [[DeviceStatus alloc]initWithEntity:entity insertIntoManagedObjectContext:context];
    
    deviceStatus.id = @1;
    deviceStatus.identification = @"DEV001";
    deviceStatus.created = @0;
    
    if([sender isSelected]){
        deviceStatus.status = @1;
        [sender setSelected:NO];
    } else {
        deviceStatus.status = @2;
        [sender setSelected:YES];
    }
    
    [self putDeviceStatus:deviceStatus];
}

- (void) putDeviceStatus:(DeviceStatus *)deviceStatus {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.detailsLabelText = @"¡Command in progress!";
    hud.color = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0.5];
    
    //        RKObjectManager *objectManager = [RKObjectManager sharedManager];
    //        NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    //        DeviceStatus *deviceStatus = [NSEntityDescription insertNewObjectForEntityForName:@"DeviceStatus" inManagedObjectContext:context];
    [[RKObjectManager sharedManager] putObject:deviceStatus
                                          path:[NSString stringWithFormat:@"%@/%@", DEVICE_STATUS_PATH, deviceStatus.id]
                                    parameters:nil
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           hud.detailsLabelText = @"¡Success!";
                                           hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                                           hud.mode = MBProgressHUDModeCustomView;
                                           
                                       }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                           ShowAlertWithError(error.localizedDescription);
                                           [hud hide:YES];
                                       }];
}

static void ShowAlertWithError(NSString *error)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


- (IBAction)startButtonAction:(UIButton *)sender {
    
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
    }
    self.startButton.enabled = FALSE;

}

@end
