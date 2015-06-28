//
//  LobbyViewController.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 24/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Lobby;

@interface LobbyViewController : UITableViewController
@property (nonatomic) BOOL lobbyAsHost;
@property (nonatomic) Lobby *lobbyToConnectTo;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startGameButton;

- (IBAction)startGameButtonPressed:(id)sender;

@end
