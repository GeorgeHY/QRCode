//
//  ViewController.m
//  QRCodeTest
//
//  Created by 韩扬 on 2017/4/10.
//  Copyright © 2017年 HanYang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>

{
    AVCaptureSession * session;
    AVCaptureVideoPreviewLayer * layer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addQRBtn];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)addQRBtn{
    UIButton * zhBtn = [UIButton buttonWithType:0];
    zhBtn.frame = CGRectMake(75, 100, self.view.bounds.size.width - 150, 60);
    [zhBtn setTitle:@"点我进行二维码扫描" forState:0];
    [zhBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    zhBtn.backgroundColor = [UIColor grayColor];
    [self.view addSubview:zhBtn];
}

- (void)btnClick{
    NSLog(@"点击二维码按钮");
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    NSError * error = nil;
    if (input) {
        //设置会话的输入设备
        [session addInput:input];
    }else{
        NSLog(@"error --- %@",[error localizedDescription]);
    }
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    [session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //设置相机扫描框的大小
    layer.frame = CGRectMake(50, 170, 200, 200);
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [session startRunning];
    
    
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"扫描输出");
    NSString * zhQRCode = nil;
    for (AVMetadataObject * metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            zhQRCode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            break;
        }
    }
    NSLog(@"QR Code----%@", zhQRCode);
    [session stopRunning];
    //结束捕获，如果不结束，就会反复调用此回调方法
}
@end
