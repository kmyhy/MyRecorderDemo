//
//  WaveView.m
//
//  Created by qq on 2017/4/28.
//  Copyright © 2017年 qq. All rights reserved.
//

#import "WaveView.h"

@implementation WaveView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setup];
    }
    return self;
}
-(void)setup{
    swing = CGRectGetHeight(self.frame);
    length = CGRectGetWidth(self.frame);
    _strokeWidth = 1;///([UIScreen mainScreen].scale);
    _strokeColor = [UIColor blackColor];
    _isCurveDraw = YES;

    self.backgroundColor= [UIColor clearColor];
}
- (void)drawValues:(NSArray<NSNumber*>*)values
{
    if(values.count>0){
        if(values.count>1){
            length = CGRectGetMaxX(self.frame)/(values.count-1);
        }
        _values = values;
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    NSLog(@"%f",swing);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, _strokeColor.CGColor);
    CGContextSetLineWidth(context, _strokeWidth);


    NSArray<NSValue*>* points = [self pointsForValues];
    
    for(int i = 0;i<points.count;i++){
        
        CGPoint point= points[i].CGPointValue;
        
        if(i==0){
            CGContextMoveToPoint(context, point.x, point.y);
        }else{
            if(_isCurveDraw==NO){
                CGContextAddLineToPoint(context, point.x, point.y);
            }else{
                [self addCurveFrom:i-1 to:i points:points context:context];
            }
        }
    }
    CGContextStrokePath(context);
}
// 为 values 数组中的每个值分配要绘制的点的 x,y 坐标
-(NSArray<NSValue*>*)pointsForValues{
    
    NSMutableArray<NSValue*>* points=[NSMutableArray new];
    double midy=CGRectGetMidY(self.bounds);
    
    for(int i= 0;i<_values.count;i++){
        double value = _values[i].doubleValue;
        
        double x = length*i;
        double y = value * swing * 0.5;
        
        CGPoint point = CGPointMake(x, midy+y);
        CGPoint mirrorPoint = CGPointMake(x+length*0.5, midy-y);
        
        [points addObject:[NSValue valueWithCGPoint:point]];
        [points addObject:[NSValue valueWithCGPoint:mirrorPoint]];
    }
    return points;
    
}
-(void)addCurveFrom:(NSInteger)from to:(NSInteger)to points:(NSArray<NSValue*>*)points context:(CGContextRef)context{
    if(from<1 || to>=points.count-1){
        return;
    }
    CGPoint frontPoint = points[from-1].CGPointValue;
    
    CGPoint point = points[from].CGPointValue;
    
    CGPoint endpoint = points[to].CGPointValue;
    
    CGPoint afterPoint = points[to+1].CGPointValue;
    
    CGPoint p1,p2;// 控制点
    
    if(from==0){
        p1 = CGPointMake(point.x+(endpoint.x-point.x)/4, point.y+(endpoint.y-point.y)/4);
        p2 = CGPointMake(endpoint.x-(afterPoint.x-point.x)/4, endpoint.y-(afterPoint.y-point.y)/4);
    }else if(to==points.count-1){
        p1 = CGPointMake(point.x+(endpoint.x-frontPoint.x)/4, point.y+(endpoint.y-frontPoint.y)/4);
        p2 = CGPointMake(endpoint.x-(endpoint.x-point.x)/4, endpoint.y-(endpoint.y-point.y)/4);
    }else{
        p1 = CGPointMake(point.x+(endpoint.x-frontPoint.x)/4, point.y+(endpoint.y-frontPoint.y)/4);
        p2 = CGPointMake(endpoint.x-(afterPoint.x-point.x)/4, endpoint.y-(afterPoint.y-point.y)/4);
    }
    
    CGContextAddCurveToPoint(context, p1.x,p1.y, p2.x, p2.y, endpoint.x, endpoint.y);
    
}
@end





