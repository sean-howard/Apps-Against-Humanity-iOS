//
//  GameViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 28/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "GameViewController.h"
#import "GameManager.h"
#import "BlackCard.h"
#import "WhiteCard.h"
#import "BlackCardModalViewController.h"
#import "SubmittedWhiteCardsTableViewController.h"
#import "Hand.h"
#import "Submission.h"
#import "Player.h"
#import "WhiteCardTableViewCell.h"
#import "BlackCardTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface GameViewController ()<GameManagerDelegate>
@property (nonatomic, strong) BlackCard *blackCardInPlay;
@property (nonatomic, strong) Hand *hand;
@property (nonatomic, strong) NSMutableArray *whiteCardsToSubmit;
@property (nonatomic, strong) NSArray *submittedWhiteCards;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[GameManager sharedManager] setDelegate:self];
    
    if ([[GameManager sharedManager] isGameHost]) {
        [[GameManager sharedManager] selectFirstBlackCardPlayer];
    }
    
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

- (NSMutableArray *)whiteCardsToSubmit
{
    if (!_whiteCardsToSubmit) {
        _whiteCardsToSubmit = [NSMutableArray new];
    }
    return _whiteCardsToSubmit;
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
    return (self.hand)?self.hand.whiteCards.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WhiteCardTableViewCell *cell = (WhiteCardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    WhiteCard *whiteCard = (WhiteCard *)self.hand.whiteCards[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;

    if ([self.whiteCardsToSubmit containsObject:whiteCard]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.multilineLabel.text = whiteCard.text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WhiteCard *whiteCard = (WhiteCard *)self.hand.whiteCards[indexPath.row];
    
    WhiteCardTableViewCell *cell = (WhiteCardTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([self.whiteCardsToSubmit containsObject:whiteCard]) {
            [self.whiteCardsToSubmit removeObject:whiteCard];
        }
        
    } else {
        
        if (![self.whiteCardsToSubmit containsObject:whiteCard]) {
            [self.whiteCardsToSubmit addObject:whiteCard];
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    self.submitButton.enabled = ([self.whiteCardsToSubmit firstObject]);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentBlackCard"]) {
        BlackCardModalViewController *blackCardModalVC = (BlackCardModalViewController *)segue.destinationViewController;
        blackCardModalVC.blackCard = self.blackCardInPlay;
    } else if ([segue.identifier isEqualToString:@"presentSubmittedWhiteCards"]){
        
        UINavigationController *navcon = (UINavigationController *)segue.destinationViewController;
        
        SubmittedWhiteCardsTableViewController *submittedWhiteCardVC = (SubmittedWhiteCardsTableViewController *)navcon.topViewController;
        submittedWhiteCardVC.submissions = self.submittedWhiteCards;
        submittedWhiteCardVC.blackCardInPlay = self.blackCardInPlay;
    }
}

#pragma mark - Game Manager Delegate Methods
- (void)gameManagerDidReceiveBlackCard:(BlackCard *)blackCard asBlackCardPlayer:(BOOL)blackCardPlayer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", blackCard.text);
    self.blackCardInPlay = blackCard;
    
    if (blackCardPlayer) {
        [[GameManager sharedManager] setBlackCardPlayer:blackCardPlayer];
        [[GameManager sharedManager] distributeInitialWhiteCards];

        [self performSegueWithIdentifier:@"presentBlackCard" sender:self];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Black Card"
                                    message:blackCard.text
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }
}

- (void)gameManagerDidReceiveInitialHand:(Hand *)hand
{
    self.hand = hand;
    [self.whiteCardsToSubmit removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)gameManagerDidReceiveAllSubmittedWhiteCards:(NSArray *)submittedWhiteCards
{
    if ([[GameManager sharedManager] isCurrentlyBlackCardPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:^{
                self.submittedWhiteCards = submittedWhiteCards;
                [self performSegueWithIdentifier:@"presentSubmittedWhiteCards" sender:self];
            }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Waiting for winning cards to be chosen, bitch." maskType:SVProgressHUDMaskTypeGradient];
        });
    }
}

- (void)gameManagerDidReceiveWinningSubmission:(Submission *)submission isWinner:(BOOL)winner
{
    NSString *copy;
    if (winner) {
        copy = [NSString stringWithFormat:@"CONGRATULATIONS, YOU ARE WINNER!"];
    } else {
        copy = [NSString stringWithFormat:@"%@ IS WINNER!", [submission.player.name uppercaseString]];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
//        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:copy maskType:SVProgressHUDMaskTypeGradient];
    });
}

- (IBAction)submitButtonPressed:(UIBarButtonItem *)sender {
    
    for (WhiteCard *whiteCard in self.whiteCardsToSubmit) {
        if ([self.hand.whiteCards containsObject:whiteCard]) {
            [self.hand.whiteCards removeObject:whiteCard];
        }
    }
    
    if ([self.whiteCardsToSubmit firstObject]) {
        [[GameManager sharedManager] submitWhiteCardsResponse:self.whiteCardsToSubmit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.whiteCardsToSubmit removeAllObjects];
            [self.tableView reloadData];
            [SVProgressHUD showWithStatus:@"Waiting for players to submit cards" maskType:SVProgressHUDMaskTypeGradient];
        });
    }
}
@end
