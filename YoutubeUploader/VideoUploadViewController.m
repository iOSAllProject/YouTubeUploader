//
//  Copyright (C) 2015 tbago.
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//
//
//  VideoUploadViewController.m
//  YoutubeUploader
//
//  Created by tbago on 8/20/15.
//

#import "VideoUploadViewController.h"
#import "Utils.h"

@interface VideoUploadViewController () <YouTubeUploadVideoDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView         *playerBackView;
@property (weak, nonatomic) IBOutlet UITextField    *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField    *descriptionTextField;

@property(nonatomic, retain) MPMoviePlayerController    *player;
@property(nonatomic, retain) UITextField                *activeField;
@property(nonatomic, strong) YouTubeUploadVideo         *uploadVideo;
@end

@implementation VideoUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _uploadVideo = [[YouTubeUploadVideo alloc] init];
    _uploadVideo.delegate = self;
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Do any additional setup after loading the view.
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:_videoUrl];
    self.player.view.frame = self.playerBackView.frame;
    [self.playerBackView addSubview:self.player.view];
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.player.view.frame = self.playerBackView.frame;
}

#pragma mark - action
- (IBAction)uploadYTDL:(UIBarButtonItem *)sender {
    NSData *fileData = [NSData dataWithContentsOfURL:_videoUrl];
    NSString *title = self.titleTextField.text;
    NSString *description = self.descriptionTextField.text;
    
    if ([title isEqualToString:@""]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"'Direct Lite Uploaded File ('EEEE MMMM d, YYYY h:mm a, zzz')"];
        title = [dateFormat stringFromDate:[NSDate date]];
    }
    if ([description isEqualToString:@""]) {
        description = @"Uploaded from YouTube Direct Lite iOS";
    }
    
    [self.uploadVideo uploadYouTubeVideoWithService:_youtubeService
                                           fileData:fileData
                                              title:title
                                        description:description];
}


#pragma mark - uploadYouTubeVideo

- (void)uploadYouTubeVideo:(YouTubeUploadVideo *)uploadVideo
      didFinishWithResults:(GTLYouTubeVideo *)video {
    [Utils showAlert:@"Video Uploaded" message:video.identifier];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    //    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    //    _scrollView.contentInset = contentInsets;
    //    _scrollView.scrollIndicatorInsets = contentInsets;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    contentInsets.top = 64.0f;
    contentInsets.bottom = 44.0f;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = self.activeField.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [self.activeField.superview setFrame:bkgndRect];
    [self.scrollView setContentOffset:CGPointMake(0.0, self.activeField.frame.origin.y - kbSize.height)
                             animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
