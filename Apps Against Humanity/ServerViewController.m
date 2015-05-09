//
//  ServerViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "ServerViewController.h"
#import "SocketServerManager.h"

@interface ServerViewController ()<SocketServerDelegate>

@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[SocketServerManager sharedManager] setDelegate:self];
    [[SocketServerManager sharedManager] startBroadcast];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
