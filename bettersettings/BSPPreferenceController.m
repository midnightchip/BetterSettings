#include "BSPPreferenceController.h"

@interface UIApplication (existing)
- (void)suspend;
- (void)terminateWithSuccess;
@end
/*@interface UIApplication (close)
- (void)close;
@end
@implementation UIApplication (close)

- (void)close
{
    // Check if the current device supports background execution.
    BOOL multitaskingSupported = NO;
    // iOS < 4.0 compatibility check.
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
        multitaskingSupported = [UIDevice currentDevice].multitaskingSupported;
    // Good practice, we're using a private method.
    if ([self respondsToSelector:@selector(suspend)])
    {
        if (multitaskingSupported)
        {
            [self beginBackgroundTaskWithExpirationHandler:^{}];
            // Change the delay to your liking. I think 0.4 seconds feels just right (the "close" animation lasts 0.3 seconds).
            [self performSelector:@selector(exit) withObject:nil afterDelay:0.4];
        }
        [self suspend];
    }
    else
        [self exit];
}

- (void)exit
{
    // Again, good practice.
    if ([self respondsToSelector:@selector(terminateWithSuccess)])
        [self terminateWithSuccess];
    else
        exit(EXIT_SUCCESS);
}

@end*/


@implementation BSPPreferenceController

- (void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applySettings)];
        self.navigationItem.rightBarButtonItem = applyButton;
}
-(void)applySettings{
  [[UIApplication sharedApplication] terminateWithSuccess];
}
@end
