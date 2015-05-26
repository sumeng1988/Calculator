//
//  ViewController.m
//  Calc
//
//  Created by sumeng on 15/5/14.
//  Copyright (c) 2015年 sumeng. All rights reserved.
//

#import "ViewController.h"
#import "ExpressionUtils.h"

typedef enum _CalcBtnType {
    CalcBtnType0 = 0,
    CalcBtnType1,
    CalcBtnType2,
    CalcBtnType3,
    CalcBtnType4,
    CalcBtnType5,
    CalcBtnType6,
    CalcBtnType7,
    CalcBtnType8,
    CalcBtnType9,
    CalcBtnTypeDot,
    CalcBtnTypeAC,
    CalcBtnTypeParentheseLeft,
    CalcBtnTypeParentheseRight,
    CalcBtnTypeAdd,
    CalcBtnTypeSubtracte,
    CalcBtnTypeMultiplay,
    CalcBtnTypeDivide,
    CalcBtnTypeEqual
}CalcBtnType;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resultLbl;
@property (nonatomic, assign) BOOL isResult;

- (IBAction)onBtnClicked:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeGr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeGr.direction = UISwipeGestureRecognizerDirectionRight;
    _resultLbl.userInteractionEnabled = YES;
    [_resultLbl addGestureRecognizer:swipeGr];
    
    [self reset];
}

- (IBAction)onBtnClicked:(id)sender {
    UIButton *button = sender;
    CalcBtnType type = (CalcBtnType)button.tag;
    switch (type) {
        case CalcBtnType0:
        case CalcBtnType1:
        case CalcBtnType2:
        case CalcBtnType3:
        case CalcBtnType4:
        case CalcBtnType5:
        case CalcBtnType6:
        case CalcBtnType7:
        case CalcBtnType8:
        case CalcBtnType9:
        case CalcBtnTypeDot:
            [self onNumClicked:type];
            break;
        case CalcBtnTypeAC:
            [self reset];
            break;
        case CalcBtnTypeParentheseLeft:
        case CalcBtnTypeParentheseRight:
            [self onParentheseClicked:type];
            break;
        case CalcBtnTypeAdd:
        case CalcBtnTypeSubtracte:
        case CalcBtnTypeMultiplay:
        case CalcBtnTypeDivide:
            [self onOperatorClicked:type];
            break;
        case CalcBtnTypeEqual:
            [self onEqualClicked:type];
            break;
        default:
            break;
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        if (_isResult || _resultLbl.text.length <= 1) {
            [self reset];
        }
        else {
            _resultLbl.text = [_resultLbl.text substringToIndex:_resultLbl.text.length - 1];
        }
    }
}

- (void)onNumClicked:(CalcBtnType)type {
    if (_isResult) {
        [self reset];
    }
    
    NSString *lastOperation = [self lastOperation:_resultLbl.text];
    NSString *typeStr = [self strByType:type];
    if ([self isNum:lastOperation]) {
        if (type == CalcBtnTypeDot) {
            if ([lastOperation rangeOfString:typeStr].length == 0) {
                _resultLbl.text = [_resultLbl.text stringByAppendingString:typeStr];
            }
        }
        else {
            if ([lastOperation floatValue] == 0) {
                _resultLbl.text = [_resultLbl.text substringToIndex:_resultLbl.text.length - 1];
            }
            _resultLbl.text = [_resultLbl.text stringByAppendingString:typeStr];
        }
    }
    else {
        _resultLbl.text = [_resultLbl.text stringByAppendingString:typeStr];
    }
}

- (void)onOperatorClicked:(CalcBtnType)type {
    if (_isResult) {
        if ([self isNum:_resultLbl.text]) {
            _isResult = NO;
        }
        else {
            [self reset];
        }
    }
    
    NSString *lastOperation = [self lastOperation:_resultLbl.text];
    NSString *typeStr = [self strByType:type];
    if ([self isOperator:lastOperation]) {
        _resultLbl.text = [_resultLbl.text substringToIndex:_resultLbl.text.length - 1];
    }
    _resultLbl.text = [_resultLbl.text stringByAppendingString:typeStr];
}

- (void)onParentheseClicked:(CalcBtnType)type {
    if (_isResult) {
        if ([self isNum:_resultLbl.text]) {
            _isResult = NO;
        }
        else {
            [self reset];
        }
    }
    
    NSString *typeStr = [self strByType:type];
    if (type == CalcBtnTypeParentheseLeft && [_resultLbl.text isEqualToString:@"0"]) {
        _resultLbl.text = @"(";
    }
    else {
        _resultLbl.text = [_resultLbl.text stringByAppendingString:typeStr];
    }
}

- (void)onEqualClicked:(CalcBtnType)type {
    if (_isResult) {
        return;
    }
    NSDecimalNumber *num = [ExpressionUtils calcFromExpression:_resultLbl.text];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:8];
    [formatter setMinimumFractionDigits:0];
    if (num) {
        _resultLbl.text = [formatter stringFromNumber:num];
    }
    else {
        _resultLbl.text = @"ERROR";
    }
    _isResult = YES;
}

- (BOOL)isNum:(NSString *)operation {
    return ([@"0" isEqualToString:operation]
            || [@"." isEqualToString:operation]
            || [operation floatValue] != 0);
}

- (BOOL)isParenthese:(NSString *)operation {
    return [@"(" isEqualToString:operation] || [@")" isEqualToString:operation];
}

- (BOOL)isOperator:(NSString *)operation {
    return ([@"+" isEqualToString:operation]
            || [@"-" isEqualToString:operation]
            || [@"*" isEqualToString:operation]
            || [@"/" isEqualToString:operation]);
}

- (NSString *)lastOperation:(NSString *)expresstion {
    NSString *operation = @"";
    for (int i = 0; i < expresstion.length; i++) {
        NSString *str = [expresstion substringWithRange:NSMakeRange(expresstion.length - i - 1, 1)];
        if ([self isNum:str]) {
            operation = [str stringByAppendingString:operation];
        }
        else {
            if (i == 0) {
                operation = str;
            }
            break;
        }
    }
    return operation;
}

- (NSString *)strByType:(CalcBtnType)type {
    switch (type) {
        case CalcBtnType0:
        case CalcBtnType1:
        case CalcBtnType2:
        case CalcBtnType3:
        case CalcBtnType4:
        case CalcBtnType5:
        case CalcBtnType6:
        case CalcBtnType7:
        case CalcBtnType8:
        case CalcBtnType9:
            return [NSString stringWithFormat:@"%d", type];
        case CalcBtnTypeDot:
            return @".";
        case CalcBtnTypeParentheseLeft:
            return @"(";
        case CalcBtnTypeParentheseRight:
            return @")";
        case CalcBtnTypeAdd:
            return @"+";
        case CalcBtnTypeSubtracte:
            return @"-";
        case CalcBtnTypeMultiplay:
            return @"*";
        case CalcBtnTypeDivide:
            return @"/";
        default:
            return @"";
    }
}

- (void)reset {
    _isResult = NO;
    _resultLbl.text = @"0";
}

@end
