//
//  TickerTableViewCell.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TickerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tickerSymbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *tickerNameLabel;

@end