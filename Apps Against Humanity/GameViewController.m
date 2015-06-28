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
#import "Hand.h"

@interface GameViewController ()<GameManagerDelegate>
@property (nonatomic, strong) BlackCard *blackCardInPlay;
@property (nonatomic, strong) Hand *hand;
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
    
    cell.textLabel.text = whiteCard.text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentBlackCard"]) {
        BlackCardModalViewController *blackCardModalVC = (BlackCardModalViewController *)segue.destinationViewController;
        blackCardModalVC.blackCard = self.blackCardInPlay;
    }
}

#pragma mark - Game Manager Delegate Methods
- (void)gameManagerDidReceiveBlackCard:(BlackCard *)blackCard asBlackCardPlayer:(BOOL)blackCardPlayer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", blackCard.text);
    self.blackCardInPlay = blackCard;
    
    if (blackCardPlayer) {
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
@end
