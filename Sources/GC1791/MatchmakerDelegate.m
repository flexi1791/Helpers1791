//
//  MatchmakerDelegate.m
//  Conversation
//
//  Created by Felix Andrew Work on 2/15/25.
//


#import "MatchmakerDelegate.h"

@implementation MatchmakerDelegate

- (void)startMatchmakingWithMinPlayers:(int)minPlayers
                            maxPlayers:(int)maxPlayers
                      viewController:(UIViewController *)viewController {
    self.presentingViewController = viewController;

    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    request.inviteMessage = @"Lets have a meaningful conversation";

    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = NO;

    [self.presentingViewController presentViewController:mmvc animated:YES completion:nil];
}

#pragma mark - GKTurnBasedMatchmakerViewControllerDelegate

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    NSLog(@"Matchmaker view controller was cancelled");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    NSLog(@"Matchmaker failed with error: %@", [error localizedDescription]);
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
