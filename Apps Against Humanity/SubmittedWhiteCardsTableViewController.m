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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (nullable UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BlackCardTableViewCell *headerCell = (BlackCardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"headerCell"];
    headerCell.multilineLabel.text = self.blackCardInPlay.text;
    return headerCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.submissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WhiteCardTableViewCell *cell = (WhiteCardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Submission *submission = (Submission *)self.submissions[indexPath.row];
    WhiteCard *whiteCard = (WhiteCard *)[submission.whiteCards firstObject];
    
    cell.multilineLabel.text = whiteCard.text;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Submission *submission = self.submissions[indexPath.row];
    WhiteCard *whiteCard = (WhiteCard *)[submission.whiteCards firstObject];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure this is your winning answer?"
                                                                             message:whiteCard.text
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
