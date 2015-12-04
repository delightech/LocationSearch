//
//  ViewController.m
//  LocationSearch
//
//  Created by Hisafumi Kikkawa on 2015/12/04.
//  Copyright © 2015年 FreakOut, inc. All rights reserved.
//

#import "LocationSearchViewController.h"
#import <AddressBook/AddressBook.h>

@interface LocationSearchViewController ()
@property (strong, nonatomic) NSMutableArray *mapItems;
@end

@implementation LocationSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 検索結果を一時的に保存する配列を初期化
    _mapItems = [NSMutableArray array];
    [self initMapRegion];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self initMapRegion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Job

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder]; // キーボードを隠す
    
    // マップ検索リクエストを準備
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = _mapView.region; // 地図の範囲内で検索する
    
    // マップ検索クラスを生成
    MKLocalSearch * search = [[MKLocalSearch alloc] initWithRequest:request];
    // 検索結果をブロックで受け取る
    [search startWithCompletionHandler:^(MKLocalSearchResponse * response, NSError *error) {
        [_mapItems removeAllObjects];
        [_mapView removeAnnotations:[_mapView annotations]];
        for(MKMapItem *item in response.mapItems) {
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = item.placemark.coordinate; // 緯度経度
            point.title = item.placemark.name; // スポット名称
            point.subtitle = item.phoneNumber; // 電話番号
            [_mapView addAnnotation:point]; // 地図にアノテーションを追加
            [_mapItems addObject:item]; // TableView用に結果を保存
        }
        // アノテーションを表示（自動縮尺）
        [_mapView showAnnotations:[_mapView annotations] animated:YES];
        // 結果リストをTableViewに表示
        [_tableView reloadData];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // キーワードの入力がキャンセルの場合にキーボードを隠す
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    // キーワード入力のキャンセル開始でキャンセルボタンを表示
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    // キーワードの入力の終了でキャンセルボタンを表示
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

#pragma mark - Map Job

- (void)initMapRegion {
    // マップの初期表示範囲を設定
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(35.660994, 139.728163);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.5, 0.5);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    [point setCoordinate:coordinate];
    [point setTitle:@"FreakOut, inc."];
    [point setSubtitle:@"+81 3 6721 1740"];
    [_mapView setRegion:region];
    [_mapView addAnnotation:point]; // 地図にアノテーションを追加
    
    //NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    //[dic setObject:@"title" forKey:@"〒106-0032, 東京都港区六本木6-3-1六本木ヒルズクロスポイント5F"];
    NSDictionary *addressDict = @{
                                  (NSString *) kABPersonAddressCityKey : @"東京都港区6-3-1六本木ヒルズクロスポイント5F",
                                  (NSString *) kABPersonAddressZIPKey : @"〒106-0032",
                                  };
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDict];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    [item setName:@"フリークアウト ヒルズガレージ"];
    [_mapItems addObject:item]; // TableView用に結果を保存
    
}

- (IBAction)initButtonPushed:(id)sender {
    // マップの表示範囲を初期状態に戻す
    [self initMapRegion];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_mapItems count];
}

/*
 * TableViewへの表示
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MKMapItem *item = [_mapItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.title;
    return cell;
}

/*
 * セルがタップされた時の処理
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MKMapItem *item = [_mapItems objectAtIndex:indexPath.row];
    
    // MKMapViewのアノテーションはaddした順に並んでないので場所が一致するスポットを探し出す
    for(MKPointAnnotation *annotation in _mapView.annotations) {
        if((annotation.coordinate.latitude == item.placemark.coordinate.latitude) &&
           (annotation.coordinate.longitude == item.placemark.coordinate.longitude)) {
            [_mapView selectAnnotation:annotation animated:YES];
            break;
        }
    }
    
}
@end
