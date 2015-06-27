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
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    if (![[CardManager sharedManager] packsAvailable]) {
        [[CardManager sharedManager] populateDatabaseWithCards];
    }

}

@end
