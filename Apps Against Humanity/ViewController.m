//
//  ViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "ViewController.h"
#import "LobbyViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLobby"]) {
        LobbyViewController *lobbyVC = (LobbyViewController *)segue.destinationViewController;
        lobbyVC.lobbyAsHost = YES;
    }
}

@end
