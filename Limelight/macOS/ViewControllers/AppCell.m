//
//  AppCell.m
//  Moonlight for macOS
//
//  Created by Michael Kenny on 24/12/17.
//  Copyright © 2017 Moonlight Stream. All rights reserved.
//

#import "AppCell.h"
#import "BackgroundColorView.h"

@interface AppCell ()

@end

@implementation AppCell

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appCoverArt.wantsLayer = YES;
    self.appCoverArt.layer.masksToBounds = YES;
    self.appCoverArt.layer.cornerRadius = 6;
    
    [self updateSelectedState:NO];
}

- (void)updateSelectedState:(BOOL)selected {
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateSelectedState:selected];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if ([theEvent clickCount] == 2) {
        [self.delegate openApp:self.app];
    } else {
        [super mouseDown:theEvent];
    }
}

@end
