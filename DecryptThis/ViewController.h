//
//  ViewController.h
//  DecryptThis
//
//  Created by Kenneth Siu on 8/31/15.
//  Copyright (c) 2015 Kenneth Siu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ACEDrawingView.h>
#import <Firebase/Firebase.h>

@interface ViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate>

//drawing view
@property ACEDrawingView *drawingView;

//firebase
@property Firebase *firebase;

//input field
@property UITextView *inputKey;

//clear button
@property UIButton *clearButton;

//button properties
@property UIColor *sendButtonNotPressedColor;
@property UIColor *sendButtonPressedColor;

//array of buttons in the ui toolbar
@property NSMutableArray *toolbarArray;

//toolbar
@property UIToolbar* toolbar;

//slider for width
@property UISlider* widthSlider;

//get the full line width allowed
@property CGFloat fullLineWidth;

//color alert view
@property UIActionSheet *colorSelectView;

//color array
@property NSDictionary *colorArray;

@end

