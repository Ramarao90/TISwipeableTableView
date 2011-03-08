//
//  TISwipeableTableViewDelegate.h
//  SwipeableExample
//
//  Created by Marcel Müller on 08.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TISwipeableTableViewDelegate <NSObject>
@optional
- (BOOL)tableView:(UITableView *)tableView shouldSwipeCellAtIndexPath:(NSIndexPath *)indexPath; // Thanks to Martin Destagnol (@mdestagnol) for this delegate method.
- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath;
@end
