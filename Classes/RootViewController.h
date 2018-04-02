//
//  RootViewController.h
//  Pet Pic
//
//  Created by Rafael Gaino on 11/1/10.
//  Copyright 2010 PunkOpera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FBConnect.h"

@interface RootViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, 
												     AVAudioPlayerDelegate, FBSessionDelegate, FBRequestDelegate,
													UITextViewDelegate> { 

	//overlay view outlets
	IBOutlet UIView *overlayView;
	IBOutlet UIButton *flashButton;
	IBOutlet UIButton *shutterButton;
	IBOutlet UIButton *dogButton;
	IBOutlet UIButton *catButton;
	IBOutlet UIButton *squeakyButton;
														
	//share screen outlets
	IBOutlet UIImageView *assetImageView;
	IBOutlet UITextView *pictureCaptionTextView;
	IBOutlet UIButton *connectFacebookButton;
	IBOutlet UISwitch *facebookSwitch;
	IBOutlet UIButton *saveAndPublishButton;
	IBOutlet UIView *waitIndicatorView;
    IBOutlet UILabel *waitingLabel;
	IBOutlet UILabel *facebookLabel;
														
	UIImagePickerController *imagePicker;
	NSMutableArray *sounds;
	AVAudioPlayer *audioPlayer;
	BOOL isPlayingSound;
	BOOL isFirstTimeLoadingApp;
	ALAssetsLibrary *library;
	NSDictionary *currentMediaInfo;
	
	
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, retain) IBOutlet UIButton *flashButton;
@property (nonatomic, retain) IBOutlet UIButton *shutterButton;
@property (nonatomic, retain) IBOutlet UIButton *dogButton;
@property (nonatomic, retain) IBOutlet UIButton *catButton;
@property (nonatomic, retain) IBOutlet UIButton *squeakyButton;


@property (nonatomic, retain) IBOutlet UIImageView *assetImageView;
@property (nonatomic, retain) IBOutlet UIView *waitIndicatorView;
@property (nonatomic, retain) IBOutlet UIButton *connectFacebookButton;
@property (nonatomic, retain) IBOutlet UISwitch *facebookSwitch;
@property (nonatomic, retain) IBOutlet UILabel *facebookLabel;
@property (nonatomic, retain) IBOutlet UITextView *pictureCaptionTextView;
@property (nonatomic, retain) IBOutlet UIButton *saveAndPublishButton;
@property (nonatomic, retain) IBOutlet UILabel *waitingLabel;
@property BOOL isFirstTimeLoadingApp;

//overlay view actions
-(IBAction) playSound;
-(IBAction) stopSounds;
-(IBAction) shutterPressed;
-(IBAction) flashPressed;
-(IBAction) cameraModePressed;
-(IBAction) doneButtonPressed;
-(IBAction) backButtonPressed;
-(IBAction) connectFacebookPressed;
-(IBAction) facebookSwitchPressed;

-(void) showCamera;
-(void) loadSounds;
-(IBAction) loadDogSounds;
-(IBAction) loadCatSounds;
-(IBAction) loadSqueakySounds;
-(void) setupOverlayView;
-(void) setupImagePicker;
-(void) showAlertForError:(NSError *) error;
//-(void) moveToShareScreenWithAsset:(NSURL *) assetURL;
//-(void) loadAssetToShare;
-(void) showWaitView;
-(void) hideWaitView;
-(void) showWaitMessage:(NSString *)message;
-(void) setupFacebook;
-(void) saveCurrentMedia;
-(void) publishOnFacebook;
-(void) disconnectFacebook;
-(UIImage*) scaleAndRotateImage:(UIImage*)image;

@end
