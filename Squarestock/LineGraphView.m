//
//  LineGraphView.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/28/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "LineGraphView.h"

@implementation LineGraphView

- (void)drawRect:(CGRect)rect {
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = {1.0, 0.0};
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    self.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
}

@end
