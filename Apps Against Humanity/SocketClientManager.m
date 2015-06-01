//
//  SocketClientManager.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "SocketClientManager.h"
#import <SocketRocket/SRWebSocket.h>
#include <arpa/inet.h>
#import "MessagePacket.h"

@interface SocketClientManager ()<NSNetServiceDelegate, NSNetServiceBrowserDelegate, SRWebSocketDelegate>
@property (strong, nonatomic) SRWebSocket *socket;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@end

@implementation SocketClientManager

static SocketClientManager *SINGLETON = nil;

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
    return [[SocketClientManager alloc] init];
}

- (id)mutableCopy
{
    return [[SocketClientManager alloc] init];
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

- (void)startBrowsing {
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
    
    // Initialize Service Browser
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    
    // Configure Service Browser
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:@"_AppsAgainstHumanity._tcp." inDomain:@"local."];
}

- (void)stopBrowsing {
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        [self setServiceBrowser:nil];
    }
}

- (void)resolveService:(NSNetService *)service
{
    // Resolve Service
    [service setDelegate:self];
    [service resolveWithTimeout:30.0];
}

#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services addObject:service];
    [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

    if ([self.delegate respondsToSelector:@selector(clientDidUpdateServices:)]) {
        [self.delegate clientDidUpdateServices:self.services];
    }

    if(!moreComing) {
        // Sort Services
        if ([self.delegate respondsToSelector:@selector(clientDidFinishFindingServices:)]) {
            [self.delegate clientDidFinishFindingServices:self.services];
        }
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services removeObject:service];
    
    if(!moreComing) {
        if ([self.delegate respondsToSelector:@selector(clientDidUpdateServices:)]) {
            [self.delegate clientDidUpdateServices:self.services];
        }
    }
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    [service setDelegate:nil];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo {
    [self stopBrowsing];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    // Connect With Service
    [self connectWithService:service];
}

- (void)connectWithService:(NSNetService *)service {
    // Copy Service Addresses
    NSArray *addresses = [[service addresses] mutableCopy];
    
    if (!self.socket) {
        // Initialize Socket
        self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self getStringFromAddressData:[addresses firstObject]]]]];
        self.socket.delegate = self;
        [self.socket open];
     }
}

- (NSString *)getStringFromAddressData:(NSData *)dataIn {
    struct sockaddr_in  *socketAddress = nil;
    NSString            *ipString = nil;
    
    socketAddress = (struct sockaddr_in *)[dataIn bytes];
    ipString = [NSString stringWithFormat: @"http://%s:%i",
                inet_ntoa(socketAddress->sin_addr),ntohs(socketAddress->sin_port)];  ///problem here
    
    return ipString;
}


#pragma mark -
#pragma mark SRSocketDelegate Methods
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSDictionary *lobbyMessage = @{@"action":[NSNumber numberWithInt:MessagePacketActionJoiningLobby],
                                   @"name":@"Sean Howard"};
    
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:lobbyMessage options:0 error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSString *string = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", string);
    [webSocket send:string];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, message);
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSLog(@"Client received message: %@", json);
}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", error.localizedDescription);
}

@end
