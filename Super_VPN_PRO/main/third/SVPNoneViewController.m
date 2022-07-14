//
//  SVPNoneViewController.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/16.
//

#import "SVPNoneViewController.h"

@interface SVPNoneViewController ()

@end

@implementation SVPNoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *noneLabel = [[UILabel alloc]init];
    noneLabel.frame = CGRectMake(0, self.view.frame.size.height /2 - 21/2, self.view.frame.size.width, 21);
    noneLabel.font = [UIFont systemFontOfSize:15.0];
    noneLabel.textColor = [UIColor blackColor];
    noneLabel.textAlignment = NSTextAlignmentCenter;
    noneLabel.text = @"Please confirm whether the network is normal";
    [self.view addSubview:noneLabel];
}



@end
