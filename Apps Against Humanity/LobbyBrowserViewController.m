//
//  LobbyBrowserViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "LobbyBrowserViewController.h"
#import "SocketClientManager.h"

static NSString *ServiceCell = @"ServiceCell";

@interface LobbyBrowserViewController ()<SocketClientManagerDelegate>
@property (strong, nonatomic) NSArray *services;
@property (nonatomic, strong) SocketClientManager *clientManager;
@end

@implementation LobbyBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.clientManager = [SocketClientManager new];
    [self.clientManager setDelegate:self];
    [self.clientManager startBrowsing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.services ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ServiceCell];
    
    if (!cell) {
        // Initialize Table View Cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ServiceCell];
    }
    
    // Fetch Service
    NSNetService *service = [self.services objectAtIndex:[indexPath row]];
    
    // Configure Cell
    [cell.textLabel setText:[service name]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Fetch Service
    NSNetService *service = [self.services objectAtIndex:[indexPath row]];
    [self.clientManager resolveService:service];
}

#pragma mark -
#pragma mark SocketClientManager Delegate Methods
- (void)clientDidConnectToServer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)clientDidDisconnectFromServer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)clientDidFailToBroadcast
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)clientDidStartBrowsing
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)clientDidFinishFindingServices:(NSArray *)services
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, services);
    
    self.services = services;
    [self.tableView reloadData];
}

- (void)clientDidUpdateServices:(NSArray *)services
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, services);

    self.services = services;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchQuickCommand:(id)sender {
    [self performSegueWithIdentifier:@"quickCommand" sender:self];
}
@end
