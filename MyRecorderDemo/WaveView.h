//
//  WaveView.h
//
//  Created by qq on 2017/4/28.
//  Copyright © 2017年 qq. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface WaveView : UIView
{
    float swing;// 振幅
    float length;// 波长
    NSArray<NSNumber*>* _values;// 要绘制的点
}
@property(assign,nonatomic)IBInspectable double strokeWidth;
@property(assign,nonatomic)IBInspectable UIColor* strokeColor;
@property(assign,nonatomic)IBInspectable BOOL isCurveDraw;// 是绘制折线，还是三次bezier曲线
- (void)drawValues:(NSArray<NSNumber*>*)values;

@end
