/**
 * @Author: Dana Buehre <creaturesurvive>
 * @Date:   18-09-2017 2:02:28
 * @Email:  dbuehre@me.com
 * @Filename: PTCProvider.m
 * @Last modified by:   creaturesurvive
 * @Last modified time: 24-09-2017 1:15:07
 * @Copyright: Copyright © 2014-2017 CreatureSurvive
 */


#include "BSProvider.h"
// ────────────────────────────────────────────────────────────────────────────────
// this is the most convenient way or using libCSPreferences preference provider
// here we setup a singelton instance of our preference provider so that we dont
// need to pass our tweaks identifier every time we want to access a value.
// ────────────────────────────────────────────────────────────────────────────────
@implementation BSProvider

#pragma mark Initialization

+ (CSPreferencesProvider *)sharedProvider {
    static dispatch_once_t once;
    static CSPreferencesProvider *sharedProvider;
    dispatch_once(&once, ^{

        // ─────────────────────────────────────────────────────────────────
        // this should match the bundle identifier of your tweak
        // ─────────────────────────────────────────────────────────────────
        NSString *tweakId = @"com.midnightchips.bettersettings";

        // ─────────────────────────────────────────────────────────────────
        // this should usually be your tweak bundleID followed by a string
        // to indicate preferences have changed, this is used for recieving
        // and posting notifications when you change a value in preferences
        // in this case we are not using the norifications for PullToClear
        // as they are not necessary
        // ─────────────────────────────────────────────────────────────────
        NSString *prefsNotification = [tweakId stringByAppendingString:@".prefschanged"];

        // ─────────────────────────────────────────────────────────────────
        // this should point to a plist file containing the default values
        // for your tweak, in this case they are stored in the preference
        // bundle of the tweak, that is the best place to store defaults as
        // it will make them available for CSPreferences to use internally.
        // alternativly you can use another mothod available in
        // CSPreferencesProvider that takes a NSDictionary for defaults
        // rather than a path to a plist
        // ─────────────────────────────────────────────────────────────────
        NSString *defaultsPath = @"/Library/PreferenceBundles/BetterSettings.bundle/defaults.plist";

        // ─────────────────────────────────────────────────────────────────
        // instanciate our provider with the values we set above. now we can
        // access our prefs anywhere in our tweak with a call of
        // [PTCProvider sharedProvider]
        // ─────────────────────────────────────────────────────────────────
        sharedProvider = [[CSPreferencesProvider alloc] initWithTweakID:tweakId defaultsPath:defaultsPath postNotification:prefsNotification notificationCallback:nil];
    });
    return sharedProvider;
}

@end
