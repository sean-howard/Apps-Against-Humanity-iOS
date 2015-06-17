//
//  QuickCommandViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 17/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "QuickCommandViewController.h"
#import "MessagePacket.h"

@interface QuickCommandViewController ()

@end

@implementation QuickCommandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendCommand:(UIButton *)sender
{
    MessagePacket *packet;
    
    switch (sender.tag) {
        case 0:
            packet = [[MessagePacket alloc] initWithData:@{@"playerName":@"Sean Howard",
                                                           @"uniqueID":[[NSUUID UUID] UUIDString]}
                                                  action:MessagePacketActionJoiningLobby];
            break;
        case 1:
            packet = [[MessagePacket alloc] initWithData:@{}
                                                  action:MessagePacketActionStartGameSession];
            break;
        case 2:
            packet = [[MessagePacket alloc] initWithData:@{}
                                                  action:MessagePacketActionStartGameMatch];
            break;
        case 3:
            packet = [[MessagePacket alloc] initWithData:@{@"blackCardPlayerUniqueID":[[NSUUID UUID] UUIDString]}
                                                  action:MessagePacketActionSelectBlackCardPlayer];
            break;
        case 4:
            packet = [[MessagePacket alloc] initWithData:@{@"whiteCardIDs":@[@"2134",@"4314",@"4314",@"6897"]}
                                                  action:MessagePacketActionDistributeWhiteCards];
            break;
        case 5:
            packet = [[MessagePacket alloc] initWithData:@{@"blackCardID":@"0987654321"}
                                                  action:MessagePacketActionDisplayBlackQuestionCard];
            break;
        case 6:
            packet = [[MessagePacket alloc] initWithData:@{@"whiteCardID":@"1234567890"}
                                                  action:MessagePacketActionSubmitWhiteCard];
            break;
        case 7:
            packet = [[MessagePacket alloc] initWithData:@{}
                                                  action:MessagePacketActionAllCardsSubmitted];
            break;
        case 8:
            packet = [[MessagePacket alloc] initWithData:@{@"uniqueID":[[NSUUID UUID] UUIDString]}
                                                  action:MessagePacketActionChooseWinner];
            break;
        default:
            break;
    }
    
    NSLog(@"%@", [packet serialise]);
    
    
}

@end
