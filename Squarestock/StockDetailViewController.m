//
//  StockDetailViewController.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "StockDetailViewController.h"
#import "StockManager.h"
#import "TickerManager.h"
#import "ColorConstants.h"

@interface StockDetailViewController ()

#pragma mark Outlets
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *marketLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockTickerLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPriceTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPriceChangeLabel;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *lineChartView;

#pragma mark Properties

@property (nonatomic, strong) Stock *stock;

@end

#pragma mark -

@implementation StockDetailViewController

/*  TO DO:
    1. ANIMATIONS
    2. Make sure currency matches market country
    3. CLEAN UP CODE
        * Make dateformatters shared object
        * Divide out responsibility from view controller
 */

#pragma mark View Layout

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Remove placeholder content in labels
    [self emptyLabels];
    
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = {1.0, 0.0};
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    self.lineChartView.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Add a tgr to the stock ticker label
    UITapGestureRecognizer *titleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tickerSymbolLabelDidTap:)];
    [self.stockTickerLabel addGestureRecognizer:titleTapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Get the stored ticker
    NSData *archivedTicker = [[NSUserDefaults standardUserDefaults] objectForKey:@"ArchivedSelectedTicker"];
    Ticker *ticker = [NSKeyedUnarchiver unarchiveObjectWithData:archivedTicker];
    
    if (self.stock.ticker != ticker) {
        [self emptyLabels];
        [self.lineChartView reloadGraph];
    }
    
    // Get the current data for stored ticker
    [[StockManager sharedManager] getCurrentDataForTicker:ticker withCompletionHandler:^(Stock *stock, NSError *error) {
        if (!error) {
            self.stock = stock;
            [self updateLabels];
            [self.lineChartView reloadGraph];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)updateLabels {
    // Get the current status of the market based on when the last trade was executed, and change the text color
    NSAttributedString *statusString;
    if ([self.stock.tradeTime timeIntervalSinceNow] > -60 * 60) {
        statusString = [[NSAttributedString alloc] initWithString:@"market is open" attributes:@{NSForegroundColorAttributeName: kSQGreenColor}];
    } else {
        statusString = [[NSAttributedString alloc] initWithString:@"market is closed" attributes:@{NSForegroundColorAttributeName: kSQRedColor}];
    }
    self.statusLabel.attributedText = statusString;
    
    // Get the time since the last trade was executed (<1h : "now", <24h : "hh/HH:mm(a)", >24h : short date + time format)
    NSString *timeString = @"now";
    if ([self.stock.tradeTime timeIntervalSinceNow] < -60 * 60) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.timeStyle = NSDateFormatterShortStyle;
        if ([self.stock.tradeTime timeIntervalSinceNow] < -60 * 60 * 24) {
            formatter.dateStyle = NSDateFormatterShortStyle;
        }
        timeString = [formatter stringFromDate:self.stock.tradeTime];
    }
    
    // Figure out whether the price has gone up or down, and change the text color
    NSDictionary *priceChangeStringColorAttribute;
    if (self.stock.change < 0) {
        priceChangeStringColorAttribute = @{NSForegroundColorAttributeName: kSQRedColor};
    } else {
        priceChangeStringColorAttribute = @{NSForegroundColorAttributeName: kSQGreenColor};
    }
    NSAttributedString *priceChangeString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f (%.2f%%)", self.stock.change, self.stock.pctChange] attributes:priceChangeStringColorAttribute];
    
    // Set the market name, ticker symbol, company name, price last updated, and current price
    self.marketLabel.text = [self.stock.ticker.market uppercaseString];
    self.stockTickerLabel.text = self.stock.ticker.symbol;
    self.stockNameLabel.text = self.stock.ticker.name;
    self.stockPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.stock.currentPrice];
    self.stockPriceChangeLabel.attributedText = priceChangeString;
    self.stockPriceTimeLabel.text = timeString;
    self.statusLabel.attributedText = statusString;
}

- (void)emptyLabels {
    self.marketLabel.text = @"";
    self.stockTickerLabel.text = @"";
    self.stockNameLabel.text = @"";
    self.stockPriceLabel.text = @"";
    self.stockPriceChangeLabel.text = @"";
    self.stockPriceTimeLabel.text = @"";
    self.statusLabel.text = @"";
}

#pragma mark Line Graph View Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.stock.historicalPrices.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    NSNumber *price = self.stock.historicalPrices[index];
    return [price intValue];
}

#pragma mark User Actions

- (void)tickerSymbolLabelDidTap:(id)sender {
    [self performSegueWithIdentifier:@"StockDetailToSearchSegue" sender:self];
}

@end
