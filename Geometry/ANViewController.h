//
//  ANViewController.h
//  Geometry
//
//  Created by Alex Nichol on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANShapeView.h"

@interface ANViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    ANShapeView * shapeView;
    UIImageView * overlayImage;
    UINavigationBar * navBar;
    UINavigationItem * navItem;
    UIBarButtonItem * undoButton;
    UIBarButtonItem * pickButton;
    UIImagePickerController * imagePicker;
}

- (void)undo:(id)sender;
- (void)pickImage:(id)sender;

@end
