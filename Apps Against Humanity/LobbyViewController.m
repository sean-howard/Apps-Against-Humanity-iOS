//
//  LobbyViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 24/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "LobbyViewController.h"
#import "GameManager.h"
#import "Player.h"
#import "Lobby.h"

@interface LobbyViewController ()<GameManagerDelegate>
@property (nonatomic, strong) NSArray *players;
@end

@implementation LobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[GameManager sharedManager] setDelegate:self];
    
    if (self.lobbyAsHost) {
        [[GameManager sharedManager] startAsHost];
    }
    
    if (self.lobbyToConnectTo) {
        [[GameManager sharedManager] connectToLobby:self.lobbyToConnectTo];
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
    return self.players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Player *player = self.players[indexPath.row];
    cell.textLabel.text = player.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SocketServerManagerDelegates
- (void)gameManagerDidUpdateConnectedPlayers:(NSArray *)players
{
    self.players = players;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
@end
