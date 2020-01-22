//
//  RWViewController.m
//  RWReactivePlayground
//
//  Created by Colin Eberhardt on 18/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "RWDummySignInService.h"
#import "RWViewController.h"

@interface RWViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureText;

@property (nonatomic) BOOL passwordIsValid;
@property (nonatomic) BOOL usernameIsValid;
@property (strong, nonatomic) RWDummySignInService *signInService;

@property (strong, nonatomic) RACSignal *validUsernameSignal;
@property (strong, nonatomic) RACSignal *validPasswordSignal;
@property (strong, nonatomic) RACSignal *signInServiceSignal;

@end

@implementation RWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signInService = [[RWDummySignInService alloc] init];
    
    /* username.rac_textSignal->map[信号NSString类型转换]->Boolean->map[信号Boolean类型转换]->UIColor类型->backgroundColor
                                                        ▽
                                                combineLatest[信号组合]->Boolean->enabled
                                                        △
     password.rac_textSignal->map[信号NSString类型转换]->Boolean->map[信号Boolean类型转换]->UIColor类型->backgroundColor
     */
    
    @weakify(self);
    _validUsernameSignal = [_usernameTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        @strongify(self);
        return @([self isValidUsername:value]);
    }];
    
    _validPasswordSignal = [_passwordTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        @strongify(self);
        return @([self isValidPassword:value]);
    }];
    
    RAC(_signInButton, enabled) = [RACSignal combineLatest:@[_validUsernameSignal, _validPasswordSignal] reduce:^id (NSNumber *userNameValid, NSNumber *passwordValid){
        return @(userNameValid.boolValue && passwordValid.boolValue);
    }];
    
    RAC(_usernameTextField, backgroundColor) = [_validUsernameSignal map:^id _Nullable(NSNumber * _Nullable value) {
        return value.boolValue ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    RAC(_passwordTextField, backgroundColor) = [_validPasswordSignal map:^id _Nullable(NSNumber * _Nullable value) {
        return value.boolValue ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    [_signInService.additionalCommand.executionSignals.switchToLatest subscribeNext:^(NSNumber * _Nullable loginState) {
        @strongify(self);
        switch (loginState.integerValue) {
            case Logining:
                [UIApplication.sharedApplication.keyWindow endEditing:YES];
                self.signInButton.enabled = NO;
                self.signInFailureText.hidden = YES;
                break;
            case LoginFail:
                self.signInButton.enabled = YES;
                self.signInFailureText.hidden = NO;
                [self.usernameTextField becomeFirstResponder];
                break;
            case LoginFinish:
                self.signInButton.enabled = YES;
                break;
            default:
                break;
        }
    }];
    
    /*
     UIControl事件信号->flattenMap[信号转换]->ServiceSingal->subscribeNext
                            ▽
                        RACCommand[命令事件]->RACSignal[已注册在命令中的信号]->
     */
    [[[_signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACSignal * _Nullable(__kindof UIControl * _Nullable value) {
        @strongify(self);
        return [self.signInService signInWithSingal:self.usernameTextField.text password:self.passwordTextField.text];
    }] subscribeNext:^(NSNumber * _Nullable state) {
        if (state.integerValue == LoginFinish) {
            [CentreMediator.shareCentreMediator CM_PushRWSearchViewController];
        }
    }];
}

- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 3;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return ![string containsString:@" "];
}

@end

