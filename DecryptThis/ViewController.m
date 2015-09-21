//
//  ViewController.m
//  DecryptThis
//
//  Created by Kenneth Siu on 8/31/15.
//  Copyright (c) 2015 Kenneth Siu. All rights reserved.
//

#import "ViewController.h"
#import "SecretKeys.h"

#define TOOLBAR_HEIGHT 50
#define CHAR_LIMIT 40
#define IMAGE @"image"
#define KEY @"key"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set the view
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //get the drawing context
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    float heightOfScreen = self.view.bounds.size.height;
    float widthOfScreen = self.view.bounds.size.width;
    
    float heightOfToolbar = TOOLBAR_HEIGHT;
    float heightOfInputField = heightOfScreen / 20.f;
    float heightOfStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height;
    float heightOfSlider = self.view.frame.size.height / 15.f;
    
    // set views
    self.inputKey = [[UITextView alloc] initWithFrame:CGRectMake(0, heightOfStatusBar, widthOfScreen, heightOfInputField)];
    
    self.drawingView = [[ACEDrawingView alloc] initWithFrame:CGRectMake(0, heightOfInputField + heightOfStatusBar, widthOfScreen, heightOfScreen - heightOfToolbar - heightOfInputField - heightOfStatusBar - heightOfSlider)];
    
    // text view settings
    [self.inputKey setFont:[UIFont systemFontOfSize:heightOfInputField - (heightOfInputField / 2.f)]];
    [self.inputKey setReturnKeyType:UIReturnKeyDone];
    self.inputKey.delegate = self;
    [self.inputKey setTextAlignment:NSTextAlignmentCenter];
    self.inputKey.layer.borderWidth = 2.f;
    self.inputKey.layer.borderColor = [[UIColor blackColor] CGColor];
    self.inputKey.showsHorizontalScrollIndicator = YES;
    
    //dismiss keyboard gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //set up firebase
    self.firebase = [[Firebase alloc] initWithUrl:[SecretKeys getURL]];
    
    //set up width slider
    self.widthSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 4.f, self.view.frame.size.height -  heightOfSlider - heightOfToolbar, self.view.frame.size.width / (2.f), heightOfSlider)];
    [self.widthSlider addTarget:self action:@selector(widthChanged:) forControlEvents:UIControlEventValueChanged];
    [self.widthSlider setValue:0.5f];
    [self.view addSubview:self.widthSlider];
    self.fullLineWidth = [self.drawingView lineWidth] / 0.5f;
    
    //set up toolbar
    self.toolbarArray = [[NSMutableArray alloc] init];
    UIBarButtonItem *colorItem = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Color" style:UIBarButtonItemStylePlain
                                  target:self action:@selector(colorSelected:)];
    
    self.colorArray = @{@"Black" : [UIColor blackColor],
                        @"Red" : [UIColor redColor],
                        @"Orange" : [UIColor orangeColor],
                        @"Yellow" : [UIColor yellowColor],
                        @"Green" : [UIColor greenColor],
                        @"Blue" : [UIColor blueColor],
                        @"Purple" : [UIColor purpleColor],
                        @"Brown" : [UIColor brownColor],
                        @"Gray" : [UIColor grayColor],
                        @"Pink" : [UIColor colorWithRed:1.f green:0.753f blue:0.796f alpha:1.f]
                        };
    
    self.colorSelectView = [[UIActionSheet alloc] initWithTitle:@"Color Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: nil];
    
    for(NSString *color in [self.colorArray allKeys]) {
        [self.colorSelectView addButtonWithTitle:color];
    }

    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Clear" style:UIBarButtonItemStylePlain
                                  target:self action:@selector(clearSelected:)];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Undo" style:UIBarButtonItemStylePlain
                                 target:self action:@selector(undoSelected:)];
    UIBarButtonItem *redoItem = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Redo" style:UIBarButtonItemStylePlain
                                 target:self action:@selector(redoSelected:)];
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Send!" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPressed:)];
    
    //for flexible space
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil action:nil];
    
    [self.toolbarArray addObject:flexSpace];
    [self.toolbarArray addObject:colorItem];
    [self.toolbarArray addObject:flexSpace];
    
    [self.toolbarArray addObject:flexSpace];
    [self.toolbarArray addObject:clearItem];
    [self.toolbarArray addObject:flexSpace];
    [self.toolbarArray addObject:undoItem];
    [self.toolbarArray addObject:flexSpace];
    [self.toolbarArray addObject:redoItem];
    [self.toolbarArray addObject:flexSpace];
    
    [self.toolbarArray addObject:flexSpace];
    [self.toolbarArray addObject:sendItem];
    [self.toolbarArray addObject:flexSpace];
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, heightOfScreen - heightOfToolbar, widthOfScreen, heightOfToolbar)];
    [self.toolbar setItems:self.toolbarArray];
    
    // add all views to device
    [self.view addSubview:self.drawingView];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.inputKey];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

-(void)dismissKeyboard{
    [self.inputKey resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    //check for new line
    if ([text isEqualToString:@"\n"]) {
        [self.inputKey resignFirstResponder];
        return NO;
    }
    
    //check for character limit
    if(([[textView text] length] - range.length + text.length > CHAR_LIMIT))
    {
        return NO;
    }
    
    return YES;
}

-(IBAction)widthChanged:(id)sender {
    [self.drawingView setLineWidth:([self.widthSlider value] * self.fullLineWidth) + 1.f];
}

// toolbar selectors
-(IBAction)sendButtonPressed:(id)sender {
    
    if([self.inputKey.text length] == 0)
    {
        return;
    }
    
    NSData* imageData = UIImagePNGRepresentation(self.drawingView.image);
    NSString *base64Encoding = [imageData base64EncodedStringWithOptions:0];
    
    //send information
    NSDictionary *map = @{ IMAGE : base64Encoding, KEY : self.inputKey.text};
    [self.firebase setValue:map withCompletionBlock:^(NSError *error, Firebase *ref) {
        
    }];
    
}

-(IBAction)colorSelected:(id)sender {
    [self.colorSelectView showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *key = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([actionSheet isEqual:self.colorSelectView]) {
        [self.drawingView setLineColor:[self.colorArray objectForKey:key]];
    }
}

-(IBAction)sendButtonReleased:(UIButton*) button {
    [button setBackgroundColor:self.sendButtonNotPressedColor];
}

-(IBAction)clearSelected:(id)sender {
    [self.drawingView clear];
}

-(IBAction)undoSelected:(id)sender {
    [self.drawingView undoLatestStep];
}

-(IBAction)redoSelected:(id)sender {
    [self.drawingView redoLatestStep];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
