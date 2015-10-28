//
//  StockDetailViewController.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface StockDetailViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@end
