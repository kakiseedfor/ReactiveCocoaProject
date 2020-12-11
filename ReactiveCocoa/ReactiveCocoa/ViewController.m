//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by kakiYen on 2020/1/21.
//  Copyright © 2020 kakiYen. All rights reserved.
//

#import "ViewController.h"

@interface RWThread : NSThread{
    NSMutableArray<NSOperation *> *operationArray;
    CFRunLoopSourceRef sourceRef;
    CFRunLoopTimerRef timerRef;
    CFRunLoopRef runLoopRef;
    RWThread *selfThread;
    NSLock *threadLock;
    BOOL executed;
}

@end

static void RWPerform(void *info);
@implementation RWThread

- (void)dealloc
{
    executed = NO;
    selfThread = nil;
    CFRunLoopTimerInvalidate(timerRef);
    CFRunLoopSourceInvalidate(sourceRef);
    CFRetain(timerRef);
    CFRelease(sourceRef);
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        operationArray = [NSMutableArray arrayWithCapacity:3];
        threadLock = [[NSLock alloc] init];
        selfThread = self;
        [self addRunLoopSource];
        [self addRunLoopTimer];
        [self start];
    }
    return self;
}

- (void)addRunLoopSource{
    CFRunLoopSourceContext sourceContext = {
        0,
        (__bridge void *)self,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        &RWPerform,
    };
    sourceRef = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext);
}

- (void)addRunLoopTimer{
    __weak typeof(self) weakSelf = self;
    timerRef = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + 3, 3, 0, 0, ^(CFRunLoopTimerRef timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->threadLock lock];
        if (strongSelf->operationArray.count) {
            [strongSelf->threadLock unlock];
            return;
        }
        
        strongSelf->executed = NO;
        strongSelf->selfThread = nil;
        CFRunLoopStop(strongSelf->runLoopRef);
        [strongSelf->threadLock unlock];
    });
}

- (BOOL)isFinished{
    [threadLock lock];
    BOOL should = super.isFinished;
    [threadLock unlock];
    return should;
}

- (void)perform{
    [threadLock lock];
    if (!operationArray.count) {
        [threadLock unlock];
        return;
    }
    
    [operationArray.lastObject start];
    [operationArray removeLastObject];
    
    if (operationArray.count) {
        CFRunLoopSourceSignal(sourceRef);
        CFRunLoopWakeUp(runLoopRef);
    }
    [threadLock unlock];
}

- (void)main{
    runLoopRef = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoopRef, sourceRef, kCFRunLoopCommonModes);
    CFRunLoopAddTimer(runLoopRef, timerRef, kCFRunLoopCommonModes);
    CFRunLoopSourceSignal(sourceRef);
    CFRunLoopWakeUp(runLoopRef);
    executed = YES;
    CFRunLoopRun();
}

- (void)addOperation:(NSOperation *)operation{
    [threadLock lock];
    if ([operationArray containsObject:operation]) {
        [threadLock unlock];
        return;
    }
    [operationArray addObject:operation];
    
    if (executed) {
        CFRunLoopSourceSignal(sourceRef);
        CFRunLoopWakeUp(runLoopRef);
    }
    [threadLock unlock];
}

+ (void)addOperation:(NSOperation *)operation{
    if (operation.isAsynchronous) {
        [RWThread.createInstance addOperation:operation];
    }else{
        [RWThread.shareInstance addOperation:operation];
    }
}

+ (instancetype)createInstance{
    RWThread *tempThread = [[RWThread alloc] init];
    return tempThread;
}

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    __weak static RWThread *thread = nil;
    if (!thread || thread.isFinished) {
        onceToken = 0;
    }
    dispatch_once(&onceToken, ^{
        RWThread *tempThread = [[RWThread alloc] init];
        thread = tempThread;
    });
    return thread;
}

@end

static void RWPerform(void *info){
    RWThread *tempThread = (__bridge RWThread *)info;
    [tempThread perform];
}

@interface CustomerOperation : NSOperation
@property(nonatomic) BOOL shouldReady;
@property(nonatomic) BOOL shouldFinished;
@property(nonatomic) BOOL shouldExecuting;
@property(nonatomic, copy) void(^executeBlock)(void);

@end

@implementation CustomerOperation

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isReady" context:NULL];
    [self removeObserver:self forKeyPath:@"isFinished" context:NULL];
    [self removeObserver:self forKeyPath:@"isExecuting" context:NULL];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldReady = self.isReady;
        __weak typeof(self) weakSelf = self;
        self.completionBlock = ^{
            weakSelf.shouldExecuting = NO;
        };
        [self addObserver:self forKeyPath:@"isReady" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)start{
    self.shouldReady = self.isReady;
}

- (void)main{
    if (self.isCancelled) {
        return;
    }
    
    self.shouldExecuting = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        !self.executeBlock ?: self.executeBlock();
        self.executeBlock = nil;
    });
    self.shouldFinished = YES;
}

- (void)cancel{
    [super cancel];
    self.shouldFinished = YES;
}

- (BOOL)isFinished{
    return self.shouldFinished;
}

- (BOOL)isExecuting{
    return self.shouldExecuting;
}

- (BOOL)isAsynchronous{
    return YES;
}

- (void)setShouldReady:(BOOL)shouldReady{
    [self willChangeValueForKey:@"isReady"];
    _shouldReady = shouldReady;
    [self didChangeValueForKey:@"isReady"];
}

- (void)setShouldFinished:(BOOL)shouldFinished{
    [self willChangeValueForKey:@"isFinished"];
    _shouldFinished = shouldFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setShouldExecuting:(BOOL)shouldExecuting{
    [self willChangeValueForKey:@"isExecuting"];
    _shouldExecuting = shouldExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isReady"]) {
        ![change[NSKeyValueChangeNewKey] boolValue] ?: [self main];
    }else if ([keyPath isEqualToString:@"isFinished"]) {
        [change[NSKeyValueChangeNewKey] boolValue] ? NSLog(@"is Finished") : NSLog(@"is not Finished");
    }else if ([keyPath isEqualToString:@"isExecuting"]) {
        [change[NSKeyValueChangeNewKey] boolValue] ? NSLog(@"is Executing") : NSLog(@"is not Executing");
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

@interface ViewController ()
@property(nonatomic, strong) CustomerOperation *operation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)beginAction:(id)sender {
    CustomerOperation *operation = [[CustomerOperation alloc] init];
    operation.executeBlock = ^{
        [CentreMediator.shareCentreMediator CM_PushRWViewController];
    };
    [RWThread addOperation:operation];
}

@end
