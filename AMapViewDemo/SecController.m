//
//  SecController.m
//  MapDemo
//
//  Created by 铁拳科技 on 16/8/22.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "SecController.h"
#import "TggMapView.h"
#import <AMapLocationKit/AMapLocationKit.h>



@interface SecController ()

@end

@implementation SecController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    TggMapView *mapView = [TggMapView viewFromNib];
    mapView.frame = self.view.bounds;
    mapView.frame = CGRectMake(0, 200, 320, 300);
    [self.view addSubview:mapView];
    
    
    
}


@end
