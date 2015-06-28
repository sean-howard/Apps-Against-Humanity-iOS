//
//  GameManager.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 28/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Lobby;
@class BlackCard;
@class Hand;

@protocol GameManagerDelegate <NSObject>
@optional
- (void)gameManagerDidFindAvailableLobbies:(NSArray *)lobbies;
- (void)gameManagerDidUpdateConnectedPlayers:(NSArray *)players;
- (void)gameManagerDidStartGameSession;
- (void)gameManagerDidReceiveBlackCard:(BlackCard *)blackCard asBlackCardPlayer:(BOOL)blackCardPlayer;
- (void)gameManagerDidReceiveInitialHand:(Hand *)hand;
@end

@interface GameManager : NSObject

@property (nonatomic) id <GameManagerDelegate> delegate;
@property (nonatomic, getter=isGameHost) BOOL gameHost;

/**
 * gets singleton object.
 * @return singleton
 */
+ (GameManager*)sharedManager;
- (void)startAsHost;
- (void)startAsClient;
- (void)connectToLobby:(Lobby *)lobby;
- (void)enterGame;
- (void)selectFirstBlackCardPlayer;
- (void)distributeInitialWhiteCards;
@end
