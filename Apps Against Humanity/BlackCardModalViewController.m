//
//  BlackCardModalViewController.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 28/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "BlackCardModalViewController.h"
#import "BlackCard.h"

@interface BlackCardModalViewController ()

@end

@implementation BlackCardModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.blackCardLabel.text = self.blackCard.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
