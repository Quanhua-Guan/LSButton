//
//  ViewController.m
//  LSButton
//
//  Created by Yang on 2015/01/16.
//  Copyright (c) 2015年 Yang. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];    
}

-(void)viewDidLayoutSubviews
{
    if (!buttonFromCode)
    {
        buttonFromCode = [LSButton buttonWithFrame:CGRectOffset(button.frame, 0, -button.frame.size.height - 10) icon:[UIImage imageNamed:@"icon"] buttonColor:[UIColor grayColor] titleShadowColor:[UIColor blackColor] tintColor:[UIColor whiteColor] radius:20 titleShadowAngel:45 target:nil action:nil];
        [self.view addSubview:buttonFromCode];
    }
    [button setTitleColor:[UIColor colorWithRed:0.986 green:0.000 blue:0.173 alpha:0.510] forState:UIControlStateHighlighted];
}

- (IBAction)valueDidChanged:(UISlider *)sender
{
    button.titleShadowAngel = sender.value;
    [button setNeedsDisplay];
    
    buttonFromCode.titleShadowAngel = sender.value;
}

- (IBAction)backgroundColorValueDidChanged:(UISlider *)sender
{
    UIColor *bgColor = button.backgroundColor;
    CGFloat r, g, b, a, realR = sender.value;
    //
    [bgColor getRed:&r green:&g blue:&b alpha:&a];
    UIColor *color =[UIColor colorWithRed:realR green:g blue:b alpha:a];
    button.backgroundColor = color;
}

- (IBAction)titleColorValueDidChanged2:(UISlider *)sender
{
    UIColor *titleColor = button.currentTitleColor;
    CGFloat r, g, b, a, realR = sender.value;
    //
    [titleColor getRed:&r green:&g blue:&b alpha:&a];
    UIColor *color =[UIColor colorWithRed:realR green:g blue:b alpha:a];
    [button setTitleColor:color forState:UIControlStateNormal];
}

- (IBAction)titleShadowColorValueDidChanged:(UISlider *)sender
{
    UIColor *titleShadowColor = button.currentTitleShadowColor;
    CGFloat r, g, b, a, realR = sender.value;
    //
    [titleShadowColor getRed:&r green:&g blue:&b alpha:&a];
    UIColor *color =[UIColor colorWithRed:realR green:g blue:b alpha:a];
    [button setTitleShadowColor:color forState:UIControlStateNormal];
}

- (IBAction)titleShadowLengthValueDidChanged:(UISlider *)sender {
    buttonFromCode.titleShadowLength =
    button.titleShadowLength = sender.value;
}

@end
