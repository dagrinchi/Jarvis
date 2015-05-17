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

@end

@implementation MainViewController

#define kLevelUpdatesPerSecond 1000000
#define kGetNbest

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fliteController = [[OEFliteController alloc] init];
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    self.slt = [[Slt alloc] init];
    
    self.restartAttemptsDueToPermissionRequests = 0;
    self.startupFailedDueToLackOfPermissions = FALSE;
    
   
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"button-3" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    
    SystemSoundID audioEffect;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
    
    [OELogging startOpenEarsLogging];
    [OEPocketsphinxController sharedInstance].verbosePocketSphinx = TRUE;
    
    [self.openEarsEventsObserver setDelegate:self];
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    
//    NSArray *firstLanguageArray = @[@"START",
//                                    @"ADJUST MIRRORS",
//                                    @"ADJUST MY CHAIR",
//                                    @"SCAN THE REAR",
//                                    @"HOW MANY FUEL TO MY HOUSE",
//                                    @"OPEN MY WINDOW",
//                                    @"CLOSE SUNROOT"];
    
    NSDictionary *firstLanguageDict = @{
                                        ThisWillBeSaidOnce : @[
                                                @{ OneOfTheseCanBeSaidOnce : @[@"HELLO JARVIS", @"JARVIS"]},
                                                @{ OneOfTheseWillBeSaidOnce : @[@"START", @"OPEN", @"CLOSE", @"SCAN", @"READ"]},
                                                @{ OneOfTheseWillBeSaidOnce : @[@"THE CAR", @"MY WINDOW", @"MY CHAIR", @"MY DOOR", @"THE INSTRUMENTS"]}
                                        ]};
    
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    
    languageModelGenerator.verboseLanguageModelGenerator = TRUE;
    
    //NSError *error = [languageModelGenerator generateLanguageModelFromArray:firstLanguageArray withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    NSError *error = [languageModelGenerator generateGrammarFromDictionary:firstLanguageDict withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
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
        
        self.startButton.hidden = TRUE;
        self.stopButton.hidden = TRUE;
    }

    
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    
    NSLog(@"Local callback: The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Log it.
    
    if([hypothesis containsString:@"OPEN"]) {
        
    } else if ([hypothesis containsString:@"CLOSE"]) {
        
    } else if ([hypothesis containsString:@"START"]) {
        
    }
    
    //self.heardTextView.text = [NSString stringWithFormat:@"Heard: \"%@\"", hypothesis]; // Show it in the status box.
    [self.fliteController say:[NSString stringWithFormat:@"You said %@", hypothesis] withVoice:self.slt];
}

#ifdef kGetNbest
- (void) pocketsphinxDidReceiveNBestHypothesisArray:(NSArray *)hypothesisArray { // Pocketsphinx has an n-best hypothesis dictionary.
    NSLog(@"Local callback:  hypothesisArray is %@",hypothesisArray);
}
#endif

- (void) audioSessionInterruptionDidBegin {
    NSLog(@"Local callback:  AudioSession interruption began."); // Log it.
    //self.statusTextView.text = @"Status: AudioSession interruption began."; // Show it in the status box.
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) {
        error = [[OEPocketsphinxController sharedInstance] stopListening]; // React to it by telling Pocketsphinx to stop listening (if it is listening) since it will need to restart its loop after an interruption.
        if(error) NSLog(@"Error while stopping listening in audioSessionInterruptionDidBegin: %@", error);
    }
}


- (void) audioSessionInterruptionDidEnd {
    NSLog(@"Local callback:  AudioSession interruption ended."); // Log it.
    // self.statusTextView.text = @"Status: AudioSession interruption ended."; // Show it in the status box.
    // We're restarting the previously-stopped listening loop.
    if(![OEPocketsphinxController sharedInstance].isListening){
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't currently listening.
    }
}


- (void) audioInputDidBecomeUnavailable {
    NSLog(@"Local callback:  The audio input has become unavailable"); // Log it.
    // self.statusTextView.text = @"Status: The audio input has become unavailable"; // Show it in the status box.
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening){
        error = [[OEPocketsphinxController sharedInstance] stopListening]; // React to it by telling Pocketsphinx to stop listening since there is no available input (but only if we are listening).
        if(error) NSLog(@"Error while stopping listening in audioInputDidBecomeUnavailable: %@", error);
    }
}


- (void) audioInputDidBecomeAvailable {
    NSLog(@"Local callback: The audio input is available"); // Log it.
    // self.statusTextView.text = @"Status: The audio input is available"; // Show it in the status box.
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition, but only if we aren't already listening.
    }
}

- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
    NSLog(@"Local callback: Audio route change. The new audio route is %@", newRoute); // Log it.
    //self.statusTextView.text = [NSString stringWithFormat:@"Status: Audio route change. The new audio route is %@",newRoute]; // Show it in the status box.
    
    NSError *error = [[OEPocketsphinxController sharedInstance] stopListening]; // React to it by telling the Pocketsphinx loop to shut down and then start listening again on the new route
    
    if(error)NSLog(@"Local callback: error while stopping listening in audioRouteDidChangeToRoute: %@",error);
    
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
    }
}


- (void) pocketsphinxRecognitionLoopDidStart {
    
    NSLog(@"Local callback: Pocketsphinx started."); // Log it.
    //self.statusTextView.text = @"Status: Pocketsphinx started."; // Show it in the status box.
}


- (void) pocketsphinxDidStartListening {
    
    NSLog(@"Local callback: Pocketsphinx is now listening."); // Log it.
    //self.statusTextView.text = @"Status: Pocketsphinx is now listening."; // Show it in the status box.
    
    self.startButton.hidden = TRUE; // React to it with some UI changes.
    self.stopButton.hidden = FALSE;
}


- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Local callback: Pocketsphinx has detected speech."); // Log it.
    //self.statusTextView.text = @"Status: Pocketsphinx has detected speech."; // Show it in the status box.
}


- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Local callback: Pocketsphinx has detected a second of silence, concluding an utterance."); // Log it.
    [self stopButtonAction];
    //self.statusTextView.text = @"Status: Pocketsphinx has detected finished speech."; // Show it in the status box.
}



- (void) pocketsphinxDidStopListening {
    NSLog(@"Local callback: Pocketsphinx has stopped listening."); // Log it.
    //self.statusTextView.text = @"Status: Pocketsphinx has stopped listening."; // Show it in the status box.
}


- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Local callback: Pocketsphinx has suspended recognition."); // Log it.
    //self.statusTextView.text = @"Status: Pocketsphinx has suspended recognition."; // Show it in the status box.
}


- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Local callback: Pocketsphinx has resumed recognition."); // Log it.
    //self.statusTextView.text = @"Status: Pocketsphinx has resumed recognition."; // Show it in the status box.
}


- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Local callback: Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}


- (void) fliteDidStartSpeaking {
    NSLog(@"Local callback: Flite has started speaking"); // Log it.
    //self.statusTextView.text = @"Status: Flite has started speaking."; // Show it in the status box.
}

- (void) fliteDidFinishSpeaking {
    NSLog(@"Local callback: Flite has finished speaking"); // Log it.
    //self.statusTextView.text = @"Status: Flite has finished speaking."; // Show it in the status box.
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
    NSLog(@"Local callback: Setting up the continuous recognition loop has failed for the reason %@, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure); // Log it.
    //self.statusTextView.text = @"Status: Not possible to start recognition loop."; // Show it in the status box.
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
    NSLog(@"Local callback: Tearing down the continuous recognition loop has failed for the reason %@, please turn on [OELogging startOpenEarsLogging] to learn more.", reasonForFailure); // Log it.
    //self.statusTextView.text = @"Status: Not possible to cleanly end recognition loop."; // Show it in the status box.
}

- (void) testRecognitionCompleted { // A test file which was submitted for direct recognition via the audio driver is done.
    NSLog(@"Local callback: A test file which was submitted for direct recognition via the audio driver is done."); // Log it.
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) { // If we're listening, stop listening.
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error) NSLog(@"Error while stopping listening in testRecognitionCompleted: %@", error);
    }
    
}

- (void) pocketsphinxFailedNoMicPermissions {
    NSLog(@"Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.");
    self.startupFailedDueToLackOfPermissions = TRUE;
    if([OEPocketsphinxController sharedInstance].isListening){
        NSError *error = [[OEPocketsphinxController sharedInstance] stopListening]; // Stop listening if we are listening.
        if(error) NSLog(@"Error while stopping listening in micPermissionCheckCompleted: %@", error);
    }
}


- (void) micPermissionCheckCompleted:(BOOL)result {
    if(result) {
        self.restartAttemptsDueToPermissionRequests++;
        if(self.restartAttemptsDueToPermissionRequests == 1 && self.startupFailedDueToLackOfPermissions) { // If we get here because there was an attempt to start which failed due to lack of permissions, and now permissions have been requested and they returned true, we restart exactly once with the new permissions.
            
            if(![OEPocketsphinxController sharedInstance].isListening) { // If there was no error and we aren't listening, start listening.
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


- (IBAction) suspendListeningButtonAction { // This is the action for the button which suspends listening without ending the recognition loop
    [[OEPocketsphinxController sharedInstance] suspendRecognition];
    
    self.startButton.hidden = TRUE;
    self.stopButton.hidden = FALSE;
    //self.suspendListeningButton.hidden = TRUE;
    //self.resumeListeningButton.hidden = FALSE;
}

- (IBAction) resumeListeningButtonAction { // This is the action for the button which resumes listening if it has been suspended
    [[OEPocketsphinxController sharedInstance] resumeRecognition];
    
    self.startButton.hidden = TRUE;
    self.stopButton.hidden = FALSE;
//    self.suspendListeningButton.hidden = FALSE;
//    self.resumeListeningButton.hidden = TRUE;
}

- (void) startDisplayingLevels { // Start displaying the levels using a timer
    [self stopDisplayingLevels]; // We never want more than one timer valid so we'll stop any running timers first.
    self.uiUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/kLevelUpdatesPerSecond target:self selector:@selector(updateLevelsUI) userInfo:nil repeats:YES];
}
- (IBAction)stopButtonAction {
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) { // Stop if we are currently listening.
        error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)NSLog(@"Error stopping listening in stopButtonAction: %@", error);
    }
    self.startButton.hidden = FALSE;
    self.stopButton.hidden = TRUE;
}

- (void) stopDisplayingLevels { // Stop displaying the levels by stopping the timer if it's running.
    if(self.uiUpdateTimer && [self.uiUpdateTimer isValid]) { // If there is a running timer, we'll stop it here.
        [self.uiUpdateTimer invalidate];
        self.uiUpdateTimer = nil;
    }
}

- (void) updateLevelsUI { // And here is how we obtain the levels.  This method includes the actual OpenEars methods and uses their results to update the UI of this view controller.
    
    self.inLevelLabel.text = [NSString stringWithFormat:@"%f",[[OEPocketsphinxController sharedInstance] pocketsphinxInputLevel]];  //pocketsphinxInputLevel is an OpenEars method of the class OEPocketsphinxController.
    
    if(self.fliteController.speechInProgress) {
        self.outLevelLabel.text = [NSString stringWithFormat:@"%f",[self.fliteController fliteOutputLevel]]; // fliteOutputLevel is an OpenEars method of the class OEFliteController.
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)startButtonAction:(UIButton *)sender {
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't already listening.
    }
    self.startButton.hidden = TRUE;

}
@end
