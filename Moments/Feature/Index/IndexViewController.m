//
//  IndexViewController.m
//  Moments
//
//  Created by 宋国华 on 2018/9/11.
//  Copyright © 2018年 songguohua. All rights reserved.
//

#import "IndexViewController.h"
#import "SWStatusViewController.h"
#import "SWMessageViewController.h"
#import "SWAuthor.h"
#import "SWFeedbackViewController.h"
#import "SWInstructionsViewController.h"
@interface IndexViewController ()<GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) QMUIGridView *gridView;

@end

@implementation IndexViewController

- (void)initSubviews {
    [super initSubviews];
    self.view.backgroundColor = UIColorForBackground;
    [self setTitle:@"发现"];
    
    
    self.gridView = [[QMUIGridView alloc] init];
    self.gridView.columnCount = 3;
    self.gridView.rowHeight = kScreenW/3;
    self.gridView.separatorWidth = PixelOne;
    [self.view addSubview:self.gridView];
    
    NSArray *dataSource = @[@"制作朋友圈",@"制作消息",@"使用说明",@"反馈"];
    NSArray *iconName = @[@"朋友圈",@"消息",@"说明",@"反馈"];

    for (NSInteger i = 0; i < dataSource.count; i++) {
        QMUIButton *btn = [[QMUIButton alloc] init];
        btn.tag = i;
        btn.titleLabel.font = UIFontMake(14);
        btn.imagePosition = QMUIButtonImagePositionTop;// 将图片位置改为在文字上方
        btn.spacingBetweenImageAndTitle = 10;
        [btn setBackgroundColor:UIColorWhite];
        UIImage *icon = UIImageMake(iconName[i]);
        [btn setImage:icon forState:UIControlStateNormal];
        [btn setTitle:dataSource[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorMakeX(61) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickMenuAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.gridView addSubview:btn];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bannerView = [[GADBannerView alloc] init];
    self.bannerView.adUnitID = @"ca-app-pub-6037095993957840/9771733149";
    self.bannerView.rootViewController = self;
//    self.bannerView.backgroundColor = UIColorRandom;
    [self.view addSubview:self.bannerView];

    @weakify(self)
    dispatch_queue_t queue = dispatch_queue_create("kk", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        @strongify(self)
        [self addTestRealm];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    GADRequest *request = [GADRequest request];
    request.testDevices = @[kGADSimulatorID];
    self.bannerView.delegate = self;
    [self.bannerView loadRequest:request];
}

- (void)clickMenuAction:(QMUIButton *)sender {
    switch (sender.tag) {
            case 0: {
                SWStatusViewController *controller = [[SWStatusViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
            break;
            
            case 1: {
                SWMessageViewController *controller = [[SWMessageViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
            break;
            case 2: {
                // 使用说明
                SWInstructionsViewController *controller = [[SWInstructionsViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
            break;

            case 3:{
                SWFeedbackViewController *controller = [[SWFeedbackViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
            break;
        default:
            break;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.gridView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, CGRectGetWidth(self.view.bounds), QMUIViewSelfSizingHeight);
    
    self.bannerView.frame = CGRectMake(0, self.view.qmui_height - 50, self.view.qmui_width, 50);
}



- (BOOL)shouldCustomNavigationBarTransitionWhenPushDisappearing {
    return YES;
}

- (BOOL)shouldCustomNavigationBarTransitionWhenPopDisappearing {
    return YES;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"adView:didSuccess");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}

- (void)addTestRealm {
    NSInteger launch = [[NSUserDefaults standardUserDefaults] integerForKey:kLaunch];
    NSLog(@"launch:%zi",launch);
    if (launch < 2) {
        return;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *allAuthor = [SWAuthor allObjects];
    if (allAuthor.count == 0) {
        NSArray *nicknames = @[@"煎饼侠",@"萌萌",@"皮卡丘",@"凹凸曼",@"拉克丝",@"小鑫鑫",@"琪琪",@"喵",@"Laurinda",@"阿狸",@"Fiona",@"Lee",@"雅彤",@"璐璐",@"SuperMan",@"可儿",@"雅静",@"Jennifer",@"路飞",@"达孟",@"蛋儿",@"茉莉",@"小薇",@"小翔",@"Adele",@"李菲菲",@"haha",@"ZZ",@"Lacey",@"星爷",@"Selena",@"周归璨",@"Wendy",@"Queenie",@"Lana",@"阿颖"];
        [realm beginWriteTransaction];
        for (int i = 0; i < nicknames.count; i ++) {
            SWAuthor *author = [[SWAuthor alloc] init];
            author.nickname = nicknames[i];
            NSString *imageName = [NSString stringWithFormat:@"avatar%d.jpg",i];
            author.avatar = [SWStatus saveImage:[UIImage imageNamed:imageName]];
            [realm addObject:author];
        }
        [realm commitWriteTransaction];
    }
    
    RLMResults<SWStatus *> *allStatus = [SWStatus allObjects];
    if (allStatus.count <= 0) {
        NSArray *nicknames = @[@"爱范儿呀",@"可儿",@"煎饼侠",@"Jennifer",@"开心鸭"];
        NSArray *avatars = @[UIImageMake(@"avatar29.jpg"),UIImageMake(@"avatar10.jpg"),UIImageMake(@"avatar32.jpg"),UIImageMake(@"avatar35.jpg"),UIImageMake(@"avatar2.jpg")];
        NSArray *contents = @[@"",@"",@"Zepp DiverCity",@"今日の東京。",@"每一天都很快乐!!!"];
        NSArray *times = @[@"1天前",@"1天前",@"2小时前",@"10分钟前",@"1分钟前"];
        [realm beginWriteTransaction];
        for (int i = 0; i < nicknames.count; i ++) {
            SWStatus *status = [[SWStatus alloc] init];
            status.id = i;
            status.avator = [SWStatus saveImage:avatars[i]];
            status.nickname = nicknames[i];
            status.content = contents[i];
            status.createdTime = times[i];
            if (i == 0) {
                status.webSiteDesc = @"索尼推出 PS1 迷你复刻主机，你准备好剁手了吗";
                status.type = 2;
            } else if (i == 1) {
                UIImage *image = [UIImage imageNamed:@"WechatIMG5.jpeg"];
                status.images = [@[[SWStatus saveImage:image]] mj_JSONString];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                status.type = 1;
            } else if (i == 2) {
                UIImage *image = [UIImage imageNamed:@"WechatIMG6.jpeg"];
                status.images = [@[[SWStatus saveImage:image]] mj_JSONString];
                
            } else if (i == 3) {
                NSMutableArray *imageNames = [NSMutableArray arrayWithCapacity:9];
                for (int z = 0; z < 9; z ++) {
                    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"tokyo%d.jpg",z]];
                    [imageNames addObject:[SWStatus saveImage:image]];
                }
                status.images = [imageNames mj_JSONString];
                status.location = @"日本·东京";
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                SWStatusComment *comment1 = [[SWStatusComment alloc] init];
                comment1.fromAuthor = status.likes[0];
                comment1.comment = @"Beautiful!!!";
                [status.comments addObject:comment1];
                SWStatusComment *comment2 = [[SWStatusComment alloc] init];
                comment2.fromAuthor = status.likes[3];
                comment2.toAuthor = status.likes[0];
                comment2.comment = @"thanks...";
                [status.comments addObject:comment2];
                
            } else if (i == 4) {
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                [status.likes addObject:[allAuthor objectAtIndex:arc4random() % allAuthor.count]];
                SWStatusComment *comment1 = [[SWStatusComment alloc] init];
                comment1.fromAuthor = [status.likes lastObject];
                comment1.comment = @"赞";
                [status.comments addObject:comment1];
            }
            [realm addObject:status];
        }
        [realm commitWriteTransaction];
    }
}


@end
