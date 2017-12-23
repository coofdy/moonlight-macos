//
//  HostCell.h
//  Moonlight for macOS
//
//  Created by Michael Kenny on 22/12/17.
//  Copyright © 2017 Moonlight Stream. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HostsViewControllerDelegate.h"

@interface HostCell : NSCollectionViewItem
@property (weak) IBOutlet NSTextField *hostName;
@property (nonatomic, strong) TemporaryHost *host;
@property (nonatomic, weak) id<HostsViewControllerDelegate> delegate;

@end
