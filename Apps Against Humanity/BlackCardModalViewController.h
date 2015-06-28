//
//  BlackCardModalViewController.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 28/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BlackCard;

@interface BlackCardModalViewController : UIViewController
@property (nonatomic, strong) BlackCard *blackCard;
@property (weak, nonatomic) IBOutlet UILabel *blackCardLabel;
@end
