//
//  SocketServerManager.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "SocketServerManager.h"
#import "MBWebSocketServer.h"

@interface SocketServerManager ()<NSNetServiceDelegate, MBWebSocketServerDelegate>
@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) MBWebSocketServer *socketServer;
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
    
    self.socketServer = [[MBWebSocketServer alloc] initWithPort:12345 delegate:self];
    
    self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_AppsAgainstHumanity._tcp." name:@"" port:(int)[self.socketServer port]];
    
    // Configure Service
    [self.service setDelegate:self];
    
    // Publish Service
    [self.service publish];
        
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
#pragma mark MBWebSocketServerDelegate
- (void)webSocketServer:(MBWebSocketServer *)webSocketServer didAcceptConnection:(GCDAsyncSocket *)connection
{
    NSLog(@"Accepted New Socket from %@:%hu", [connection connectedHost], [connection connectedPort]);
    
    [self.connections addObject:connection];
    
    // Read Data from Socket
    [connection readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    
    if ([self.delegate respondsToSelector:@selector(serverDidAcceptNewConnections:)]) {
        [self.delegate serverDidAcceptNewConnections:self.connections];
    }
}

- (void)webSocketServer:(MBWebSocketServer *)webSocketServer clientDisconnected:(GCDAsyncSocket *)connection
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.connections containsObject:connection]) {
        [self.connections removeObject:connection];
        if ([self.delegate respondsToSelector:@selector(serverDidLoseConnections:)]) {
            [self.delegate serverDidLoseConnections:self.connections];
        }
    }
}

- (void)webSocketServer:(MBWebSocketServer *)webSocket didReceiveData:(NSData *)data fromConnection:(GCDAsyncSocket *)connection
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webSocketServer:(MBWebSocketServer *)webSocketServer couldNotParseRawData:(NSData *)rawData fromConnection:(GCDAsyncSocket *)connection error:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
