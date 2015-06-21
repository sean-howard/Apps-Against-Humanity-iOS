//
//  ViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "ViewController.h"
#import "MessagePacket.h"
#import "CardManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    if (![[CardManager sharedManager] packsAvailable]) {
        [[CardManager sharedManager] populateDatabaseWithCards];
    }
    
    /*
    NSDictionary *rawMessage = @{@"name":@"Sean Howard",
                                 @"uuid":[[NSUUID UUID] UUIDString]};
    
    MessagePacket *message = [[MessagePacket alloc] initWithData:rawMessage action:MessagePacketActionJoiningLobby];
    
    NSLog(@"%@", [message asString]);
    NSLog(@"%@", [message serialise]);

    
    MessagePacket *secondPacket = [[MessagePacket alloc] initWithRawData:[message asString]];
    NSLog(@"%@", [secondPacket serialise]);
     */
}

@end
