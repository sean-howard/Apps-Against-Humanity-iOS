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

@interface GameManager ()<SocketClientDelegate, SocketServerDelegate>
@property (nonatomic, strong) SocketServer *server;
@property (nonatomic, strong) SocketClient *client;

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

- (Player *)localPlayer
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Player *player = appDelegate.player;
    return player;
}

- (void)updateLobbyWithLocalPlayer
{
    MessagePacket *packet = [[MessagePacket alloc] initWithData:[[self localPlayer] serialise]
                                                         action:MessagePacketActionJoiningLobby];
    
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
            
        default:
            break;
    }
}

- (void)updateConnectedPlayersWithDict:(NSDictionary *)data
{
    Player *player = [Player new];
    player.name = data[@"name"];
    player.uuid = data[@"uuid"];
    
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

@end
