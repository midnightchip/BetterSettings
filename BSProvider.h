#include <CSPreferences/CSPreferencesProvider.h>
#define prefs [BSProvider sharedProvider]

@interface BSProvider : NSObject

+ (CSPreferencesProvider *)sharedProvider;

@end
