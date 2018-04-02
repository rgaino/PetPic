//
//  RootViewController.m
//  Pet Pic
//
//  Created by Rafael Gaino on 11/1/10.
//  Copyright 2010 PunkOpera. All rights reserved.
//

#import "RootViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Pet_PicAppDelegate.h"
#import "FBConnect.h"
#import <MediaPlayer/MPVolumeView.h>
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"


#define kSoundIndexDefault @"SoundIndexKey"
#define kFacebookAppId @"140495779334740"

@implementation RootViewController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize overlayView, flashButton, shutterButton, assetImageView, waitIndicatorView;
@synthesize connectFacebookButton, facebookLabel, facebookSwitch, pictureCaptionTextView, saveAndPublishButton, waitingLabel;
@synthesize squeakyButton, catButton, dogButton;
@synthesize isFirstTimeLoadingApp;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"Pet Pic"];
	[self.navigationController setNavigationBarHidden:YES];

	library = [[ALAssetsLibrary alloc] init];

	[self loadSounds];
	[self setupOverlayView];
	[self setupImagePicker];
	
}


-(void)viewWillAppear:(BOOL)animated {

	[self setupFacebook];
	
	if(isFirstTimeLoadingApp) {
		isFirstTimeLoadingApp = NO;
		[self showCamera];
	}
}

#pragma mark IBActions

-(IBAction) doneButtonPressed {

	[self performSelector:@selector(showWaitView) withObject:nil];
	
	if( [facebookSwitch isOn]) {
		[self publishOnFacebook];		
	} else {		
		[self saveCurrentMedia];
	}

}		


-(IBAction) backButtonPressed {
	
	[currentMediaInfo release];
	[self showCamera];
}



-(IBAction) playSound {
	
	if(isPlayingSound) {
		
		NSError *err;
		int soundIndex = arc4random() % [sounds count];

		audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[sounds objectAtIndex:soundIndex] error:&err];
		if( err ){
			NSLog(@"Failed with reason: %@", [err localizedDescription]);
		} else {
			audioPlayer.delegate = self;
			[audioPlayer play];
		}
	}
	
}


-(IBAction) stopSounds {
	isPlayingSound = NO;
}


-(void) showCamera {
	
	isPlayingSound = YES;
	[pictureCaptionTextView setText:@""];
	[self presentModalViewController:imagePicker animated:YES];
	
	[self performSelector:@selector(playSound) withObject:nil afterDelay:2.0f];
}


-(IBAction) flashPressed {
	
	if( [imagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeOff ) {
		[flashButton setImage:[UIImage imageNamed:@"flash_auto"] forState:UIControlStateNormal];
		[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeAuto];
	}
	else if( [imagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeAuto ) {
		[flashButton setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
		[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
	}
	else if( [imagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeOn ) {
		[flashButton setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
		[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
	}
}


-(IBAction) cameraModePressed {
	
	if( [imagePicker cameraCaptureMode] == UIImagePickerControllerCameraCaptureModeVideo ) {
		
		[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
		
	} else {
		
		[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
	}
}


-(IBAction) shutterPressed {
	
	[self stopSounds];
	
	[imagePicker takePicture];
}


#pragma mark Setup Views


-(void) setupOverlayView {
	
	[overlayView setBackgroundColor:[UIColor clearColor]];
	[overlayView setFrame:CGRectMake(0, 0, 320, 460)];
	
	[flashButton setHidden:![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]];
		
	
	MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(38, 60, 244, 15)];
	[volumeView setShowsRouteButton:NO];
	[overlayView addSubview: volumeView];
	[volumeView release];
	
}


-(void) setupImagePicker {
		
	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
	imagePicker.delegate = self;
	[imagePicker setAllowsEditing:NO];
	[imagePicker setShowsCameraControls:NO];
	[imagePicker setCameraOverlayView:overlayView];
	[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
	[imagePicker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:[imagePicker sourceType]]];	
	[imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
}


-(void) loadSounds {
	
	sounds = [[NSMutableArray alloc] init];
	[self loadDogSounds];

}

-(IBAction) loadDogSounds {
	
	[dogButton setImage:[UIImage imageNamed:@"button_woof_down"] forState:UIControlStateNormal];
	[catButton setImage:[UIImage imageNamed:@"button_meow"] forState:UIControlStateNormal];
	[squeakyButton setImage:[UIImage imageNamed:@"button_squeeze"] forState:UIControlStateNormal];
	
	[sounds release];
	
	NSString *bundleResourcePath = [[NSBundle mainBundle] resourcePath];
	NSURL *soundFileURL; 
	sounds = [[NSMutableArray alloc] init];
	
	soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/dog_1.mp3"]];
	[sounds addObject:soundFileURL];
	
	soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/dog_2.mp3"]];
	[sounds addObject:soundFileURL];
	
	soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/dog_3.mp3"]];
	[sounds addObject:soundFileURL];
	
	
		
}

-(IBAction) loadCatSounds {
	
	[dogButton setImage:[UIImage imageNamed:@"button_woof"] forState:UIControlStateNormal];
	[catButton setImage:[UIImage imageNamed:@"button_meow_down"] forState:UIControlStateNormal];
	[squeakyButton setImage:[UIImage imageNamed:@"button_squeeze"] forState:UIControlStateNormal];
	
	[sounds release];
	
	NSString *bundleResourcePath = [[NSBundle mainBundle] resourcePath];
	NSURL *soundFileURL; 
	sounds = [[NSMutableArray alloc] init];
	
	soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/cat_1.mp3"]];
	[sounds addObject:soundFileURL];
	
	soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/cat_2.mp3"]];
	[sounds addObject:soundFileURL];
	
	soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/cat_3.mp3"]];
	[sounds addObject:soundFileURL];
	
}

-(IBAction) loadSqueakySounds {
	
	[dogButton setImage:[UIImage imageNamed:@"button_woof"] forState:UIControlStateNormal];
	[catButton setImage:[UIImage imageNamed:@"button_meow"] forState:UIControlStateNormal];
	[squeakyButton setImage:[UIImage imageNamed:@"button_squeeze_down"] forState:UIControlStateNormal];
	
	[sounds release];
	
	NSString *bundleResourcePath = [[NSBundle mainBundle] resourcePath];
	NSURL *soundFileURL; 
	sounds = [[NSMutableArray alloc] init];
	
    soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/squeaky_1.m4v"]];
    //soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/squeaky_1.mp3"]];
	[sounds addObject:soundFileURL];
	
    soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/squeaky_2.m4v"]];
    //soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/squeaky_2.mp3"]];
	[sounds addObject:soundFileURL];
	
    soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/squeaky_3.m4v"]];
    //soundFileURL = [NSURL fileURLWithPath:[bundleResourcePath stringByAppendingString:@"/squeaky_3.mp3"]];
	[sounds addObject:soundFileURL];
	
}





- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	[self dismissModalViewControllerAnimated:YES];

	UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
	[assetImageView setImage:[picture thumbnailImage:150 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh]];

	currentMediaInfo = info;
	[currentMediaInfo retain];

	
	return;
}

-(void) saveCurrentMedia {
	
	[self performSelectorInBackground:@selector(showWaitMessage:) withObject:@"Saving..."];
		
	UIImage *picture = [currentMediaInfo objectForKey:UIImagePickerControllerOriginalImage];
	NSDictionary *metadata = [currentMediaInfo objectForKey:UIImagePickerControllerMediaMetadata];
	
	[library writeImageToSavedPhotosAlbum:[picture CGImage] metadata:metadata 
									  completionBlock:
										^(NSURL *assetURL, NSError *error){
											if (error != NULL) {
												[self showAlertForError:error];
												return;
											}
										}
	];

	[self hideWaitView];
	[self showCamera];

}


-(void) showAlertForError:(NSError*) error {
	
	[self hideWaitView];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
						  message: [error localizedDescription]
						  delegate: nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	
	[audioPlayer release];	
	[self playSound];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[pictureCaptionTextView resignFirstResponder];
}


-(BOOL)textViewShouldBeginEditing:(UITextView *)textField {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.25];
	
	CGAffineTransform transform;
	
	transform = CGAffineTransformMakeTranslation(0, -150);
	self.view.transform = transform;
	
	[UIView commitAnimations];
	
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.25];
	
	CGAffineTransform transform;
	
	transform = CGAffineTransformMakeTranslation(0, 0);
	self.view.transform = transform;
	
	[UIView commitAnimations];
	
	return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	if ([text hasSuffix:@"\n"]) {
		[self textViewShouldEndEditing:textView];
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
}


-(void) showWaitView {
	[waitIndicatorView setHidden:NO];
}

-(void) hideWaitView {
	[waitIndicatorView setHidden:YES];
}

-(void) showWaitMessage:(NSString *)message {
	[waitingLabel setText:message];
}


#pragma mark Facebook
-(void) setupFacebook {
	
	Pet_PicAppDelegate* appDelegate = (Pet_PicAppDelegate*)[[UIApplication sharedApplication] delegate];
	Facebook *facebook = [appDelegate facebook];
	
	facebook.accessToken    = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
    facebook.expirationDate = (NSDate *) [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
	
    if ([facebook isSessionValid] == NO) {
		[facebookSwitch setOn:NO];
		[connectFacebookButton setHidden:NO];
		[facebookSwitch setHidden:YES];
		[facebookLabel setHidden:YES];
    } else {
		[facebookSwitch setOn:YES];
		[connectFacebookButton setHidden:YES];
		[facebookSwitch setHidden:NO];
		[facebookLabel setHidden:NO];
	}

	[self facebookSwitchPressed];
	
}

-(IBAction) facebookSwitchPressed {

	if([facebookSwitch isOn]) {	
		[saveAndPublishButton setImage:[UIImage imageNamed:@"button_publish"] forState:UIControlStateNormal];
	} else {
		[saveAndPublishButton setImage:[UIImage imageNamed:@"button_save"] forState:UIControlStateNormal];
	}
}


-(IBAction) connectFacebookPressed {

	Pet_PicAppDelegate* appDelegate = (Pet_PicAppDelegate*)[[UIApplication sharedApplication] delegate];
	Facebook *facebook = [appDelegate facebook];
	NSArray *permissions =  [NSArray arrayWithObjects:@"publish_stream", @"offline_access",nil];
	
	[facebook authorize:kFacebookAppId permissions:permissions delegate:self];
}


- (void) fbDidLogin
{
	Pet_PicAppDelegate* appDelegate = (Pet_PicAppDelegate*)[[UIApplication sharedApplication] delegate];
	Facebook *facebook = [appDelegate facebook];

    [[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:facebook.expirationDate forKey:@"ExpirationDate"];
	
	[self setupFacebook];
}


/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	
	if([error code] == 190 || [error code] == 101) {
		//permission error
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Facebook"
														message: @"You must connect with Facebook again"
													   delegate: nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		
		[self disconnectFacebook];
		[self setupFacebook];
	}
	else {
		[self showAlertForError:error];		
	}

	[self hideWaitView];
}


/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {

	[self saveCurrentMedia];
}


-(void) disconnectFacebook {
	
	Pet_PicAppDelegate* appDelegate = (Pet_PicAppDelegate*)[[UIApplication sharedApplication] delegate];
	Facebook *facebook = [appDelegate facebook];
	
	[facebook logout:self];
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"AccessToken"];
	[[NSUserDefaults standardUserDefaults] setObject:[[NSDate date] addTimeInterval: -86400.0] forKey:@"ExpirationDate"];

}


-(void) publishOnFacebook {
	
	[self performSelectorInBackground:@selector(showWaitMessage:) withObject:@"Publishing..."];
	
	Pet_PicAppDelegate* appDelegate = (Pet_PicAppDelegate*)[[UIApplication sharedApplication] delegate];
	Facebook *facebook = [appDelegate facebook];
	
	UIImage *sourceImage = [currentMediaInfo objectForKey:UIImagePickerControllerOriginalImage];
	UIImage *img = [self scaleAndRotateImage:sourceImage];
	
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									img, @"picture",
									[pictureCaptionTextView text], @"caption",
									nil];
	
	@try {
		[facebook requestWithMethodName: @"photos.upload"
							  andParams: params
						  andHttpMethod: @"POST"
							andDelegate: self];
		
	}
	@catch (NSException * e) {
		NSLog(@"Exception is %@", [e reason]);
	}
	
}


#pragma mark UIImage method

-(UIImage*) scaleAndRotateImage:(UIImage*)image {
	
    int kMaxResolution = 700; // Or whatever
	
    CGImageRef imgRef = image.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
			
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
			
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
			
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
			
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
    }
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return imageCopy;
}


#pragma mark Memory management
- (void)dealloc {
    
	[squeakyButton release];
	[dogButton release];
	[catButton release];
	
	[sounds release];
	[overlayView release];
	[flashButton release];
	[shutterButton release];
	[library release];
	[assetImageView release];
	[waitIndicatorView release];
	[connectFacebookButton release];
	[facebookSwitch release];
	[pictureCaptionTextView release];
	[saveAndPublishButton release];
	[waitingLabel release];
	[facebookLabel release];
	
	[fetchedResultsController_ release];
    [managedObjectContext_ release];
	
    [super dealloc];
}


@end

