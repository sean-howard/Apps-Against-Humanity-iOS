//
//  GameManager.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 28/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "GameManager.h"
#import "AppDelegate.h"
#import "MessagePacket.h"
#import "SocketServer.h"
#import "SocketClient.h"
#import "Lobby.h"
#import "CardManager.h"
#import "BlackCard.h"
#import "Hand.h"
#import "WhiteCard.h"

@interface GameManager ()<SocketClientDelegate, SocketServerDelegate>
@property (nonatomic, strong) SocketServer *server;
@property (nonatomic, strong) SocketClient *client;
@property (nonatomic, strong) Player *localPlayer;

@property (nonatomic ,strong) NSMutableArray *submittedWhiteCards;
@property (nonatomic, strong) NSMutableArray *players;
@end

@implementation GameManager

static GameManager *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Lazy loading
- (NSMutableArray *)players
{
    if (!_players) {
        _players = [NSMutableArray array];
    }
    return _players;
}

- (NSMutableArray *)submittedWhiteCards
{
    if (_submittedWhiteCards) {
        _submittedWhiteCards = [NSMutableArray new];
    }
    return _submittedWhiteCards;
}

#pragma mark - Public Method

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}

- (id)copy
{
    return [[GameManager alloc] init];
}

- (id)mutableCopy
{
    return [[GameManager alloc] init];
}

- (id)init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    return self;
}

- (void)startAsHost
{
    self.gameHost = YES;
    [self commonInit];
}

- (void)startAsClient
{
    self.gameHost = NO;
    [self commonInit];
}

- (void)commonInit
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.localPlayer = appDelegate.player;
    self.blackCardPlayer = NO;
    
    if (self.isGameHost) {
        [self startServer];
    }
    
    [self startClient];
}

- (void)startServer
{
    self.server = [SocketServer new];
    self.server.delegate = self;
    [self.server startBroadcast];
}

- (void)startClient
{
    self.client = [SocketClient new];
    self.client.delegate = self;
    [self.client startBrowsing];
}

- (void)connectToLobby:(Lobby *)lobby
{
    [self.client resolveService:lobby.service];
}

- (void)enterGame
{
    MessagePacket *packet = [[MessagePacket alloc] initWithData:@{}
                                                         action:MessagePacketActionStartGameSession];
    
    [self.client sendMessage:packet];
}

#pragma mark - Socket Client delegate methods
- (void)clientDidConnectToServer
{
    [self updateLobbyWithLocalPlayer];
}

- (void)clientDidUpdateServices:(NSArray *)services
{
    if ([self.delegate respondsToSelector:@selector(gameManagerDidFindAvailableLobbies:)]) {
        [self.delegate gameManagerDidFindAvailableLobbies:services];
    }
}

- (void)clientDidReceiveMessagePacket:(MessagePacket *)packet
{
    NSDictionary *packetData = packet.data;
    
    switch (packet.action) {
        case MessagePacketActionJoiningLobby:
            [self updateConnectedPlayersWithDict:packetData];
            break;
        case MessagePacketActionStartGameSession:
            
            //Reorder players alphabetically to help selecting black card player. <- temp solution
            [self.players sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
            
            if ([self.delegate respondsToSelector:@selector(gameManagerDidStartGameSession)]) {
                [self.delegate gameManagerDidStartGameSession];
            }
        case MessagePacketActionSelectBlackCardPlayer:
            [self presentBlackCardForPlayersWithDict:packetData];
            break;
        case MessagePacketActionDistributeWhiteCards:
            [self presentWhiteCardsWithDict:packetData];
            break;
        case MessagePacketActionSubmitWhiteCards:
            [self playerSubmittedWhiteCardsWithDict:packetData];
            break;
        case MessagePacketActionAllCardsSubmitted:
            [self presentAllSubmittedWhiteCards];
            break;
        default:
            break;
    }
}

#pragma mark - Lobby Logic
- (void)updateConnectedPlayersWithDict:(NSDictionary *)data
{
    Player *player = [Player new];
    player.name = data[@"playerName"];
    player.uuid = data[@"uniqueID"];
    
    BOOL alreadyAdded = NO;
    
    if ([self.players firstObject]) {
        for (Player *connectedPlayer in self.players) {
            alreadyAdded = [connectedPlayer.uuid isEqualToString:player.uuid];
            if (alreadyAdded) return;
        }
    }
    
    [self.players addObject:player];
    [self updateLobbyWithLocalPlayer];
    
    if ([self.delegate respondsToSelector:@selector(gameManagerDidUpdateConnectedPlayers:)]) {
        [self.delegate gameManagerDidUpdateConnectedPlayers:self.players];
    }
}

#pragma mark - Send Commands
#pragma mark - Game Play Logic
- (void)selectFirstBlackCardPlayer
{
    Player *blackCardPlayer = [self.players firstObject];
    BlackCard *blackCard = [[CardManager sharedManager] randomBlackCardFromPack:nil];
    
    NSDictionary *packetData = @{@"uniqueID":blackCardPlayer.uuid,
                                 @"blackCardID":@(blackCard.cardId)};
    
    MessagePacket *packet = [[MessagePacket alloc] initWithData:packetData
                                                         action:MessagePacketActionSelectBlackCardPlayer];
    
    [self.client sendMessage:packet];
}

- (void)distributeInitialWhiteCards
{
    NSMutableDictionary *playerHands = [NSMutableDictionary dictionary];
    
    for (Player *player in self.players) {
        Hand *hand = [[Hand alloc] initWithCount:7];
        [playerHands setObject:[hand asCardIds] forKey:player.uuid];
    }
    
    NSDictionary *packetData = @{@"initialCards":playerHands};
    
    MessagePacket *packet = [[MessagePacket alloc] initWithData:packetData action:MessagePacketActionDistributeWhiteCards];
    [self.client sendMessage:packet];
    
    NSLog(@"%@", packet.serialise);
}

- (void)submitWhiteCardsResponse:(NSArray *)whiteCards
{
    WhiteCard *whiteCard = (WhiteCard *)[whiteCards firstObject];
    
    NSDictionary *packetData = @{@"uniqueID":self.localPlayer.uuid,
                                 @"whiteCardID":@(whiteCard.cardId)};
    
    MessagePacket *packet = [[MessagePacket alloc] initWithData:packetData
                                                         action:MessagePacketActionSubmitWhiteCards];
    
    [self.client sendMessage:packet];
}

- (void)updateLobbyWithLocalPlayer
{
    MessagePacket *packet = [[MessagePacket alloc] initWithData:[self.localPlayer serialise]
                                                         action:MessagePacketActionJoiningLobby];
    
    [self.client sendMessage:packet];
}

- (void)sendAllPlayersSubmittedCommand
{
    if (self.submittedWhiteCards.count == self.players.count-1) {
        NSLog(@"RECEIVED WHITE CARDS FROM ALL PLAYERS");
        
        MessagePacket *packet = [[MessagePacket alloc] initWithData:@{}
                                                             action:MessagePacketActionAllCardsSubmitted];
        [self.client sendMessage:packet];
    }
}

#pragma mark - Receive Commands
- (void)presentBlackCardForPlayersWithDict:(NSDictionary *)data
{
    NSString *blackCardPlayerUUID = data[@"uniqueID"];
    NSInteger blackCardID = [data[@"blackCardID"] integerValue];
    BlackCard *blackCard = [[CardManager sharedManager] blackCardWithId:blackCardID];

    BOOL isBlackCardPlayer = [self.localPlayer.uuid isEqualToString:blackCardPlayerUUID];
        
    if ([self.delegate respondsToSelector:@selector(gameManagerDidReceiveBlackCard:asBlackCardPlayer:)]) {
        [self.delegate gameManagerDidReceiveBlackCard:blackCard asBlackCardPlayer:isBlackCardPlayer];
    }
}

- (void)presentWhiteCardsWithDict:(NSDictionary *)data
{
    NSArray *cardIDs = data[@"initialCards"][self.localPlayer.uuid];
    
    Hand *hand = [[Hand alloc] initWithCardIds:cardIDs];
    
    if (hand) {
        if ([self.delegate respondsToSelector:@selector(gameManagerDidReceiveInitialHand:)]) {
            [self.delegate gameManagerDidReceiveInitialHand:hand];
        }
    }
}

- (void)playerSubmittedWhiteCardsWithDict:(NSDictionary *)data
{
    if (!self.isCurrentlyBlackCardPlayer) return;
    
    NSString *whiteCardKey;
    if (data[@"whiteCardID"]) {
        whiteCardKey = @"whiteCardID";
    } else if (data[@"whiteCardIDs"]) {
        whiteCardKey = @"whiteCardIDs";
    } else {
        NSLog(@"%s: NO VALID WHITE CARD KEY", __PRETTY_FUNCTION__);
        return;
    }
    
    if ([data[whiteCardKey] isKindOfClass:[NSArray class]]){
        NSMutableArray *playerSubmittedCards = [NSMutableArray new];
        for (NSNumber *whiteCardID in data[whiteCardKey]) {
            WhiteCard *whiteCard = [[CardManager sharedManager] whiteCardWithId:[whiteCardID integerValue]];
            if (whiteCard) {
                [playerSubmittedCards addObject:whiteCard];
            }
        }
        [self.submittedWhiteCards addObject:playerSubmittedCards];
    }
    
    if ([data[whiteCardKey] isKindOfClass:[NSNumber class]]) {
        WhiteCard *whiteCard = [[CardManager sharedManager] whiteCardWithId:[data[whiteCardKey] integerValue]];
        if (whiteCard) {
            [self.submittedWhiteCards addObject:whiteCard];
        }
    }
    
    [self sendAllPlayersSubmittedCommand];
}

- (void)presentAllSubmittedWhiteCards
{
    if (self.isCurrentlyBlackCardPlayer) {
        if ([self.delegate respondsToSelector:@selector(gameManagerDidReceiveAllSubmittedWhiteCards:)]) {
            [self.delegate gameManagerDidReceiveAllSubmittedWhiteCards:self.submittedWhiteCards];
        }
    }
}

@end
