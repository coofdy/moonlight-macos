//
//  AppCell.m
//  Moonlight for macOS
//
//  Created by Michael Kenny on 24/12/17.
//  Copyright © 2017 Moonlight Stream. All rights reserved.
//

#import "AppCell.h"
#import "AppCellView.h"
#import "NSApplication+Moonlight.h"

#import <QuartzCore/QuartzCore.h>

#import "Moonlight-Swift.h"

@interface AppCell () <NSMenuDelegate>
@property (nonatomic) BOOL togglingHideStatus;
@property (nonatomic) BOOL hovered;
@property (nonatomic) BOOL previousHovered;
@property (nonatomic) BOOL previousSelected;
@end

@implementation AppCell

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSShadow *runningShadow = [[NSShadow alloc] init];
    [runningShadow setShadowColor:[NSColor colorWithRed:0.06 green:0.204 blue:0.5 alpha:0.75]];
    [runningShadow setShadowOffset:NSMakeSize(0, -2)];
    [runningShadow setShadowBlurRadius:2];
    self.runningIcon.shadow = runningShadow;
    
    self.appCoverArt.wantsLayer = YES;
    self.appCoverArt.layer.masksToBounds = YES;
    if (@available(macOS 10.15, *)) {
        self.appCoverArt.layer.cornerCurve = kCACornerCurveContinuous;
    }
    self.placeholderView.layer.cornerRadius = APP_CELL_CORNER_RADIUS;

    self.placeholderView.backgroundColor = [NSColor systemGrayColor];
    self.placeholderView.wantsLayer = YES;
    self.placeholderView.layer.masksToBounds = YES;
    if (@available(macOS 10.15, *)) {
        self.appCoverArt.layer.cornerCurve = kCACornerCurveContinuous;
    }
    self.placeholderView.layer.cornerRadius = APP_CELL_CORNER_RADIUS;

    self.appNameContainer.wantsLayer = YES;
    self.appNameContainer.layer.masksToBounds = YES;
    self.appNameContainer.layer.cornerRadius = 4;

    ((AppCellView *)self.view).delegate = self;
    
    [self updateSelectedState:NO];
}

- (CATransform3D)translationTransform {
    return CATransform3DMakeTranslation(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 0);
}

- (CGFloat)scaleForSelected:(BOOL)selected hovered:(BOOL)hovered {
    CGFloat scale = 1;
    if (selected) {
        scale *= 1.15;
    }
    if (hovered) {
        scale *= 1.1;
    }
    return scale;
}

- (void)enterHoveredState {
    self.hovered = YES;
    [self animateSelectedAndHoveredState];
}

- (void)exitHoveredState {
    self.hovered = NO;
    [self animateSelectedAndHoveredState];
}

- (void)animateSelectedAndHoveredState {
    CGFloat oldScale = [self scaleForSelected:self.previousSelected hovered:self.previousHovered];
    CGFloat newScale = [self scaleForSelected:self.selected hovered:self.hovered];
    if (fabs(oldScale - newScale) < 0.0001) {
        return;
    }
    
    self.view.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CATransform3D oldTransform = CATransform3DScale([self translationTransform], oldScale, oldScale, 1);
    CATransform3D newTransform = CATransform3DScale([self translationTransform], newScale, newScale, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:oldTransform];
    animation.toValue = [NSValue valueWithCATransform3D:newTransform];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = 0.2;
    animation.beginTime = 0.0;
    
    [self.view.layer addAnimation:animation forKey:nil];
    self.view.layer.transform = newTransform;
    
    [NSAnimationContext beginGrouping];
    [NSAnimationContext currentContext].duration = 0.4;
    self.appCoverArt.superview.animator.alphaValue = [self appCoverArtAlphaWithHovered:self.hovered];
    [NSAnimationContext endGrouping];
    
    self.previousSelected = self.selected;
    self.previousHovered = self.hovered;
}

- (CGFloat)shadowAlpha {
    if (@available(macOS 10.14, *)) {
        return [NSApplication moonlight_isDarkAppearance] ? 0.7 : 0.33;
    } else {
        return [NSApplication moonlight_isDarkAppearance] ? 0.7 : 0.55;
    }
}

- (CGFloat)appCoverArtAlphaWithHovered:(BOOL)hovered {
    if (self.app.hidden) {
        return 0.33;
    }
    if (self.selected) {
        return 1;
    } else {
        if (hovered) {
            return [NSApplication moonlight_isDarkAppearance] ? 1 : 1;
        } else {
            return [NSApplication moonlight_isDarkAppearance] ? 0.85 : 0.925;
        }
    }
}

- (void)updateAlphaStateWithShouldAnimate:(BOOL)animate {
    self.togglingHideStatus = YES;
    if (animate) {
        [NSAnimationContext beginGrouping];
        [NSAnimationContext currentContext].duration = 0.4;
        [NSAnimationContext currentContext].completionHandler = ^{
            self.togglingHideStatus = NO;
        };
        self.appCoverArt.superview.animator.alphaValue = [self appCoverArtAlphaWithHovered:NO];
        [NSAnimationContext endGrouping];
    } else {
        self.togglingHideStatus = NO;
        self.appCoverArt.superview.alphaValue = [self appCoverArtAlphaWithHovered:NO];
    }
}

- (void)updateSelectedState:(BOOL)selected {
    NSView *appCoverArtContainerView = self.appCoverArt.superview;
    appCoverArtContainerView.shadow = [[NSShadow alloc] init];
    appCoverArtContainerView.wantsLayer = YES;

    appCoverArtContainerView.layer.shadowColor = [NSColor colorWithWhite:0 alpha:[self shadowAlpha]].CGColor;
    if (@available(macOS 10.14, *)) {
        appCoverArtContainerView.layer.shadowOffset = NSMakeSize(0, -5);
        appCoverArtContainerView.layer.shadowRadius = 5;
    } else {
        appCoverArtContainerView.layer.shadowOffset = NSMakeSize(0, -4);
        appCoverArtContainerView.layer.shadowRadius = 4;
    }

    self.appNameContainer.backgroundColor = selected ? [NSColor alternateSelectedControlColor] : [NSColor clearColor];
    self.appName.textColor = selected ? [NSColor alternateSelectedControlTextColor] : [NSColor textColor];

    [NSAnimationContext beginGrouping];
    [NSAnimationContext currentContext].duration = 0.4;
    self.appCoverArt.superview.animator.alphaValue = [self appCoverArtAlphaWithHovered:NO];
    [NSAnimationContext endGrouping];

    [self animateSelectedAndHoveredState];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self updateAlphaStateWithShouldAnimate:NO];
    [self updateShadowPath];
}

- (CGMutablePathRef)CGPathFromPath:(NSBezierPath *)path {
    CGMutablePathRef cgPath = CGPathCreateMutable();
    NSInteger n = [path elementCount];

    for (NSInteger i = 0; i < n; i++) {
        NSPoint ps[3];
        switch ([path elementAtIndex:i associatedPoints:ps]) {
            case NSMoveToBezierPathElement: {
                CGPathMoveToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSLineToBezierPathElement: {
                CGPathAddLineToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSCurveToBezierPathElement: {
                CGPathAddCurveToPoint(cgPath, NULL, ps[0].x, ps[0].y, ps[1].x, ps[1].y, ps[2].x, ps[2].y);
                break;
            }
            case NSClosePathBezierPathElement: {
                CGPathCloseSubpath(cgPath);
                break;
            }
            default: NSAssert(0, @"Invalid NSBezierPathElement");
        }
    }
    return cgPath;
}

- (void)updateShadowPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBezierPath *shadowPath = [NSBezierPath bezierPathWithRoundedRect:self.appCoverArt.bounds xRadius:APP_CELL_CORNER_RADIUS yRadius:APP_CELL_CORNER_RADIUS];
        self.appCoverArt.superview.layer.shadowPath = [self CGPathFromPath:shadowPath];
    });
}

- (void)setSelected:(BOOL)selected {
    BOOL previousState = self.selected;
    [super setSelected:selected];
    
    if (previousState != selected) {
        [self updateSelectedState:selected];
    }
}

- (void)mouseEntered:(NSEvent *)event {
    [self.delegate didHover:YES forApp:self.app];
}

- (void)mouseExited:(NSEvent *)event {
    if (!self.togglingHideStatus) {
        [self.delegate didHover:NO forApp:self.app];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    if ([theEvent clickCount] == 2) {
        [self.delegate openApp:self.app];
    } else {
        [super mouseDown:theEvent];
    }
}

- (void)menuWillOpen:(NSMenu *)menu {
    [self.delegate didOpenContextMenu:menu forApp:self.app];
}

@end
