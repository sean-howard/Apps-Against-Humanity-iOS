//
//  LobbyBrowserViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "LobbyBrowserViewController.h"
#import "GameManager.h"
#import "Lobby.h"
#import "LobbyViewController.h"

@interface LobbyBrowserViewController ()<GameManagerDelegate>
@property (nonatomic, strong) NSArray *lobbies;
@property (nonatomic, strong) Lobby *selectedLobby;
@end

@implementation LobbyBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[GameManager sharedManager] setDelegate:self];
    [[GameManager sharedManager] startAsClient];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lobbies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Lobby *lobby = (Lobby *)self.lobbies[indexPath.row];
    cell.textLabel.text = lobby.lobbyName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedLobby = (Lobby *)self.lobbies[indexPath.row];
    [self performSegueWithIdentifier:@"showLobby" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLobby"]) {
        LobbyViewController *lobbyVC = (LobbyViewController *)segue.destinationViewController;
        lobbyVC.lobbyAsHost = NO;
        lobbyVC.lobbyToConnectTo = self.selectedLobby;
    }
}

#pragma mark - Game Manager Delegate Methods
- (void)gameManagerDidFindAvailableLobbies:(NSArray *)lobbies
{
    self.lobbies = lobbies;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchQuickCommand:(id)sender {
    [self performSegueWithIdentifier:@"quickCommand" sender:self];
}
@end
