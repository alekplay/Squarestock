//
//  StockDetailViewController.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "StockDetailViewController.h"
#import "StockManager.h"
#import "Constants.h"
#import "Stock.h"
#import "Price.h"
#import "Company.h"
#import "LineGraphView.h"

typedef NS_ENUM(NSInteger, StockDetailViewControllerStatus) {
    StockDetailViewControllerStatusLoading = 1,
    StockDetailViewControllerStatusMarketOpen,
    StockDetailViewControllerStatusMarketClosed,
    StockDetailViewControllerStatusMarketDelayed,
    StockDetailViewControllerStatusError
};

@interface StockDetailViewController ()

#pragma mark Outlets
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *marketLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockTickerLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPriceTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPriceChangeLabel;
@property (weak, nonatomic) IBOutlet LineGraphView *lineChartView;

#pragma mark Properties

@property (nonatomic, strong) Stock *stock;
@property (nonatomic) StockDetailViewControllerStatus currentStatus;

@end

#pragma mark -

@implementation StockDetailViewController

/*  TO DO:
    1. Errors
 */

#pragma mark View Layout

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a gesture recognizer to the ticker label
    UITapGestureRecognizer *titleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonDidPress:)];
    [self.stockTickerLabel addGestureRecognizer:titleTapGestureRecognizer];
    
    // Get the stored company
    NSData *archivedCompany = [[NSUserDefaults standardUserDefaults] objectForKey:kSQArchivedSelectedCompanyKey];
    Company *company = [NSKeyedUnarchiver unarchiveObjectWithData:archivedCompany];
    self.stock = [[Stock alloc] initWithCompany:company currentPrice:nil andOpenPrice:nil];
    
    [self getCurrentData];
}

#pragma mark Data

- (void)getCurrentData {
    // Set the current status
    self.currentStatus = StockDetailViewControllerStatusLoading;
    [self updateStatusLabel];
    
    // Update company info labels
    [self updateCompanyInfoLabels];
    
    // Reset stock info labels and graph
    [self updateStockInfoLabels];
    [self.lineChartView reloadGraph];
    
    // Set the activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Get information about current stock
    [[StockManager sharedManager] getCurrentDataForCompany:self.stock.company withCompletionHandler:^(Stock *stock, NSError *error) {
        if (!error) {
            // Update the current stock
            self.stock = stock;
            
            // Determine current status
            [self determineCurrentStatus];
            [self updateStatusLabel];
            
            // Update stock info labels
            [self updateStockInfoLabels];
            
            // Update chart
            [self.lineChartView reloadGraph];
            
        } else {
            [self displayError:error];
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

#pragma mark Labels

- (void)updateStatusLabel {
    NSAttributedString *statusString;
    
    switch (self.currentStatus) {
        case StockDetailViewControllerStatusLoading:
            statusString = [[NSAttributedString alloc] initWithString:@"loading..." attributes:nil];
            break;
        case StockDetailViewControllerStatusMarketClosed:
            statusString = [[NSAttributedString alloc] initWithString:@"market is closed" attributes:@{NSForegroundColorAttributeName: kSQRedColor}];
            break;
        case StockDetailViewControllerStatusMarketOpen:
        case StockDetailViewControllerStatusMarketDelayed:
        case StockDetailViewControllerStatusError:
        default:
            statusString = [[NSAttributedString alloc] initWithString:@""];
            break;
    }
    
    self.statusLabel.attributedText = statusString;
}

- (void)updateCompanyInfoLabels {
    self.marketLabel.text = [self.stock.company.market uppercaseString];
    self.stockTickerLabel.text = self.stock.company.symbol;
    self.stockNameLabel.text = self.stock.company.name;
}

- (void)updateStockInfoLabels {
    NSDate *lastTradeTime = self.stock.currentPrice.tradeTime;
    
    // Get the time since the last trade was executed (<1h : "now", <24h : "hh/HH:mm(a)", >24h : short date + time format)
    NSString *timeString = @"now";
    if ([lastTradeTime timeIntervalSinceNow] < -60 * 60) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.timeStyle = NSDateFormatterShortStyle;
        if ([lastTradeTime timeIntervalSinceNow] < -60 * 60 * 24) {
            formatter.dateStyle = NSDateFormatterShortStyle;
        }
        timeString = [formatter stringFromDate:lastTradeTime];
    }
    
    // Figure out whether the price has gone up or down, and change the text color
    NSDictionary *priceChangeStringColorAttribute;
    if (self.stock.dailyChange < 0) {
        priceChangeStringColorAttribute = @{NSForegroundColorAttributeName: kSQRedColor};
    } else {
        priceChangeStringColorAttribute = @{NSForegroundColorAttributeName: kSQGreenColor};
    }
    NSAttributedString *priceChangeString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f (%.2f%%)", self.stock.dailyChange, self.stock.dailyChangePercent] attributes:priceChangeStringColorAttribute];
    
    self.stockPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.stock.currentPrice.value];
    self.stockPriceChangeLabel.attributedText = priceChangeString;
    self.stockPriceTimeLabel.text = timeString;
}

#pragma mark Status

- (void)determineCurrentStatus {
    NSDate *lastTradeTime = self.stock.currentPrice.tradeTime;
    
    // Get the current status of the market based on when the last trade was executed
    if ([lastTradeTime timeIntervalSinceNow] > -60 * 60) {
        self.currentStatus = StockDetailViewControllerStatusMarketOpen;
    } else {
        self.currentStatus = StockDetailViewControllerStatusMarketClosed;
    }
}

#pragma mark Line Graph View Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.stock.historicalPrices.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    Price *price = self.stock.historicalPrices[index];
    return (NSInteger)price.value;
}

#pragma mark Search View Controller Delegate

- (void)searchViewController:(SearchViewController *)searchViewController didFinishSearchingForCompany:(Company *)company {
    // Get the selected stock and update the data
    self.stock = [[Stock alloc] initWithCompany:company currentPrice:nil andOpenPrice:nil];
    [self getCurrentData];
    
    // Dismiss the search view controller
    [self dismissViewControllerAnimated:true completion:nil];
    
    // Save the selected company in the user defaults
    NSData *archivedCompany = [NSKeyedArchiver archivedDataWithRootObject:company];
    [[NSUserDefaults standardUserDefaults] setObject:archivedCompany forKey:kSQArchivedSelectedCompanyKey];
}

- (void)searchViewControllerDidCancel:(SearchViewController *)searchViewController {
    [self.lineChartView reloadGraph];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"StockDetailToSearchSegue"]) {
        SearchViewController *controller = (SearchViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.currentCompany = self.stock.company;
    }
}

#pragma mark Actions

- (IBAction)searchButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"StockDetailToSearchSegue" sender:self];
}

#pragma mark Errors

- (void)displayError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *againAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self getCurrentData];
    }];
    [alert addAction:againAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.currentStatus = StockDetailViewControllerStatusError;
        [self updateStatusLabel];
    }];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

@end