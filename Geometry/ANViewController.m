//
//  ANViewController.m
//  Geometry
//
//  Created by Alex Nichol on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANViewController.h"

@interface ANViewController ()

- (void)setupTitleBar;

- (UIImage *)scaleAndRotate:(UIImage *)image;

@end

@implementation ANViewController

- (void)setupTitleBar {
    navItem = [[UINavigationItem alloc] initWithTitle:@"Geometry!"];
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
                                                               target:self
                                                               action:@selector(undo:)];
    pickButton = [[UIBarButtonItem alloc] initWithTitle:@"Picture"
                                                  style:UIBarButtonItemStyleBordered
                                                 target:self
                                                 action:@selector(pickImage:)];
    
    [navItem setLeftBarButtonItem:undoButton];
    [navItem setRightBarButtonItem:pickButton];
    
    [navBar setItems:[NSArray arrayWithObject:navItem]];
    [self.view addSubview:navBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTitleBar];
    
    overlayImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height - 44)];
    [overlayImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:overlayImage];
    
	shapeView = [[ANShapeView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height - 44)];
    [shapeView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:shapeView];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions -

- (void)undo:(id)sender {
    [shapeView undoDraw:sender];
}

- (void)pickImage:(id)sender {
    NSString * camOption = @"Camera";
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        camOption = nil;
    }
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set a background image"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:@"Clear"
                                                     otherButtonTitles:@"Circle", @"Photo Library", camOption, nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Clear"]) {
        [overlayImage setImage:nil];
    } else if ([title isEqualToString:@"Camera"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:imagePicker animated:YES];
    } else if ([title isEqualToString:@"Photo Library"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:imagePicker animated:YES];
    } else if ([title isEqualToString:@"Circle"]) {
        [overlayImage setImage:[UIImage imageNamed:@"circle.png"]];
    }
}

#pragma mark - Image Picker -

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)theImage
				  editingInfo:(NSDictionary *)editingInfo  {
	UIImage * image = [self scaleAndRotate:theImage];
    [picker dismissModalViewControllerAnimated:YES];
    [overlayImage setImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// ignore
	[picker dismissModalViewControllerAnimated:YES];
}

- (UIImage *)scaleAndRotate:(UIImage *)image {
	int kMaxResolution = 640; // Or whatever
	
    CGImageRef imgRef = image.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
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

@end
