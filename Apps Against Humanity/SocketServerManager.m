//
//  SocketServerManager.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "SocketServerManager.h"
#import <PocketSocket/PSWebSocketServer.h>
#import "MessagePacket.h"

@interface SocketServerManager ()<NSNetServiceDelegate, PSWebSocketServerDelegate>
@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) PSWebSocketServer *socketServer;
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
    
    
    self.socketServer = [PSWebSocketServer serverWithHost:nil port:12345];
    self.socketServer.delegate = self;
    [self.socketServer start];
    
    self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_AppsAgainstHumanity._tcp." name:@"" port:12345];
    
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
#pragma mark - PSWebSocketServerDelegate
- (void)serverDidStart:(PSWebSocketServer *)server {
    NSLog(@"Server did start…");
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"Server did stop…");
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    NSLog(@"Server should accept request: %@", request);
    return YES;
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSLog(@"Server received message: %@", json);
    
    if ([json[@"action"] integerValue] == 0) {
        [self.connections addObject:json];
        
        if ([self.delegate respondsToSelector:@selector(serverDidAcceptNewConnections:)]) {
            [self.delegate serverDidAcceptNewConnections:self.connections];
        }
    }
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"Server websocket did open");
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail with error: %@", error);
}

@end
