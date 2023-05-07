//
//  TextViewController.m
//  AgoraSTT_XF
//
//  Created by FanPengpeng on 2022/4/1.
//

#import "STTTxtViewController.h"

@interface STTTxtViewController ()

@end

@implementation STTTxtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *text = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
    UITextView *txtView = [[UITextView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:txtView];
    txtView.editable = false;
    txtView.text = text;
}


@end
