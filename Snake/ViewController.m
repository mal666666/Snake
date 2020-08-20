//
//  ViewController.m
//  Snake
//
//  Created by 马 爱林 on 16/4/16.
//  Copyright © 2016年 manbu. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>

#define UIScreenWidth    [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight   [UIScreen mainScreen].bounds.size.height
#define INTERFACE_IS_IPHONEX  (@available(iOS 11.0, *) && ([UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0)?YES:NO)
#define nav_Height (INTERFACE_IS_IPHONEX ? 88 : 64)
#define tabBar_Height (INTERFACE_IS_IPHONEX ? 83 : 49)

#define _CELL @ "acell"
#define Speed 0.4

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate>
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSMutableArray *snake_arr;//所有点
@property(nonatomic, assign)NSInteger chang_num;//判断方向
@property(nonatomic, strong)NSMutableArray *snake_state;//辅助数组
@property(nonatomic, assign)NSInteger random_num;//随机数
@property(nonatomic, strong)NSTimer *myTimer;//定时器
@property(nonatomic, assign)int row;//列
@property(nonatomic, assign)float cell_width;//cell宽
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout=[[ UICollectionViewFlowLayout alloc ] init ];
    layout.minimumLineSpacing =1;
    layout.minimumInteritemSpacing =1;
    _collectionView=[[ UICollectionView alloc ] initWithFrame :CGRectMake(0, 20,UIScreenWidth,UIScreenHeight) collectionViewLayout :layout];
    [_collectionView registerClass :[ UICollectionViewCell class ] forCellWithReuseIdentifier : _CELL ];
    self.collectionView. backgroundColor =[ UIColor clearColor];
    self.collectionView. delegate = self ;
    self.collectionView. dataSource = self;
    self.collectionView.backgroundColor =[UIColor lightGrayColor];
    self.collectionView.scrollEnabled =0;
    [self.view addSubview :_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.offset(10);
        make.left.right.offset(0);
        make.bottomMargin.offset(0);
    }];
    
//    float height =UIScreenHeight -nav_Height  - tabBar_Height ;
//    _row =(height-20)/((UIScreenWidth-21)/20+1);
    _cell_width =(UIScreenWidth-21)/20;
    [self initSnake];
    [self bindSwipe];
    
    // 设置允许摇一摇功能
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    // 并让自己成为第一响应者
    [self becomeFirstResponder];
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    float height =0;
    if (@available(iOS 11.0, *)) {
        height =self.view.safeAreaLayoutGuide.layoutFrame.size.height;
    } else {
        height =self.view.bounds.size.height;
    }
    _row =(height-20)/((UIScreenWidth-21)/20+1);
}
#pragma mark - 摇一摇相关方法
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSLog(@"开始摇动");
}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSLog(@"取消摇动");
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.subtype == UIEventSubtypeMotionShake) { // 判断是否是摇动结束
        NSLog(@"摇动结束");
        [self initSnake];
    }
}
-(void)initSnake{
    [_myTimer invalidate];
    _myTimer =nil;
    _snake_arr =[NSMutableArray arrayWithCapacity:0];
    [_snake_arr addObjectsFromArray:[NSArray arrayWithObjects:@"28",@"29",@"30",@"31",@"32", nil]];
    _random_num =arc4random()%20*_row;
    _chang_num =-1;
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:Speed target:self selector:@selector(snakeMove) userInfo:nil repeats:YES];
}
- (void)bindSwipe{
    UISwipeGestureRecognizer *recognizer_1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp)];
    recognizer_1.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:recognizer_1];
    UISwipeGestureRecognizer *recognizer_2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft)];
    recognizer_2.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:recognizer_2];
    UISwipeGestureRecognizer *recognizer_3 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown)];
    recognizer_3.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:recognizer_3];
    UISwipeGestureRecognizer *recognizer_4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight)];
    recognizer_4.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:recognizer_4];
    
    UILongPressGestureRecognizer *longPressReger = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    longPressReger.minimumPressDuration = 2.0;
    [self.view addGestureRecognizer:longPressReger];
    
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    NSLog(@"长按");
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        [self initSnake];
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
    }
    else{
    }
}
-(void)handleSwipeUp{
    NSLog(@"上滑");
    if (_chang_num!=20) {
        _chang_num =-20;
    }
}
-(void)handleSwipeLeft{
    NSLog(@"左滑");
    if (_chang_num!=1) {
        _chang_num =-1;
    }
}
-(void)handleSwipeDown{
    NSLog(@"下滑");
    if (_chang_num!=-20) {
        _chang_num=+20;
    }
}
-(void)handleSwipeRight{
    NSLog(@"右滑");
    if (_chang_num!=-1) {
        _chang_num =+1;
    }
}
-(void)snakeMove{
    [_snake_state removeAllObjects];
    _snake_state =[NSMutableArray arrayWithArray:_snake_arr];
    //移动
    for (int i=0; i<_snake_arr.count; i++) {
        
        if (i==0) {
            NSInteger x =[_snake_arr[i] integerValue]+_chang_num;
            if (x==_random_num) {
                [_snake_arr insertObject:[NSString stringWithFormat:@"%ld",(long)_random_num] atIndex:0];

                if(1){//产生当前没有的数
                    _random_num =arc4random()%20*_row;
                    if (![_snake_arr containsObject:[NSString stringWithFormat:@"%ld",(long)_random_num]]) {
                        break;
                    }
                }
            }
            [_snake_arr replaceObjectAtIndex:(NSUInteger)i withObject:[NSString stringWithFormat:@"%ld",(long)x]];
        }else{
            [_snake_arr replaceObjectAtIndex:(NSUInteger)i withObject:[NSString stringWithFormat:@"%@",_snake_state[i-1]]];
        }
    }

    //判断碰撞
    //自己碰撞自己
    for (NSString *str in _snake_arr) {
        int x=0;
        for (int i=0; i<_snake_arr.count; i++) {
            if ([_snake_arr[i] isEqualToString:str]) {
                x++;
                //NSLog(@"____%d____",x);
                if (x>1) {
                    [self addAlert];
                    return;
                    
                }
            }
        }
    }
    //顶、底碰撞
    if ([_snake_arr[0] integerValue]>20*_row ||[_snake_arr[0] integerValue]<0) {
        [self addAlert];
        return;
    }
    //左碰撞
    if (([_snake_arr[0] integerValue]+1)%20==0&&_chang_num==-1) {
        [self addAlert];
        return;
    }
    //右碰撞
    if (([_snake_arr[0] integerValue])%20==0&&_chang_num==1) {
        [self addAlert];
        return;
    }
    [_collectionView reloadData];
}
-(void)addAlert{
    [_myTimer invalidate];
    _myTimer =nil;
    UIAlertController *alertVC =[UIAlertController alertControllerWithTitle:@"游戏结束" message:@"摇一摇，或长按屏幕重新开始..." preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1 =[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *action2 =[UIAlertAction actionWithTitle:@"重新开始" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self initSnake];
    }];
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [self presentViewController:alertVC animated:YES completion:nil];
}
-( NSInteger )collectionView:( UICollectionView *)collectionView numberOfItemsInSection:( NSInteger )section{
    return 20*_row;
}
-( UICollectionViewCell *)collectionView:( UICollectionView *)collectionView cellForItemAtIndexPath:( NSIndexPath *)indexPath{
    if (collectionView==_collectionView) {
        UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier : _CELL forIndexPath :indexPath];
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        _collectionView.frame =CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y, _collectionView.frame.size.width, _collectionView.contentSize.height);
        NSString *str=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        if ([_snake_arr containsObject:str]) {
            cell. backgroundColor = [ UIColor colorWithRed :(( arc4random ()% 255 )/ 255.0 ) green :(( arc4random ()% 255 )/ 255.0 ) blue :(( arc4random ()% 255 )/ 255.0 ) alpha : 1.0f ];
            //cell.backgroundColor =[UIColor greenColor];
        }
        else if (_random_num==indexPath.row){
            cell.backgroundColor =[UIColor redColor];
        }
        else{
            cell.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        }
        return cell;
    }
    return nil;
}
- ( CGSize )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath{
    if (collectionView==_collectionView) {
        return CGSizeMake (_cell_width , _cell_width );
    }
    return CGSizeZero;
}
-( UIEdgeInsets )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:( NSInteger )section{
    return UIEdgeInsetsMake ( 1 , 1 , 1 , 1 );
}

@end

