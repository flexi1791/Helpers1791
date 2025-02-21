//
//  MatchmakerDelegate.h
//  Conversation
//
//  Created by Felix Andrew Work on 2/15/25.
//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface MatchmakerDelegate : NSObject <GKTurnBasedMatchmakerViewControllerDelegate>

@property (nonatomic, weak) UIViewController *presentingViewController;

- (void)startMatchmakingWithMinPlayers:(int)minPlayers
                            maxPlayers:(int)maxPlayers
                      viewController:(UIViewController *)viewController;

@end
