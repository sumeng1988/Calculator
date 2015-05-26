//
//  ExpressionUtils.m
//  Calc
//
//  Created by sumeng on 15/5/14.
//  Copyright (c) 2015年 sumeng. All rights reserved.
//

#import "ExpressionUtils.h"
#import "Stack.h"

@implementation ExpressionUtils

+ (NSDecimalNumber *)calcFromExpression:(NSString *)expression {
    return [self calePostfix:[self postfixFromInfix:[self infixFromExpression:expression]]];
}

+ (NSDecimalNumber *)calcFromInfix:(Queue *)infix {
    return [self calePostfix:[self postfixFromInfix:infix]];
}

//expression to infix
+ (Queue *)infixFromExpression:(NSString *)expression {
    Queue *infix = [[Queue alloc] init];
    NSString *num = @"";
    BOOL isNum = NO;
    for (int i = 0; i < expression.length; i++) {
        NSString *str = [expression substringWithRange:NSMakeRange(i, 1)];
        unichar ch = [expression characterAtIndex:i];
        if ([self isNumber:ch]) {
            isNum = YES;
            num = [num stringByAppendingString:str];
        }
        else if ([self isOperator:ch]) {
            if (isNum) {
                isNum = NO;
                [infix push:[NSDecimalNumber decimalNumberWithString:num]];
                num = @"";
            }
            [infix push:str];
        }
        else {
            return nil;
        }
    }
    if (num.length > 0) {
        [infix push:[NSDecimalNumber decimalNumberWithString:num]];
    }
    return infix;
}

//infix to postfix
+ (Queue *)postfixFromInfix:(Queue *)infix {
    if (infix == nil) {
        return nil;
    }
    Queue *postfix = [[Queue alloc] init];
    Stack *stack = [[Stack alloc] init];
    while (![infix empty]) {
        id obj = [infix front];
        if ([obj isKindOfClass:[NSDecimalNumber class]]) {
            [postfix push:obj];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            NSString *operator = obj;
            if (operator.length > 0) {
                unichar ch = [operator characterAtIndex:0];
                if ([self isOperator:ch]) {
                    if (ch == '(') {
                        [stack push:operator];
                    }
                    else if (ch == ')') {
                        while (!([stack empty] || [@"(" isEqualToString:[stack top]])) {
                            [postfix push:[stack top]];
                            [stack pop];
                        }
                        if ([@"(" isEqualToString:[stack top]]) {
                            [stack pop];
                        }
                        else {
                            //parentheses are not matching
                            NSLog(@"postfixFromInfix() parentheses are not matching");
                            return nil;
                        }
                    }
                    else {
                        NSInteger topPriority = 0;
                        NSString *topStr = [stack empty] ? nil : [stack top];
                        if (topStr.length > 0) {
                            unichar topCh = [topStr characterAtIndex:0];
                            topPriority = [self priorityOfOperator:topCh];
                        }
                        while (!([stack empty] || topPriority < [self priorityOfOperator:ch]))
                        {
                            [postfix push:[stack top]];
                            [stack pop];
                            
                            topPriority = 0;
                            NSString *topStr = [stack empty] ? nil : [stack top];
                            if (topStr.length > 0) {
                                unichar topCh = [topStr characterAtIndex:0];
                                topPriority = [self priorityOfOperator:topCh];
                            }
                        }
                        [stack push:operator];
                    }
                }
            }
        }
        else {
            //illegal element
            NSLog(@"postfixFromInfix() illegal element");
            return nil;
        }
        [infix pop];
    }
    while (![stack empty]) {
        [postfix push:[stack top]];
        [stack pop];
    }
    return postfix;
}

//calc postfix
+ (NSDecimalNumber *)calePostfix:(Queue *)postfix {
    if (postfix == nil) {
        return nil;
    }
    Stack *stack = [[Stack alloc] init];
    while (![postfix empty]) {
        id obj = [postfix front];
        if ([obj isKindOfClass:[NSDecimalNumber class]]) {
            [stack push:obj];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            NSString *operator = obj;
            if (operator.length > 0) {
                unichar ch = [operator characterAtIndex:0];
                
                if ([stack size] < 2) {
                    //illegal postfix
                    NSLog(@"calePostfix() illegal postfix");
                    return nil;
                }
                NSDecimalNumber *num1 = [stack top];
                [stack pop];
                NSDecimalNumber *num2 = [stack top];
                [stack pop];
                
                switch (ch) {
                    case '*':
                        [stack push:[num2 decimalNumberByMultiplyingBy:num1]];
                        break;
                    case '/':
                        if ([num1 compare:@0] == NSOrderedSame) {
                            //divide by zero
                            return nil;
                        }
                        [stack push:[num2 decimalNumberByDividingBy:num1]];
                        break;
                    case '+':
                        [stack push:[num2 decimalNumberByAdding:num1]];
                        break;
                    case '-':
                        [stack push:[num2 decimalNumberBySubtracting:num1]];
                        break;
                    default:
                        //unknown operator
                        NSLog(@"calePostfix() unknown operator");
                        return nil;
                }
            }
        }
        else {
            //illegal element
            NSLog(@"calePostfix() illegal element");
            return nil;
        }
        [postfix pop];
    }
    return [[stack top] isKindOfClass:[NSDecimalNumber class]] ? [stack top] : nil;
}

+ (NSInteger)priorityOfOperator:(unichar)ch {
    switch (ch) {
        case '*':
        case '/':
            return 2;
        case '+':
        case '-':
            return 1;
        default:
            return 0;
    }
}

+ (BOOL)isNumber:(unichar)ch {
    return (ch >= '0' && ch <= '9') || ch == '.';
}

+ (BOOL)isOperator:(unichar)ch {
    switch (ch) {
        case '*':
        case '/':
        case '+':
        case '-':
        case '(':
        case ')':
            return YES;
        default:
            return NO;
    }
}

@end
