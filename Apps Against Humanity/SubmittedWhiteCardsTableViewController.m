//
//  SubmittedWhiteCardsTableViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 10/07/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "SubmittedWhiteCardsTableViewController.h"
#import "GameManager.h"

#import "Submission.h"
#import "Player.h"
#import "WhiteCard.h"

@interface SubmittedWhiteCardsTableViewController ()

@end

@implementation SubmittedWhiteCardsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.submissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Submission *submission = (Submission *)self.submissions[indexPath.row];
    WhiteCard *whiteCard = (WhiteCard *)[submission.whiteCards firstObject];
    
    cell.textLabel.text = whiteCard.text;
    
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
