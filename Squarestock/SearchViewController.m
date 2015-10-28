//
//  SearchViewController.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "SearchViewController.h"
#import "TickerTableViewCell.h"
#import "TickerManager.h"
#import "ColorConstants.h"

@interface SearchViewController ()

#pragma mark Outlets

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *textField;

#pragma mark Properties

@property (nonatomic, strong) NSArray *tickers;

@end

#pragma mark -

@implementation SearchViewController

/*  TO DO:
    1. Open/ Close/ Selection ANIMATIONS
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make the status bar white
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Move the contents of the TableView up as the keyboard moves up
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        CGRect keyboardEndRect = [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        double duration = [[note.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, keyboardEndRect.size.height, 0)];
        } completion:nil];
    }];
    
    // Set up the array to hold the result tickers
    self.tickers = [NSMutableArray array];
    
    // Find the current ticker the user selected and add it as a placeholder with a readable color
    Ticker *currentTicker = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"ArchivedSelectedTicker"]];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:currentTicker.symbol attributes:@{NSForegroundColorAttributeName:kSQGrayColor}];
    
    // Open up the keyboard
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Remove the keyboard *before* the view is offscreen
    [self.textField resignFirstResponder];
}

#pragma mark TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tickers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TickerTableViewCell *cell = (TickerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TickerCell" forIndexPath:indexPath];
    
    Ticker *ticker = self.tickers[indexPath.row];
    
    cell.tickerSymbolLabel.text = ticker.symbol;
    cell.tickerNameLabel.text = ticker.name;
    
    return cell;
}

#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Find and save the ticker the user pressed
    Ticker *ticker = self.tickers[indexPath.row];
    NSData *archivedTicker = [NSKeyedArchiver archivedDataWithRootObject:ticker];
    [[NSUserDefaults standardUserDefaults] setObject:archivedTicker forKey:@"ArchivedSelectedTicker"];
    
    // Dismiss the search view controller
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    NSString *tickerSymbol = textField.text;
    if (tickerSymbol.length > 0) {
        [[TickerManager sharedManager] lookupTicker:tickerSymbol withCompletionHandler:^(NSArray *tickers, NSError *error) {
            self.tickers = [tickers copy];
            [self.tableView reloadData];
        }];
    } else {
        self.tickers = [NSArray array];
        [self.tableView reloadData];
    }
}

#pragma mark Interaction

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // The user tapped *outside* of the table or textfield, so dismiss the search view controller
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark Other

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
