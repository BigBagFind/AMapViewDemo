//
//  TggMapView.h
//  MapDemo
//
//  Created by 铁拳科技 on 16/8/22.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>


@class AMapLocationManager;

/** 为TggMapView增加个代理，方便以后扩展 */
@protocol TggMapViewDelegate <NSObject>

@optional

/** 代理方法，地图区域移动回调函数 */
- (void)tgg_mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

/** 代理方法，实现逆地理编码的回调函数 */
- (void)tgg_onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response;

/** 代理方法，实现逆地理编码失败的回调函数 */
- (void)tgg_AMapSearchRequest:(id)request didFailWithError:(NSError *)error;


@end


@interface TggMapView : UIView<MKMapViewDelegate,AMapSearchDelegate>

/** 主地图 */
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

/** 自定义中心点 */
@property (weak, nonatomic) IBOutlet UIImageView *myAnnotation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myAnnotationTop;

/** 定位manager */
@property (nonatomic, strong) AMapLocationManager *locationManager;

/** 搜索manager */
@property (nonatomic, strong) AMapSearchAPI *search;

/** 反编译对象 */
@property (nonatomic, strong) AMapReGeocodeSearchRequest *regeo;

/** TggMapView的代理对象 */
@property (nonatomic, weak) id  <TggMapViewDelegate>delegate;



/** 类方法初始化，从nib加载 */
+ (instancetype)viewFromNib;






@end
