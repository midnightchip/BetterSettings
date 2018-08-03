#import "UIImage+ScaledImage.h"
#import <PrefixUI/PrefixUI.h>
#import <UIKit/UIKit.h>



#define rgb(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]

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

    self.backgroundColor = [UIColor blackColor];
    self.foregroundColor = [UIColor greenColor];
}

%end
//Normal iPhone
%hook UIStatusBar

@interface UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

-(void)layoutSubviews {
    %orig;
    self.foregroundColor = [UIColor greenColor];
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
  self.backgroundColor = [UIColor clearColor];
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
    [self setBackgroundColor:[UIColor clearColor]];

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
  %orig([UIColor clearColor]);
}
%end
//Stupid Fix for Cephi atm, until something better comes about, Clear for background, color otherwise
%hook PSKeyboardNavigationSearchBar
- (void) setBackgroundColor:(UIColor *)color {
  %orig([UIColor clearColor]);
  //self.alpha = .3;
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
  self.textColor = [UIColor whiteColor];
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
  [self.layer setCornerRadius:12];
  //Background Color of Corners
  [self setBackgroundColor: rgb(38, 37, 42)];

  //Border Color and Width
  [self.layer setBorderColor:[UIColor blackColor].CGColor];
  [self.layer setBorderWidth:3];
  //Set Text Color
  self.textLabel.textColor = [UIColor whiteColor];
  self.detailTextLabel.textColor = [UIColor whiteColor];
  self.clipsToBounds = YES;
  MSHookIvar<UIColor*>(self, "_selectionTintColor") = [UIColor blackColor];
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
  UIImage *bgImage = [[UIImage imageWithContentsOfFile: @"/User/Documents/good.jpg"] imageScaledToSize:[UIScreen mainScreen].bounds.size];
  self.backgroundView = [[UIImageView alloc] initWithImage: bgImage];
}
%end

//Globally fix the UILabel text (for the most part)
//TODO fix UIAlert
%hook UILabel
-(void)layoutSubviews{
  %orig;
  self.textColor = [UIColor whiteColor];
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
  self.backgroundColor = rgb(38, 37, 42);
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
  [lock setTintColor:[UIColor whiteColor]];
  //Wifi Glyph
  UIImageView *wifi = MSHookIvar<UIImageView*>(self, "_signalImageView");
  wifi.image = [wifi.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [wifi setTintColor:[UIColor whiteColor]];

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
  //return nothing or nil;
    //if(RemoveSettingsIcons){
    //}
    //else {%orig;}
    nil;
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
