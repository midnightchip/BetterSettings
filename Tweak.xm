#import "UIImage+ScaledImage.h"
#import <PrefixUI/PrefixUI.h>
#import <UIKit/UIKit.h>
#include <CSColorPicker/CSColorPicker.h>
#import <libimagepicker.h>
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
static NSString *imagePlist = @"com.midnightchips.bettersettings.image";
static NSString *nsNotificationString = @"com.midnightchips.bettersettings.prefschanged";
static NSString *nsPrefPlistPath = @"/User/Library/Preferences/com.midnightchips.bettersettings.plist";

static NSString *statusColor;
static NSString *tableColor;
static NSString *bubbleColor;
static NSString *borderColor;
static NSString *bubbleSelectionColor;
static NSString *navTint;
static NSString *textTint;

static float cornerRadius;
static float borderWidth;

static BOOL enableImage;
static BOOL tintNav;
static BOOL enableBubbles;
static BOOL hideIcons;
static BOOL adaptiveColor;

static UIImage *textImage;
static NSData *tableImage;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  //Colors
  NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:nsPrefPlistPath] ? : [NSDictionary new];
  statusColor = prefs[@"statusColor"];
  tableColor = prefs[@"tableColor"];
  bubbleColor = prefs[@"bubbleColor"];
  borderColor = prefs[@"borderColor"];
  navTint = prefs[@"navTint"];
  textTint = prefs[@"textTint"];

  bubbleSelectionColor = prefs[@"bubbleSelectionColor"];
  enableImage = prefs[@"enableImage"] ? [prefs[@"enableImage"]  boolValue] : NO;
  enableBubbles = prefs[@"enableBubbles"] ? [prefs[@"enableBubbles"]  boolValue] : NO;
  tintNav = prefs[@"tintNav"] ? [prefs[@"tintNav"]  boolValue] : NO;
  hideIcons = prefs[@"hideIcons"] ? [prefs[@"hideIcons"]  boolValue] : NO;
  adaptiveColor = prefs[@"adaptiveColor"] ? [prefs[@"adaptiveColor"]  boolValue] : NO;

  cornerRadius = [prefs[@"cornerRadius"] floatValue];
  borderWidth = [prefs[@"borderWidth"] floatValue];

  NSData *tImage = (NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundImage" inDomain:imagePlist];
  tableImage = tImage;
}
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

    self.backgroundColor = [UIColor colorFromHexString:statusColor];
    self.foregroundColor = [UIColor colorFromHexString:statusColor];
}

%end
//Normal iPhone
%hook UIStatusBar

@interface UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

-(void)layoutSubviews {
    %orig;
    self.foregroundColor = [UIColor colorFromHexString:statusColor];
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
  if (enableImage){
    if(tintNav){
      self.backgroundColor = [UIColor colorFromHexString:navTint];
    }else{
      self.backgroundColor = [UIColor clearColor];
    }

  }else {
    self.backgroundColor = [UIColor colorFromHexString:tableColor];
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
    self.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

    //Tints the Buttons
    self.tintColor = [UIColor greenColor];

    //Hide background Image of NavBar, Makes black/ background image stand out
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    //Set BackgroundColor of NavBar, clear for backgroundImage
    if(enableImage){
      if(tintNav){
        [self setBackgroundColor:[UIColor colorFromHexString:navTint]];
      }else{
        [self setBackgroundColor:[UIColor clearColor]];
      }

    }else{
      [self setBackgroundColor:[UIColor colorFromHexString:tableColor]];
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
  if(enableImage){
    if(tintNav){
      %orig([UIColor colorFromHexString:navTint]);
    }else{
      %orig([UIColor clearColor]);
    }

  }else{
    %orig([UIColor colorFromHexString:tableColor]);
  }

}
%end
//Stupid Fix for Cephi atm, until something better comes about, Clear for background, color otherwise
%hook PSKeyboardNavigationSearchBar
- (void) setBackgroundColor:(UIColor *)color {
  if(enableImage){
    if(tintNav){
      %orig([UIColor colorFromHexString:navTint]);
    }else{
      %orig([UIColor clearColor]);
    }

  }else{
    %orig([UIColor colorFromHexString:tableColor]);
  }
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
  if(adaptiveColor){
    UIImage *textImage = [UIImage imageWithData:tableImage];
    UIColor *avgColor = imageAverageColor(textImage);
    self.textColor = avgColor;
  }else{
    self.textColor = [UIColor colorFromHexString:textTint];
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
    [self.layer setCornerRadius:cornerRadius];

    [self setBackgroundColor: [UIColor colorFromHexString: bubbleColor]];//rgb(38, 37, 42)];
    //Border Color and Width
    [self.layer setBorderColor:[UIColor colorFromHexString: borderColor].CGColor];
    [self.layer setBorderWidth:borderWidth];

    //Set Text Color
    if(adaptiveColor){
      UIImage *textImage = [UIImage imageWithData:tableImage];
      UIColor *avgColor = imageAverageColor(textImage);
      self.textLabel.textColor = avgColor;
      self.detailTextLabel.textColor = avgColor;
    }else{
      self.textLabel.textColor = [UIColor colorFromHexString:textTint];
      self.detailTextLabel.textColor = [UIColor colorFromHexString:textTint];
    }

    self.clipsToBounds = YES;
    MSHookIvar<UIColor*>(self, "_selectionTintColor") = [UIColor colorFromHexString:bubbleSelectionColor];



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
  if(enableImage){              //TODO CHANGE THE IMAGE TO PICKING AN IMAGE
    UIImage *bgImage = [[UIImage imageWithData:tableImage] imageScaledToSize:[[UIApplication sharedApplication] keyWindow].bounds.size];
    self.backgroundView = [[UIImageView alloc] initWithImage: bgImage];
  }else{
    self.backgroundColor = [UIColor colorFromHexString:tableColor];
  }

}
%end

//Globally fix the UILabel text (for the most part)
//TODO fix UIAlert
%hook UILabel
-(void)layoutSubviews{
  %orig;
  if(adaptiveColor){
    UIImage *textImage = [UIImage imageWithData:tableImage];
    UIColor *avgColor = imageAverageColor(textImage);
    self.textColor = avgColor;
  }else{
    self.textColor = [UIColor colorFromHexString:textTint];
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
  if(enableImage){
    self.backgroundColor = [UIColor clearColor];//rgb(38, 37, 42);
  }else{
    self.backgroundColor = [UIColor colorFromHexString:bubbleColor];
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
  [lock setTintColor:[UIColor colorFromHexString:textTint]];
  //Wifi Glyph
  UIImageView *wifi = MSHookIvar<UIImageView*>(self, "_signalImageView");
  wifi.image = [wifi.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [wifi setTintColor:[UIColor colorFromHexString:textTint]];

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
  if(!hideIcons){
    //return Nothing
    return %orig;
  }else{
    //Other wise be Normal
    nil;
  }
}
%end
//This one removes 3rd party icons, probably wont use, but is useful
/*%hook PSUIPrefsListController
- (void)_reallyLoadThirdPartySpecifiersForApps:(id)arg1 withCompletion:(id)arg2 {
    if(Remove3rdPartyAppsiNSettings){
        arg1 = NULL;
        arg2 = NULL;
        %orig;
    }
    else {%orig;}
}
%end*/

%ctor{
  notificationCallback(NULL, NULL, NULL, NULL, NULL);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
    NULL,
    notificationCallback,
    (CFStringRef)nsNotificationString,
    NULL,
    CFNotificationSuspensionBehaviorCoalesce);
  }
