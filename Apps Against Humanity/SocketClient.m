//
//  SocketClient.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "SocketClient.h"
#import <SocketRocket/SRWebSocket.h>
#include <arpa/inet.h>
#import "MessagePacket.h"
#import "AppDelegate.h"
#import "GameManager.h"
#import "Lobby.h"

@interface SocketClient ()<NSNetServiceDelegate, NSNetServiceBrowserDelegate, SRWebSocketDelegate>
@property (strong, nonatomic) SRWebSocket *socket;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@end

@implementation SocketClient

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

- (void)sendMessage:(MessagePacket *)packet
{
    [self.socket send:[packet asString]];
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

    if([[GameManager sharedManager] isGameHost]) {
        [self resolveService:service];
    }
    
    // Update Services
    
    Lobby *lobby = [Lobby new];
    lobby.lobbyName = service.name;
    lobby.service = service;
    
    [self.services addObject:lobby];
    [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lobby.lobbyName" ascending:YES]]];

    if ([self.delegate respondsToSelector:@selector(clientDidUpdateServices:)]) {
        [self.delegate clientDidUpdateServices:self.services];
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

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Player *player = appDelegate.player;
    player.socket = webSocket;

    if ([self.delegate respondsToSelector:@selector(clientDidConnectToServer)]) {
        [self.delegate clientDidConnectToServer];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    MessagePacket *packet = [[MessagePacket alloc] initWithRawData:message];
    
    if (packet) {
        if ([self.delegate respondsToSelector:@selector(clientDidReceiveMessagePacket:)]) {
            [self.delegate clientDidReceiveMessagePacket:packet];
        }
    }
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
