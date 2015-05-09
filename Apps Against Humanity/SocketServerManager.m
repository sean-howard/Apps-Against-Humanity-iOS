//
//  SocketServerManager.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "SocketServerManager.h"
#import <GCDAsyncSocket.h>

@interface SocketServerManager ()<NSNetServiceDelegate, GCDAsyncSocketDelegate>
@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *connections;
@end

@implementation SocketServerManager

static SocketServerManager *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark -
#pragma mark Lazy Loading
- (NSMutableArray *)connections
{
    if (!_connections) {
        _connections = [NSMutableArray new];
    }
    return _connections;
}

#pragma mark -
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

#pragma mark -
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
    return [[SocketServerManager alloc] init];
}

- (id)mutableCopy
{
    return [[SocketServerManager alloc] init];
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

- (void)startBroadcast {
    // Initialize GCDAsyncSocket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Start Listening for Incoming Connections
    NSError *error = nil;
    if ([self.socket acceptOnPort:0 error:&error]) {
        // Initialize Service
        self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_AppsAgainstHumanity._tcp." name:@"" port:[self.socket localPort]];
        
        // Configure Service
        [self.service setDelegate:self];
        
        // Publish Service
        [self.service publish];
        
    } else {
        NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

#pragma mark -
#pragma mark NSNetServiceDelegate
- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    
    if ([self.delegate respondsToSelector:@selector(serverDidStartBroadcasting)]) {
        [self.delegate serverDidStartBroadcasting];
    }
    
}

- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [service domain], [service type], [service name], errorDict);
    
    if ([self.delegate respondsToSelector:@selector(serverDidFailToBroadcast)]) {
        [self.delegate serverDidFailToBroadcast];
    }
}

#pragma mark -
#pragma mark GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
    [self.connections addObject:newSocket];
    
    // Read Data from Socket
    [newSocket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    
    if ([self.delegate respondsToSelector:@selector(serverDidAcceptNewConnections:)]) {
        [self.delegate serverDidAcceptNewConnections:self.connections];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@ %@", [error localizedDescription], [error description]);

    if (self.socket == socket) {
        [self.socket setDelegate:nil];
        [self setSocket:nil];
        
        if ([self.delegate respondsToSelector:@selector(serverDidDisconnect)]) {
            [self.delegate serverDidDisconnect];
        }
    }
    
    if ([self.connections containsObject:socket]) {
        [self.connections removeObject:socket];
        if ([self.delegate respondsToSelector:@selector(serverDidLoseConnections:)]) {
            [self.delegate serverDidLoseConnections:self.connections];
        }
    }
}

@end
