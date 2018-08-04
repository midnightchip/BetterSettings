#include "BSPPreferenceController.h"
#include <CSPreferences/libCSPUtilities.h>


@interface UIApplication (existing)
- (void)suspend;
- (void)terminateWithSuccess;
@end
@interface UIApplication (close)
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

   @end


@implementation CSPListController (BetterSettings)
-(void)BS_enableDarkBubbles{
  /*[CSPUProcessManager resultFromProcessAtPath:@"/bin/cp" handle:nil arguments:@[@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist.bubbleDark", @"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist",] completion:^(NSTask *task){

        [[UIApplication sharedApplication] terminateWithSuccess];
}];*/
UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                           message:@"This is an alert."
                           preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];

[alert addAction:defaultAction];
[self presentViewController:alert animated:YES completion:nil];
}
@end
@implementation BSPPreferenceController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applySettings)];
        self.navigationItem.rightBarButtonItem = applyButton;
}
-(void)applySettings{
  [[UIApplication sharedApplication] close];
  [[UIApplication sharedApplication] terminateWithSuccess];
}
@end
