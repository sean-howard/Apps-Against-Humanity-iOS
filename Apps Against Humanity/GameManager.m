//
//  GameManager.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 28/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "GameManager.h"
#import "SocketServer.h"
#import "SocketClient.h"

@interface GameManager ()<SocketClientDelegate, SocketServerDelegate>
@property (nonatomic, strong) SocketServer *server;
@property (nonatomic, strong) SocketClient *client;

@property (nonatomic, getter=isGameHost) BOOL gameHost;
@end

@implementation GameManager

static GameManager *SINGLETON = nil;

static bool isFirstAccess = YES;

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

- (id) init
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

#pragma mark - Socket Server delegate methods


#pragma mark - Socket Client delegate methods


@end
