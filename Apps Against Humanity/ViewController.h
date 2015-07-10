//
//  ViewController.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;

- (IBAction)hostGameButtonPressed:(UIButton *)sender;
- (IBAction)joinGameButtonPressed:(UIButton *)sender;
@end

