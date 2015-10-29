//
//  SearchViewController.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "SearchViewController.h"
#import "TickerTableViewCell.h"
#import "StockManager.h"
#import "Constants.h"
#import "Company.h"

@interface SearchViewController ()

#pragma mark Outlets

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *textField;

#pragma mark Properties

@property (nonatomic, strong) NSArray *companies;

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
    self.companies = [NSMutableArray array];
    
    // Set the placeholder of the textfield
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.currentCompany.symbol attributes:@{NSForegroundColorAttributeName:kSQGrayColor}];
    
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
    return [self.companies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TickerTableViewCell *cell = (TickerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TickerCell" forIndexPath:indexPath];
    
    Company *company = self.companies[indexPath.row];
    
    cell.tickerSymbolLabel.text = company.symbol;
    cell.tickerNameLabel.text = company.name;
    
    return cell;
}

#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Find the company the user pressed
    Company *company = self.companies[indexPath.row];
    
    // Return company to the delegate
    [self.delegate searchViewController:self didFinishSearchingForCompany:company];
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    NSString *searchText = textField.text;
    if (searchText.length > 0) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        [[StockManager sharedManager] lookupCompaniesForString:searchText withCompletionHandler:^(NSArray *companies, NSError *error) {
            self.companies = [companies copy];
            [self.tableView reloadData];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    } else {
        self.companies = [NSArray array];
        [self.tableView reloadData];
    }
}

#pragma mark Interaction

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // The user tapped *outside* of the table or textfield, so inform the delegate the user cancelled
    [self.delegate searchViewControllerDidCancel:self];
}

#pragma mark Other

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end