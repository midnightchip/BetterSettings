#import "UIImage+ScaledImage.h"
#import <PrefixUI/PrefixUI.h>
#import <UIKit/UIKit.h>
#include <CSColorPicker/CSColorPicker.h>
#import <libimagepicker.h>
#include "BSProvider.h"
//#define rgb(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]


NSInteger colorProfile;

struct pixel {
    unsigned char r, g, b, a;
};

CGFloat alpha = 1.0;
static UIColor *dominantColorFromImage(UIImage *image) {
    CGImageRef iconCGImage = image.CGImage;
    NSUInteger red = 0, green = 0, blue = 0;
    size_t width = CGImageGetWidth(iconCGImage);
    size_t height = CGImageGetHeight(iconCGImage);
    size_t bitmapBytesPerRow = width * 4;
    size_t bitmapByteCount = bitmapBytesPerRow * height;
    struct pixel *pixels = (struct pixel *)malloc(bitmapByteCount);
    if (pixels) {
        CGContextRef context = CGBitmapContextCreate((void *)pixels, width, height, 8, bitmapBytesPerRow, CGImageGetColorSpace(iconCGImage), kCGImageAlphaPremultipliedLast);
        if (context) {
            CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), iconCGImage);
            NSUInteger numberOfPixels = width * height;
            for (size_t i = 0; i < numberOfPixels; i++) {
                red += pixels[i].r;
                green += pixels[i].g;
                blue += pixels[i].b;
            }
            red /= numberOfPixels;
            green /= numberOfPixels;
            blue /= numberOfPixels;
            CGContextRelease(context);
        }
        free(pixels);
    }
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

UIColor *imageAverageColor(UIImage *image) {
    UIColor *color = dominantColorFromImage(image);
    return color;
}


/*
  _____           __
 |  __ \         / _|
 | |__) | __ ___| |_ ___
 |  ___/ '__/ _ \  _/ __|
 | |   | | |  __/ | \__ \
 |_|   |_|  \___|_| |___/

*/

@interface NSUserDefaults (BetterSettings)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
/*
any value thats not bool you should be able to do prefs[@"key"] integerValue | floatValue] etc,
and for string values you can just do prefs[@"key"]; bool is the only type that requires the extra steps shown above
*/
static NSString *nsDomainString = @"/User/Library/Preferences/com.midnightchips.bettersettingsmain";
static NSString *imagePlist = @"com.midnightchips.bettersettings.bgimage";
static NSString *nsNotificationString = @"com.midnightchips.bettersettings.prefschanged";
static NSString *nsPrefPlistPath = @"/User/Library/Preferences/com.midnightchips.bettersettings.plist";

//static UIImage *bgImage;
static NSData *tableImage;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  //Image
  NSData *tImage = (NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundImage" inDomain:imagePlist];
  tableImage = tImage;
}

//Set Preset on first load

@interface UIApplication (existing)
- (void)suspend;
- (void)terminateWithSuccess;
@end
@interface UIApplication (close)
- (void)close;
@end
@implementation UIApplication (close)

- (void)close{
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
- (void)exit{
    // Again, good practice.
    if ([self respondsToSelector:@selector(terminateWithSuccess)])
    [self terminateWithSuccess];
    else
    exit(EXIT_SUCCESS);
  }

@end

%hook PSUIPrefsListController
@interface PSUIPrefsListController : UIViewController
@end

@interface SBApplication : NSObject
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (id)applicationWithBundleIdentifier:(id)arg1;
@end

-(void)viewDidAppear:(BOOL)animated{

  %orig;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/BetterSettings/preset"]){
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Hi!"
                               message:@"It appears this is your first time using this tweak. Which Preset would you like?"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* bubble = [UIAlertAction actionWithTitle:@"Dark Bubbles" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                     [fileManager createDirectoryAtPath:@"/var/mobile/Library/Preferences/BetterSettings/" withIntermediateDirectories:NO attributes:nil error:nil];
                                     [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/BetterSettings/preset" contents:nil attributes:nil];
                                     NSDictionary* dict = @{@"statusColor":@"FFFFFF", @"tableColor":@"000000", @"enableImage":@NO, @"tintNav":@NO, @"navTint":@"000000", @"cornerRadius":@12, @"bubbleColor":@"26252A", @"textTint":@"FFFFFF", @"borderWidth":@3,@"borderColor":@"000000",@"bubbleSelectionColor":@"000000", @"hideIcons":@NO, @"CleanSettings":@NO};
                                     [dict writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist" atomically:YES];
                                     [[UIApplication sharedApplication] close];
                                     [[UIApplication sharedApplication] terminateWithSuccess];
                                   }];
     UIAlertAction* whiteBubble = [UIAlertAction actionWithTitle:@"Light Bubbles" style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                      [fileManager createDirectoryAtPath:@"/var/mobile/Library/Preferences/BetterSettings/" withIntermediateDirectories:NO attributes:nil error:nil];
                                      [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/BetterSettings/preset" contents:nil attributes:nil];
                                      NSDictionary* dict = @{@"statusColor":@"000000", @"tableColor":@"FFFFFF", @"enableImage":@NO, @"tintNav":@NO, @"navTint":@"000000", @"cornerRadius":@12, @"bubbleColor":@"F6F6F6", @"textTint":@"000000", @"borderWidth":@3,@"borderColor":@"FFFFFF",@"bubbleSelectionColor":@"E9E9E9", @"hideIcons":@NO, @"CleanSettings":@NO};
                                      [dict writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist" atomically:YES];
                                      [[UIApplication sharedApplication] close];
                                      [[UIApplication sharedApplication] terminateWithSuccess];
                                    }];

UIAlertAction* image = [UIAlertAction actionWithTitle:@"Transparent with Background Image" style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                    [fileManager createDirectoryAtPath:@"/var/mobile/Library/Preferences/BetterSettings/" withIntermediateDirectories:NO attributes:nil error:nil];
                                    [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/BetterSettings/preset" contents:nil attributes:nil];
                                    NSDictionary* dict = @{@"statusColor":@"FFFFFFFF", @"tableColor":@"00000000", @"enableImage":@YES, @"tintNav":@YES, @"navTint":@"42000000", @"cornerRadius":@0, @"bubbleColor":@"0026252A", @"textTint":@"FFFFFF", @"borderWidth":@0,@"borderColor":@"00000000",@"bubbleSelectionColor":@"34000000", @"hideIcons":@NO, @"CleanSettings":@NO};
                                    [dict writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.plist" atomically:YES];
                                    if (![fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.bgimage.plist"]){
                                      NSData *data =[[NSFileManager defaultManager] contentsAtPath:@"/Library/PreferenceBundles/BetterSettings.bundle/image.plist"];
                                      [data writeToFile:@"/var/mobile/Library/Preferences/com.midnightchips.bettersettings.bgimage.plist" atomically:YES];
                                      [[UIApplication sharedApplication] close];
                                      [[UIApplication sharedApplication] terminateWithSuccess];
                                    }

                                  }];


    [alert addAction:bubble];
    [alert addAction:whiteBubble];
    [alert addAction:image];
    [self presentViewController:alert animated:YES completion:nil];

}

}
%end
/*
 _______ _________ _______ _________          _______  ______   _______  _______
(  ____ \\__   __/(  ___  )\__   __/|\     /|(  ____ \(  ___ \ (  ___  )(  ____ )
| (    \/   ) (   | (   ) |   ) (   | )   ( || (    \/| (   ) )| (   ) || (    )|
| (_____    | |   | (___) |   | |   | |   | || (_____ | (__/ / | (___) || (____)|
(_____  )   | |   |  ___  |   | |   | |   | |(_____  )|  __ (  |  ___  ||     __)
      ) |   | |   | (   ) |   | |   | |   | |      ) || (  \ \ | (   ) || (\ (
/\____) |   | |   | )   ( |   | |   | (___) |/\____) || )___) )| )   ( || ) \ \__
\_______)   )_(   |/     \|   )_(   (_______)\_______)|/ \___/ |/     \||/   \__/

*/
//iPX
%hook _UIStatusBar

@interface _UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

-(void)layoutSubviews {
    %orig;

    //self.backgroundColor = [prefs colorForKey:@"statusColor"];//statusColor];
    self.foregroundColor = [prefs colorForKey:@"statusColor"];//statusColor];
}

%end
//Normal iPhone
%hook UIStatusBar

@interface UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

-(void)layoutSubviews {
    %orig;
    self.foregroundColor = [prefs colorForKey:@"statusColor"];//statusColor];
}

%end
//Set StatusBar Background
//Make Sure to set the color to match navBar
%hook UIStatusBarBackgroundView

@interface UIStatusBarBackgroundView : UIView
@end
//set to clear when using background option, or blurred
-(void)layoutSubviews {
  %orig;
  if ([prefs boolForKey:@"enableImage"]){
    if([prefs boolForKey:@"tintNav"]){
      self.backgroundColor = [prefs colorForKey:@"navTint"];
    }else{
      self.backgroundColor = [UIColor clearColor];
    }

  }else {
    self.backgroundColor = [prefs colorForKey:@"tableColor"];
  }
}
%end

/*
 _   _             _             _   _             ____
| \ | |           (_)           | | (_)           |  _ \
|  \| | __ ___   ___  __ _  __ _| |_ _  ___  _ __ | |_) | __ _ _ __
| . ` |/ _` \ \ / / |/ _` |/ _` | __| |/ _ \| '_ \|  _ < / _` | '__|
| |\  | (_| |\ V /| | (_| | (_| | |_| | (_) | | | | |_) | (_| | |
|_| \_|\__,_| \_/ |_|\__, |\__,_|\__|_|\___/|_| |_|____/ \__,_|_|
                     __/ |
                    |___/
*/

%hook UINavigationBar

@interface UINavigationBar (Settings)
-(void)setLargeTitleTextAttributes:(NSDictionary *)arg1;
@end
//Has to be layoutSubviews, as without it Cephei prefs brake this.
-(void)layoutSubviews{
    %orig;
    //Sets bar style, removes white Bar
    [self setBarStyle:UIBarStyleBlack];

    //Sets title Text to white

    self.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};

    //Tints the Buttons
    self.tintColor = [prefs colorForKey:@"textTint"];

    //Hide background Image of NavBar, Makes black/ background image stand out
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    //Set BackgroundColor of NavBar, clear for backgroundImage
    if([prefs boolForKey:@"enableImage"]){
      if([prefs boolForKey:@"tintNav"]){
        [self setBackgroundColor:[prefs colorForKey:@"navTint"]];
      }else{
        [self setBackgroundColor:[UIColor clearColor]];
      }

    }else{
      [self setBackgroundColor:[prefs colorForKey:@"tableColor"]];
    }


    //Shadow ¯\_(ツ)_/¯ not sure what this does, but uhh... the code doesnt work without it.
    //self.shadowImage = [UIImage new];

    //Sets the NavBar transparent, scrolling etc.
    //Keep this on, otherwise it breaks the background of searching
    self.translucent = YES;
}
%end
//iPX Fix wierd gap Clear for background, color otherwise
%hook _UIBarBackground
- (void) setBackgroundColor:(UIColor *)color {
  if([prefs boolForKey:@"enableImage"]){
    if([prefs boolForKey:@"tintNav"]){
      %orig([prefs colorForKey:@"navTint"]);
    }else{
      %orig([UIColor clearColor]);
    }

  }else{
    %orig([prefs colorForKey:@"tableColor"]);
  }

}
%end
//Stupid Fix for Cephi atm, until something better comes about, Clear for background, color otherwise
%hook PSKeyboardNavigationSearchBar
- (void) setBackgroundColor:(UIColor *)color {
  if([prefs boolForKey:@"enableImage"]){
    if([prefs boolForKey:@"tintNav"]){
      %orig([prefs colorForKey:@"navTint"]);
    }else{
      %orig([UIColor clearColor]);
    }

  }else{
    %orig([prefs colorForKey:@"tableColor"]);
  }
}
%end


@interface UISearchBarTextField : UITextField
@end

%hook UISearchBar
-(UITextField *)searchField {
    UITextField* field = %orig;
    field.textColor = [prefs colorForKey:@"textTint"];
    return field;
}
%end
/*
_____                     _     ____
/ ____|                   | |   |  _ \
| (___   ___  __ _ _ __ ___| |__ | |_) | __ _ _ __
 \___ \ / _ \/ _` | '__/ __| '_ \|  _ < / _` | '__|
 ____) |  __/ (_| | | | (__| | | | |_) | (_| | |
|_____/ \___|\__,_|_|  \___|_| |_|____/ \__,_|_|

*/
%hook UITextField
-(void)didMoveToWindow{
  %orig;
  self.backgroundColor = [UIColor clearColor];
  if([prefs boolForKey:@"adaptiveColor"]){
    UIImage *textImage = [UIImage imageWithData:tableImage];
    UIColor *avgColor = imageAverageColor(textImage);
    self.textColor = avgColor;
  }else{
    self.textColor = [UIColor blackColor];//[prefs colorForKey:@"textTint"];//[prefs colorForKey:@"textTint"];
  }

}
%end

/*
 _______   _     _
|__   __| | |   | |
  | | __ _| |__ | | ___  ___
  | |/ _` | '_ \| |/ _ \/ __|
  | | (_| | |_) | |  __/\__ \
  |_|\__,_|_.__/|_|\___||___/

*/
%hook UITableViewCell
-(void)didMoveToWindow {
  %orig;
  //Corners of the Tables

    //ENDED ON CORNER RADIUS
    //TODO FINISH THIS :P
    [self.layer setCornerRadius:[prefs floatForKey:@"cornerRadius"]];

    [self setBackgroundColor: [prefs colorForKey:@"bubbleColor"]];//rgb(38, 37, 42)];
    //Border Color and Width
    [self.layer setBorderColor:[prefs colorForKey:@"borderColor"].CGColor];
    [self.layer setBorderWidth:[prefs floatForKey:@"borderWidth"]];

    //Set Text Color
    if([prefs boolForKey:@"adaptiveColor"]){
      UIImage *textImage = [UIImage imageWithData:tableImage];
      UIColor *avgColor = imageAverageColor(textImage);
      self.textLabel.textColor = avgColor;
      self.detailTextLabel.textColor = avgColor;
    }else{
      self.textLabel.textColor = [prefs colorForKey:@"textTint"];//[prefs colorForKey:@"textTint"];
      self.detailTextLabel.textColor = [prefs colorForKey:@"textTint"];//[prefs colorForKey:@"textTint"];
    }

    self.clipsToBounds = YES;
    MSHookIvar<UIColor*>(self, "_selectionTintColor") = [prefs colorForKey:@"bubbleSelectionColor"];



  //Background Color of Corners

  //self.selectionTintColor = [UIColor blackColor];
}
%end



%hook UITableView
//Resize Image Interface and Implementation
@interface UIImage (ResizeImage)
- (UIImage *)imageScaledToSize:(CGSize)newSize;
@end
//Implementation
@implementation UIImage (ResizeImage)

- (UIImage *)imageScaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

-(void)didMoveToWindow {
  %orig;
  //No Separators in the Tables
  self.separatorStyle = UITableViewCellSeparatorStyleNone;
  //Set the background Color to a Color or to an Image
  //self.backgroundColor = [UIColor blackColor];
  //Set the Background to an Image, Importing UIImage+ScaledImage.h for this
  if([prefs boolForKey:@"enableImage"]){              //TODO CHANGE THE IMAGE TO PICKING AN IMAGE
    UIImage *bgImage = [[UIImage imageWithData:tableImage] imageScaledToSize:[[UIApplication sharedApplication] keyWindow].bounds.size];
    self.backgroundView = [[UIImageView alloc] initWithImage: bgImage];
  }else{
    self.backgroundColor = [prefs colorForKey:@"tableColor"];
  }

}
%end

//Globally fix the UILabel text (for the most part)
//TODO fix UIAlert
%hook UILabel
-(void)layoutSubviews{
  %orig;
  if([prefs boolForKey:@"adaptiveColor"]){
    UIImage *textImage = [UIImage imageWithData:tableImage];
    UIColor *avgColor = imageAverageColor(textImage);
    self.textColor = avgColor;
  }else{
    self.textColor = [prefs colorForKey:@"textTint"];
  }
  self.backgroundColor = [UIColor clearColor];
}
%end
/*
 ______ _
|  ____(_)
| |__   ___  _____  ___
|  __| | \ \/ / _ \/ __|
| |    | |>  <  __/\__ \
|_|    |_/_/\_\___||___/


*/

//Fix the HeaderFooter text in Phone
%hook _UITableViewHeaderFooterViewBackground

@interface _UITableViewHeaderFooterViewBackground : UIView
@end

-(void)didMoveToWindow {
  %orig;
  self.backgroundColor = [UIColor clearColor];
}
%end

//Prefix Compatibility
%hook PRXBubbleBackgroundView
-(void)layoutSubviews{
  %orig;
  if([prefs boolForKey:@"enableImage"]){
    self.backgroundColor = [UIColor clearColor];//rgb(38, 37, 42);
  }else{
    self.backgroundColor = [prefs colorForKey:@"bubbleColor"];
  }

}
%end

//Fix Wifi Connection Image
%hook WFAssociationStateView

@interface WFAssociationStateView : UIView
@end

-(void)layoutSubviews{
  %orig;
  self.backgroundColor = [UIColor clearColor];
}
%end
//Color Glyphs in Wifi
%hook WFNetworkListCell
-(void)layoutSubviews{
  %orig;
  //Lock Glyph
  UIImageView *lock = MSHookIvar<UIImageView*>(self, "_lockImageView");
  lock.image = [lock.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [lock setTintColor:[prefs colorForKey:@"textTint"]];
  //Wifi Glyph
  UIImageView *wifi = MSHookIvar<UIImageView*>(self, "_signalImageView");
  wifi.image = [wifi.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [wifi setTintColor:[prefs colorForKey:@"textTint"]];

}
%end

//TODO Fix UIAlerts
/*%hook  SBAlertView
@interface SBAlertView : UIView
@end
-(void)viewDidLoad{
  self.backgroundColor = [UIColor blackColor];
}
%end*/

@interface UIInterfaceActionGroupView : UIView
@end

@interface _UIAlertControllerInterfaceActionGroupView : UIInterfaceActionGroupView
@end

@interface _UIAlertControlleriOSActionSheetCancelBackgroundView : UIView
@end

%hook UIAlertControllerVisualStyleAlert

- (UIColor *)titleLabelColor {
    return UIColor.blackColor;
}

- (UIColor *)messageLabelColor {
    return UIColor.blackColor;
}

%end

// color of title and body of action sheets
%hook UIAlertControllerVisualStyleActionSheet

- (UIColor *)titleLabelColor {
    return UIColor.blackColor;
}

- (UIColor *)messageLabelColor {
    return UIColor.blackColor;
}


%end

//Sets Background
%hook _UIAlertControllerInterfaceActionGroupView

- (void)layoutSubviews {
    %orig;

    UIView *filterView = self.subviews.firstObject.subviews.lastObject.subviews.lastObject;
    filterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];

    UIView *labelHolder = self.subviews.lastObject.subviews.firstObject.subviews.firstObject;
    for (UILabel *label in labelHolder.subviews) {
        if ([label respondsToSelector:@selector(setTextColor:)]) {
            label.textColor = UIColor.whiteColor;
        }
    }
}

%end

%hook PUAlbumListCellContentView
@interface PUAlbumListCellContentView : UIView
@end
-(UITextField *)_titleTextField {
    UITextField* field = %orig;
    field.textColor = [prefs colorForKey:@"textTint"];
    return field;
}
%end

%hook PUCollectionView
@interface PUCollectionView : UIView
@end
-(void)didMoveToWindow{
  %orig;
  if([prefs boolForKey:@"enableImage"]){
    UIImage *bgImage = [[UIImage imageWithData:tableImage] imageScaledToSize:[[UIApplication sharedApplication] keyWindow].bounds.size];
    self.backgroundColor = [UIColor colorWithPatternImage:bgImage];
  }else{
    self.backgroundColor = [prefs colorForKey:@"tableColor"];
  }
}
%end
/*
 _                _       _       _     _
| |              (_)     / \     | |   | |
| |    _   _  ___ _     /  \   __| | __| | ___  _ __  ___
| |   | | | |/ __| |   / /\ \ / _` |/ _` |/ _ \| '_ \/ __|
| |___| |_| | (__| |  / ____ \ (_| | (_| | (_) | | | \__ \
|______\__,_|\___|_| /_/    \_\__,_|\__,_|\___/|_| |_|___/

*/
//Removes Icons from Everything



%hook PSTableCell
- (void)setIcon:(id)arg1 {
  //Yes This way makes no sense. Leave me alone
  if(![prefs boolForKey:@"hideIcons"]){
    //return Nothing
    return %orig;
  }else{
    //Other wise be Normal
    nil;
  }
}
%end
//This one removes 3rd party icons, probably wont use, but is useful

//cleansettings
BOOL enabled = YES;
BOOL shouldIgnoreRules = YES;
CGFloat inset = 16.0; //the indent
CGFloat customCornerRadius = 10;

/* indent the table view */
%hook UITableView

/* iOS 6 - 11.1.2 */
- (UIEdgeInsets)_sectionContentInset {
    if([prefs boolForKey:@"CleanSettings"]) {
        UIEdgeInsets orig = %orig;
        if (!shouldIgnoreRules && (orig.left > 0 || orig.right > 0))
        return orig;
        return UIEdgeInsetsMake(orig.top, inset, orig.bottom, inset);
    }
    else {return %orig;}
}

/* iOS 6 - 11.1.2 */
- (void)_setSectionContentInset:(UIEdgeInsets)insets {
    if([prefs boolForKey:@"CleanSettings"]) {
        if (enabled && shouldIgnoreRules)
        %orig(UIEdgeInsetsMake(insets.top, inset, insets.bottom, inset));
        else
        %orig;
    }
    else {%orig;}
}
/* Remove separator lines
* (iOS 6 - 11.1.2)
*/
-(void)setDelegate:(id)arg1 {
    if([prefs boolForKey:@"CleanSettings"]) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        %orig;
    }
    else {%orig;}
}

%end

/* rounded corners */

@interface UIGroupTableViewCellBackground : UIView
@end

%group iOS11
%hook UIGroupTableViewCellBackground
/* iOS 11+ */

-(void)didMoveToSuperview {
    %orig;
    if([prefs boolForKey:@"CleanSettings"]){
      self.layer.shadowRadius = /*default 3*/ 1;
      self.layer.shadowOpacity = 0.5;//zoop
      self.layer.shadowOffset = CGSizeMake(0, 0); //negative y is the top, positive bottom
    }else{
      %orig;
    }

}

+(id)_roundedRectBezierPathInRect:(CGRect)arg1 withSectionLocation:(int)arg2 sectionCornerRadius:(double)arg3 cornerRadiusAdjustment:(double)arg4 sectionBorderWidth:(double)arg5 forBorder:(BOOL)arg6 {
    if([prefs boolForKey:@"CleanSettings"]) {
        arg4 = customCornerRadius;
        return %orig;
    }else {
      return %orig;
    }
}
%end
%end

/* TODO:

- add subtle backdrop shadow behind the tableView to make it look cleaner and much better
- add prefs so the user can change anything they want

*/


/*
_____ _
|  __ (_)
| |__) | _ __
|  ___/ | '_ \
| |   | | | | |
|_|   |_|_| |_|

              */
%hook DevicePINPane
@interface DevicePINPane : UIView
@end
-(void)didMoveToWindow{
  %orig;
  if(![prefs boolForKey:@"enableImage"]){
    self.backgroundColor = [prefs colorForKey:@"tableColor"];
  }else{
    self.backgroundColor = [UIColor blackColor];
  }

}
%end

%hook PSBulletedPINView
@interface PSBulletedPINView : UIView
@end
-(void)didMoveToWindow{
  %orig;
  if(![prefs boolForKey:@"enableImage"]){
    self.backgroundColor = [prefs colorForKey:@"tableColor"];
  }else{
    //self.backgroundColor =
    UIImage *bgImage = [[UIImage imageWithData:tableImage] imageScaledToSize:[[UIApplication sharedApplication] keyWindow].bounds.size];
    self.backgroundColor = [UIColor colorWithPatternImage:bgImage];//[[UIImageView alloc] initWithImage: bgImage];
  }
}
%end
%hook PSPasscodeField
@interface PSPasscodeField : UIView
@property (nonatomic, strong) UIColor *foregroundColor;
@end
-(void)didMoveToWindow{
  %orig;
  self.foregroundColor = [prefs colorForKey:@"textTint"];
}
%end

%ctor{
  //Cleansettings
  %init(_ungrouped); //for all other code that isn't grouped
  if (kCFCoreFoundationVersionNumber > 1443)
  %init(iOS11);
  //End CleanSettings
  notificationCallback(NULL, NULL, NULL, NULL, NULL);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
    NULL,
    notificationCallback,
    (CFStringRef)nsNotificationString,
    NULL,
    CFNotificationSuspensionBehaviorCoalesce);
  }
