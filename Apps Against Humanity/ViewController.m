//
//  ViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "ViewController.h"
#import "LobbyViewController.h"
#import "CardManager.h"
#import "GameManager.h"
#import "Player.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if(![[CardManager sharedManager] packsAvailable]) {
        [[CardManager sharedManager] populateDatabaseWithCards];
    }
    
    NSString *defaultPlayerName = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultPlayerName"];
    self.nameField.text = defaultPlayerName;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLobby"]) {
        LobbyViewController *lobbyVC = (LobbyViewController *)segue.destinationViewController;
        lobbyVC.lobbyAsHost = YES;
    }
}

- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"defaultPlayerName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)hostGameButtonPressed:(UIButton *)sender {
    if([self validateAndMakeLocalPlayer]){
        [self performSegueWithIdentifier:@"showLobby" sender:self];
    }
}

- (IBAction)joinGameButtonPressed:(UIButton *)sender {
    if([self validateAndMakeLocalPlayer]){
        [self performSegueWithIdentifier:@"lobbyBrowser" sender:self];
    }
}

- (BOOL)validateAndMakeLocalPlayer
{
    if (self.nameField.text.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Name"
                                    message:@"You must have a player name to play this awesome game!"
                                   delegate:nil
                          cancelButtonTitle:@"Okay!"
                          otherButtonTitles:nil, nil] show];
        return NO;
    }
    
    Player *player = [Player new];
    player.name = self.nameField.text;
    player.uuid = [[NSUUID UUID] UUIDString];
    
    [[GameManager sharedManager] setLocalPlayer:player];
    return YES;
}
@end
