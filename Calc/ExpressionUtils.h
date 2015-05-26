//
//  ExpressionUtils.h
//  Calc
//
//  Created by sumeng on 15/5/14.
//  Copyright (c) 2015年 sumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Queue.h"

@interface ExpressionUtils : NSObject

+ (NSDecimalNumber *)calcFromExpression:(NSString *)expression;
+ (NSDecimalNumber *)calcFromInfix:(Queue *)infix;

@end
