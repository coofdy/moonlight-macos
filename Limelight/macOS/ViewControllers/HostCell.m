//
//  HostCell.m
//  Moonlight for macOS
//
//  Created by Michael Kenny on 22/12/17.
//  Copyright © 2017 Moonlight Stream. All rights reserved.
//

#import "HostCell.h"
#import "BackgroundColorView.h"

@interface HostCell ()
@property (weak) IBOutlet BackgroundColorView *imageContainer;
@property (weak) IBOutlet BackgroundColorView *labelContainer;

@end

@implementation HostCell

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageContainer.wantsLayer = YES;
    self.imageContainer.layer.masksToBounds = YES;
    self.imageContainer.layer.cornerRadius = 4;
    self.labelContainer.wantsLayer = YES;
    self.labelContainer.layer.masksToBounds = YES;
    self.labelContainer.layer.cornerRadius = 3;
    
    [self updateSelectedState:NO];
}

- (void)updateSelectedState:(BOOL)selected {
    self.imageContainer.backgroundColor = selected ? [NSColor colorWithWhite:0 alpha:0.1] : [NSColor clearColor];
    self.labelContainer.backgroundColor = selected ? [NSColor alternateSelectedControlColor] : [NSColor clearColor];
    self.hostName.textColor = selected ? [NSColor alternateSelectedControlTextColor] : [NSColor textColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateSelectedState:selected];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if ([theEvent clickCount] == 2) {
        [self.delegate openHost:self.host];
    } else {
        [super mouseDown:theEvent];
    }
}

@end
