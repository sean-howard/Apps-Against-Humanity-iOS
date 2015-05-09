//
//  SocketClientManager.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "SocketClientManager.h"
#import <GCDAsyncSocket.h>

@interface SocketClientManager ()<NSNetServiceDelegate, NSNetServiceBrowserDelegate>
@property (strong, nonatomic) GCDAsyncSocket *socket;
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
    if ([self connectWithService:service]) {
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    } else {
        NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    }
}

- (BOOL)connectWithService:(NSNetService *)service {
    BOOL _isConnected = NO;
    
    // Copy Service Addresses
    NSArray *addresses = [[service addresses] mutableCopy];
    
    if (!self.socket || ![self.socket isConnected]) {
        // Initialize Socket
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // Connect
        while (!_isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            
            NSError *error = nil;
            if ([self.socket connectToAddress:address error:&error]) {
                _isConnected = YES;
                
            } else if (error) {
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
            }
        }
        
    } else {
        _isConnected = [self.socket isConnected];
    }
    
    return _isConnected;
}

#pragma mark -
#pragma mark GCDSocketDelegate Methods
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    
    // Start Reading
    [socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    
    if ([self.delegate respondsToSelector:@selector(clientDidConnectToServer)]) {
        [self.delegate clientDidConnectToServer];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
    
    [socket setDelegate:nil];
    [self setSocket:nil];
    
    if ([self.delegate respondsToSelector:@selector(clientDidDisconnectFromServer)]) {
        [self.delegate clientDidDisconnectFromServer];
    }
}

@end
