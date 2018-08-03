// move this header and its implementation into the root of your project
// add this line to your Makefile `com.midnightchips.bettersettings_LDFLAGS += -lCSPreferencesProvider`

#include <CSPreferencesProvider.h>
#define prefs [BSPProvider sharedProvider]

@interface BSPProvider : NSObject

+ (CSPreferencesProvider *)sharedProvider;

@end