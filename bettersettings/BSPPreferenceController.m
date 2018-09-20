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
  NSDictionary* dict = @{@"statusColor":@"FFFFFF", @"tableColor":@"000000", @"enableImage":@NO, @"tintNav":@NO, @"navTint":@"000000", @"cornerRadius":@12, @"bubbleColor":@"26252A", @"textTint":@"FFFFFF", @"borderWidth":@3,@"borderColor":@"000000",@"bubbleSelectionColor":@"000000", @"hideIcons":@NO, @"CleanSettings":@NO};
  [dict writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist" atomically:YES];
UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Applied"
                           message:@"Settings Applied!"
                           preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Close Settings" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                 [[UIApplication sharedApplication] close];
                                 [[UIApplication sharedApplication] terminateWithSuccess];
                               }];

[alert addAction:defaultAction];
[self presentViewController:alert animated:YES completion:nil];
}

-(void)BS_enableLightBubbles{
  NSDictionary* dict = @{@"statusColor":@"000000", @"tableColor":@"FFFFFF", @"enableImage":@NO, @"tintNav":@NO, @"navTint":@"000000", @"cornerRadius":@12, @"bubbleColor":@"F6F6F6", @"textTint":@"000000", @"borderWidth":@3,@"borderColor":@"FFFFFF",@"bubbleSelectionColor":@"E9E9E9", @"hideIcons":@NO, @"CleanSettings":@NO};
  [dict writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist" atomically:YES];
UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Applied"
                           message:@"Settings Applied!"
                           preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Close Settings" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                 [[UIApplication sharedApplication] close];
                                 [[UIApplication sharedApplication] terminateWithSuccess];
                               }];

[alert addAction:defaultAction];
[self presentViewController:alert animated:YES completion:nil];
}

-(void)BS_enableDarkClean{
  NSDictionary* dict = @{@"statusColor":@"FFFFFF", @"tableColor":@"000000", @"enableImage":@NO, @"tintNav":@NO, @"navTint":@"000000", @"cornerRadius":@0, @"bubbleColor":@"161616", @"textTint":@"FFFFFF", @"borderWidth":@0,@"borderColor":@"000000",@"bubbleSelectionColor":@"25000000", @"hideIcons":@YES, @"CleanSettings":@YES};
  [dict writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist" atomically:YES];
UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Applied"
                           message:@"Settings Applied!"
                           preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Close Settings" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                 [[UIApplication sharedApplication] close];
                                 [[UIApplication sharedApplication] terminateWithSuccess];
                               }];

[alert addAction:defaultAction];
[self presentViewController:alert animated:YES completion:nil];
}

-(void)BS_enableImage{
  NSDictionary* dict = @{@"statusColor":@"FFFFFFFF", @"tableColor":@"00000000", @"enableImage":@YES, @"tintNav":@YES, @"navTint":@"42000000", @"cornerRadius":@0, @"bubbleColor":@"0026252A", @"textTint":@"FFFFFF", @"borderWidth":@0,@"borderColor":@"00000000",@"bubbleSelectionColor":@"34000000", @"hideIcons":@NO, @"CleanSettings":@NO};
  [dict writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist" atomically:YES];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.bgimage.plist"]){
    NSData *data =[[NSFileManager defaultManager] contentsAtPath:@"/Library/PreferenceBundles/BetterSettings.bundle/image.plist"];
    [data writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.bgimage.plist" atomically:YES];
}
UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Applied"
                           message:@"Settings Applied!"
                           preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Close Settings" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                 [[UIApplication sharedApplication] close];
                                 [[UIApplication sharedApplication] terminateWithSuccess];
                               }];

[alert addAction:defaultAction];
[self presentViewController:alert animated:YES completion:nil];
}
-(void)BS_applySettings{
  [[UIApplication sharedApplication] close];
  [[UIApplication sharedApplication] terminateWithSuccess];
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
