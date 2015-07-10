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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.hand)?self.hand.whiteCards.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    WhiteCard *whiteCard = (WhiteCard *)self.hand.whiteCards[indexPath.row];
    
    if ([self.whiteCardsToSubmit containsObject:whiteCard]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = whiteCard.text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WhiteCard *whiteCard = (WhiteCard *)self.hand.whiteCards[indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
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
            [self dismissViewControllerAnimated:YES completion:^{
                self.submittedWhiteCards = submittedWhiteCards;
                [self performSegueWithIdentifier:@"presentSubmittedWhiteCards" sender:self];
            }];
        });
    }
}

- (IBAction)submitButtonPressed:(UIBarButtonItem *)sender {
    if ([self.whiteCardsToSubmit firstObject]) {
        [[GameManager sharedManager] submitWhiteCardsResponse:self.whiteCardsToSubmit];
    }
}
@end
