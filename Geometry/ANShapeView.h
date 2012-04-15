//
//  ANShapeView.h
//  Geometry
//
//  Created by Alex Nichol on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANLineGroup.h"

@interface ANShapeView : UIView {
    ANLineGroup * lineGroup;
}

- (void)undoDraw:(id)sender;

@end
