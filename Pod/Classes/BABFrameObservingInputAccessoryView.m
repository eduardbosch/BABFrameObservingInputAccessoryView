//
//  BABFrameObservingInputAccessoryView.m
//
//  Created by Bryn Bodayle on October/21/2014.
//  Copyright (c) 2014 Bryn Bodayle. All rights reserved.
//

#import "BABFrameObservingInputAccessoryView.h"

static const CGFloat BABFrameObservingInputAccessoryViewDefaultHeight = 44.0f;
static void *BABFrameObservingContext = &BABFrameObservingContext;

@interface BABFrameObservingInputAccessoryView()

@property (nonatomic, assign, getter=isObserverAdded) BOOL observerAdded;
@property (nonatomic, readwrite) CGRect inputAccessorySuperviewFrame;

@end

@implementation BABFrameObservingInputAccessoryView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self sharedInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), BABFrameObservingInputAccessoryViewDefaultHeight)];
    if (self) {
        
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    
    self.userInteractionEnabled = NO;
}

- (void)dealloc {
    
    if(_observerAdded) {
        
        [self.superview removeObserver:self forKeyPath:@"frame" context:BABFrameObservingContext];
        [self.superview removeObserver:self forKeyPath:@"center" context:BABFrameObservingContext];
    }
}

#pragma mark - Setters & Getters

- (void)setInputAccessorySuperviewFrame:(CGRect)inputAccessorySuperviewFrame {
    
    if(self.inputAccessorySuperviewFrameChangedBlock) {
        
        CGFloat inputAccessoryViewHeight = CGRectGetHeight(self.bounds);
        
        CGRect frame = inputAccessorySuperviewFrame;
        frame.origin.y += inputAccessoryViewHeight;
        frame.size.height -= inputAccessoryViewHeight;
        BOOL visible = [self isKeyboardFrameVisible:frame];
        self.inputAccessorySuperviewFrameChangedBlock(visible, frame);
    }
}

- (CGRect)inputAcesssorySuperviewFrame {
    
    return self.superview.frame;
}

- (BOOL)isKeyboardVisible {
    
    return [self isKeyboardFrameVisible:self.inputAcesssorySuperviewFrame];
}

#pragma mark - Overwritten Methods

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    if(self.isObserverAdded) {
        
        [self.superview removeObserver:self forKeyPath:@"frame" context:BABFrameObservingContext];
        [self.superview removeObserver:self forKeyPath:@"center" context:BABFrameObservingContext];
    }
    
    [newSuperview addObserver:self forKeyPath:@"frame" options:0 context:BABFrameObservingContext];
    [newSuperview addObserver:self forKeyPath:@"center" options:0 context:BABFrameObservingContext];
    self.observerAdded = YES;
    
    [super willMoveToSuperview:newSuperview];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.inputAccessorySuperviewFrame = self.superview.frame;
}

#pragma mark - Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.superview && ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"center"])) {
        
        self.inputAccessorySuperviewFrame = self.superview.frame;
    }
}


#pragma mark - Helper Methods

- (BOOL)isKeyboardFrameVisible:(CGRect)keyboardFrame {
    
    return CGRectGetMinY(keyboardFrame) < CGRectGetHeight([UIScreen mainScreen].bounds);
}

@end
