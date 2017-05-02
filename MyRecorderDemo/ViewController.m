//
//  ViewController.m
//  MyRecorderDemo
//
//  Created by qq on 2017/4/24.
//  Copyright © 2017年 qq. All rights reserved.
//

#import "ViewController.h"

#import "NSTimer+Pause.h"
#import "WaveView.h"
#import "MyRecorder.h"

int static maxNumbers = 10;

@interface ViewController ()<MyRecorderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIButton *btnPreview;
@property (weak, nonatomic) IBOutlet UIButton *btnRedo;
@property (weak, nonatomic) IBOutlet UIButton *btnBegin;
@property (weak, nonatomic) IBOutlet UILabel *lbMessage;
@property (weak, nonatomic) IBOutlet WaveView *waveView;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIProgressView *pvMeter;
@property (strong,nonatomic) MyRecorder* recorder;
@property(strong,nonatomic)NSMutableArray<NSNumber*>* meters;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recorder= [MyRecorder sharedInstance];
    _recorder.delegate= self;
    _recorder.state= MyRecorderStateIsReady;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// MARK: - Actions
- (IBAction)previewAction:(id)sender {
    [_recorder playTest];
}

- (IBAction)redoAction:(id)sender {
    [self.recorder redoRecord];
    
}
- (IBAction)recordAction:(id)sender {
    switch(self.recorder.state){
        case MyRecorderStateIsReady:
            [self.recorder beginOrResumeRecord];
            break;
        case MyRecorderStatePaused:
            [self.recorder beginOrResumeRecord];
            break;
        case MyRecorderStateRecording:
            [self.recorder pauseRecord];
        default:
            break;
    }
}
- (IBAction)saveAction:(id)sender {
//    [self stopRecord];
    NSLog(@"%@",_recorder.recordFilePath);
}
// MARK: - Private
//规范时间格式
- (NSString *)convertTimeToString:(NSInteger)second {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    NSDate *date = [formatter dateFromString:@"00:00"];
    date = [date dateByAddingTimeInterval:second];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}


#pragma mark - MyRecorderDelegate
-(void)recorderGetPermissionFailed:(MyRecorder *)recorder{
    // 用户不同意获取麦克风
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"麦克风不可用" message:@"请在“设置 - 隐私 - 麦克风”中允许数字红卡访问你的麦克风" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //如果要让用户直接跳转到设置界面，则可以进行下面的操作，如不需要，就忽略下面的代码
        /*
         *iOS10 开始苹果禁止应用直接跳转到系统单个设置页面，只能跳转到应用所有设置页面
         *iOS10以下可以添加单个设置的系统路径，并在info里添加URL Type，将URL schemes 设置路径为prefs即可。
         *@"prefs:root=Sounds"
         */
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    
    [alertController addAction:openAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)recorder:(MyRecorder *)recorder stateChanged:(MyRecorderState)state{
    switch (state) {
        case MyRecorderStateIsReady:
            
            [_btnBegin setTitle:@"开始录制" forState:UIControlStateNormal];
            _lbMessage.text = @"点击开始录音，最长录制3分钟哦~";
            _btnSave.hidden =_btnRedo.hidden = _btnPreview.hidden = YES;
            break;
        case MyRecorderStatePaused:
            [_btnBegin setTitle:@"继续录制" forState:UIControlStateNormal];
            _lbMessage.text = @"";
            
            _btnSave.hidden =_btnRedo.hidden = _btnPreview.hidden = NO;
            break;
        case MyRecorderStateRecording:
            [_btnBegin setTitle:@"暂停录制" forState:UIControlStateNormal];
            _lbMessage.text = @"正在录制...";
            _btnSave.hidden =_btnRedo.hidden = _btnPreview.hidden = YES;
            
            break;
        default:
            break;
    }
}
-(void)recorder:(MyRecorder *)recorder secondChanged:(NSInteger)second{
    if(second == 0){
        _lbTime.text = @"00:00";
    }else{
        _lbTime.text = [self convertTimeToString:second];
    }
}
-(void)recorder:(MyRecorder *)recorder powerChanged:(double)power{
    if(_meters == nil){
        _meters = [NSMutableArray<NSNumber*> new];
        
        for(int i =0;i<=maxNumbers;i++){
            [_meters addObject:@(0)];
        }
    }
    if(_meters.count >= maxNumbers){
        [_meters removeObjectAtIndex:0];
    }
    [_meters addObject:@(power)];

    [_waveView drawValues:_meters];
}
@end
