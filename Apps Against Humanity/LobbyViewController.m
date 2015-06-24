//
//  LobbyViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 24/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "LobbyViewController.h"
#import "SocketServerManager.h"

@interface LobbyViewController ()<SocketServerDelegate>
@property (nonatomic, strong) SocketServerManager *serverManager;
@property (nonatomic, strong) NSArray *players;
@end

@implementation LobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serverManager = [SocketServerManager sharedManager];
    self.serverManager.delegate = self;
    [self.serverManager startBroadcast];
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
    
    NSDictionary *player = self.players[indexPath.row];
    
    cell.textLabel.text = player[@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark SocketServerManagerDelegates
- (void)serverDidStartBroadcasting
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)serverDidFailToBroadcast
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)serverDidAcceptNewConnection
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)serverDidDisconnect
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)serverDidAcceptNewConnections:(NSArray *)connections
{
    self.players = connections;
    [self.tableView reloadData];
}

- (void)serverDidLoseConnections:(NSArray *)connections
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, connections);
}

@end
