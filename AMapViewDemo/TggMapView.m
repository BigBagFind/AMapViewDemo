//
//  TggMapView.m
//  MapDemo
//
//  Created by 铁拳科技 on 16/8/22.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "TggMapView.h"
#import "UIView+ViewController.h"


#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3


@implementation TggMapView{
    MKCoordinateSpan _currentSpan;
}


/** 感觉没软用 */
- (void)dealloc {
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode  = MKUserTrackingModeNone;
    [self.mapView.layer removeAllAnimations];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

+ (instancetype)viewFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil] lastObject];
}


- (void)awakeFromNib {
    // 当前地图跟踪模式
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    // 设置地图代理
    self.mapView.delegate = self;
    
    // 先隐藏annotation
    self.myAnnotation.hidden = YES;
    
    // 初始化locationManager
    [self configLocationManager];
    
    // 初始化检索对象
    [self configSearchLObject];
}

- (void)configLocationManager {
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
    }
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，最低2s，此处设置为2s
    _locationManager.locationTimeout = DefaultLocationTimeout;
    //   逆地理请求超时时间，最低2s，此处设置为2s
    _locationManager.reGeocodeTimeout = DefaultReGeocodeTimeout;
}

- (void)configSearchLObject {
    //初始化检索对象
    if (!_search) {
        _search = [[AMapSearchAPI alloc] init];
    }
    _search.delegate = self;
    //构造AMapReGeocodeSearchRequest对象
    if (!_regeo) {
        _regeo = [[AMapReGeocodeSearchRequest alloc] init];
    }
    _regeo.radius = 10000;
    _regeo.requireExtension = NO;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.myAnnotationTop.constant = (self.frame.size.height - 30) / 2 - 15;
}

#pragma mark - 回到当前位置
- (IBAction)backToHome:(UIButton *)sender {
    //MKCoordinateSpan span = MKCoordinateSpanMake(0.021251, 0.016093);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.006085, 0.006085);
    [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.userLocation.coordinate, span) animated:YES];
}

#pragma mark - 放大
- (IBAction)zoomOutMapView:(UIButton *)sender {
    
    //获取维度跨度并放大一倍
    CGFloat latitudeDelta = self.mapView.region.span.latitudeDelta * 0.5;
    //获取经度跨度并放大一倍
    CGFloat longitudeDelta = self.mapView.region.span.longitudeDelta * 0.5;
    //经纬度跨度
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    //设置当前区域
    MKCoordinateRegion region = MKCoordinateRegionMake(self.mapView.centerCoordinate, span);
    [self.mapView setRegion:region animated:YES];
    
}

#pragma mark - 缩小
- (IBAction)zoomInMapView:(UIButton *)sender {
    
    //获取维度跨度并缩小一倍
    CGFloat latitudeDelta = self.mapView.region.span.latitudeDelta * 2;
    //获取经度跨度并缩小一倍
    CGFloat longitudeDelta = self.mapView.region.span.longitudeDelta * 2;
    //经纬度跨度
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    //设置当前区域
    MKCoordinateRegion region = MKCoordinateRegionMake(self.mapView.centerCoordinate, span);
    [self.mapView setRegion:region animated:YES];
    
}


#pragma mark - MKMapViewDelegate
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
   
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error) {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed) {
                return;
            }
        }
        
        if (regeocode) {
            // 设置标题
            userLocation.title = regeocode.city;
            // 设置子标题
            userLocation.subtitle = regeocode.formattedAddress;
            // 中心点出现
            self.myAnnotation.hidden = NO;
        }
        
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        NSLog(@"%@",error);
        [self appLocationFail];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
 
    NSLog(@"regionDidChangeAnimated %f,%f",mapView.region.center.latitude, mapView.region.center.longitude);
    // 判断定位是否代开
    [self locationServicesUnEnabled];
    // 构造location
    _regeo.location = [AMapGeoPoint locationWithLatitude:mapView.region.center.latitude  longitude:mapView.region.center.longitude];
    //发起逆地理编码
    [_search AMapReGoecodeSearch: _regeo];
    
    // 回调一个代理
    if ([self.delegate respondsToSelector:@selector(tgg_mapView:regionDidChangeAnimated:)]) {
        [self.delegate tgg_mapView:mapView regionDidChangeAnimated:animated];
    }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"%@",error);
    if (error.code == kCLErrorDenied) {
        [self appLocationFail];
    }
}

#pragma mark - AMapSearchDelegate
/** 实现逆地理编码的回调函数 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    NSLog(@"%@",response.regeocode);
    if(response.regeocode != nil){
        // 回调给代理，regeocode不为空回调回去
        if ([self.delegate respondsToSelector:@selector(tgg_onReGeocodeSearchDone:response:)]) {
            [self.delegate tgg_onReGeocodeSearchDone:request response:response];
        }
        
        // 通过AMapReGeocodeSearchResponse对象处理搜索结果且log
        NSString *result = [NSString stringWithFormat:@"ReGeocode: %@", response.regeocode];
        NSLog(@"ReGeo: %@", result);
        NSLog(@"ReGeo: %@", response.regeocode.formattedAddress);
        NSLog(@"ReGeo: %@", request.location);
    }
}


/** 实现逆地理编码的失败的回调函数 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
    // 事情交给代理去做
    if ([self.delegate respondsToSelector:@selector(tgg_AMapSearchRequest:didFailWithError:)]) {
        [self.delegate tgg_AMapSearchRequest:request didFailWithError:error];
    }
}


#pragma mark - 设备隐私定位没开
- (void)locationServicesUnEnabled {
//    // 没开定位给提示
//    if (![CLLocationManager locationServicesEnabled]) {
//        BaseViewController *baseVC = (BaseViewController *)self.viewController;
//        // 整个手机没开定位
//        [baseVC presentMyAlertWindowAlertWindowWithFirstTitle:@"稍后开启"
//                                                  SecondTitle:@"马上开启"
//                                                      Message:@"定位失败：设备定位为未打开，点击“马上开启”为喵喵开启定位吧（ps，开启后请点击重新定位）"
//                                              AlertFirstBlock:^{
//            
//        }
//                                             AlertSecondBlock:^{
//            // 跳转到手机的定位服务设置界面
//            NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
//            if ([TggApplication canOpenURL:url]) {
//                [TggApplication openURL:url];
//            }
//        }];
//        return;
//    }
}

#pragma mark - App定位没打开
- (void)appLocationFail {
//    // 整个手机没开定位
//    BaseViewController *baseVC = (BaseViewController *)self.viewController;
//    [baseVC presentMyAlertWindowAlertWindowWithFirstTitle:@"马上开启"
//                                              SecondTitle:nil
//                                                  Message:@"定位失败：喵喵定位为未打开，点击“马上开启”为喵喵开启定位吧"
//                                          AlertFirstBlock:^{
//        if (TggiOS_8_OR_LATER) {
//            if ([TggApplication canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
//                [TggApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//            }
//        } else {
//            // 手机的定位服务设置界面
//            NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
//            if ([TggApplication canOpenURL:url]) {
//                [TggApplication openURL:url];
//            }
//        }
//    }
//                                         AlertSecondBlock:^{
//        
//    }];
//    return;
}









@end
