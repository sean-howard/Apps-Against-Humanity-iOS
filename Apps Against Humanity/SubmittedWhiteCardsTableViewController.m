//
//  SubmittedWhiteCardsTableViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 10/07/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "SubmittedWhiteCardsTableViewController.h"
#import "GameManager.h"

#import "WhiteCardTableViewCell.h"
#import "BlackCardTableViewCell.h"

#import "Submission.h"
#import "Player.h"
#import "WhiteCard.h"
#import "BlackCard.h"

@interface SubmittedWhiteCardsTableViewController ()

@end

@implementation SubmittedWhiteCardsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *whiteCellNib = [UINib nibWithNibName:@"WhiteCardTableViewCell" bundle:nil];
    [self.tableView registerNib:whiteCellNib forCellReuseIdentifier:@"cell"];
    
    UINib *blackCellNib = [UINib nibWithNibName:@"BlackCardTableViewCell" bundle:nil];
    [self.tableView registerNib:blackCellNib forCellReuseIdentifier:@"headerCell"];
        
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.estimatedSectionHeaderHeight = 44.0f;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return UITableViewAutomaticDimension;
    }
    return 0.f;
}

- (nullable UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        BlackCardTableViewCell *headerCell = (BlackCardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"headerCell"];
        headerCell.multilineLabel.text = self.blackCardInPlay.text;
        return headerCell;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.submissions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    Submission *submission = (Submission *)self.submissions[section];
    
    if (submission) {
        return submission.whiteCards.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WhiteCardTableViewCell *cell = (WhiteCardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Submission *submission = (Submission *)self.submissions[indexPath.section];
    
    if (submission) {
        WhiteCard *whiteCard = (WhiteCard *)submission.whiteCards[indexPath.row];
        cell.multilineLabel.text = whiteCard.text;
    }
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Submission *submission = self.submissions[indexPath.section];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure this is your winning answer?"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"This is my winner!"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * __nonnull action) {
 
                                                          [[GameManager sharedManager] submitWinningSubmission:submission];

                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          });
                                                      
                                                      }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Nah!"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:yesAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
