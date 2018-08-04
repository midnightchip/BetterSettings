include $(THEOS)/makefiles/common.mk

TWEAK_NAME = rewriteSettings
rewriteSettings_FILES = Tweak.xm UIImage+ScaledImage.m BSprovider.m
rewriteSettings_PRIVATE_FRAMEWORKS = WiFiKitUI
rewriteSettings_EXTRA_FRAMEWORKS = PrefixUI
rewriteSettings_LIBRARIES = imagepicker
rewriteSettings_CFLAGS +=  -fobjc-arc
rewriteSettings_LDFLAGS += -lCSColorPicker -lCSPreferencesProvider

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += bettersettings
include $(THEOS_MAKE_PATH)/aggregate.mk
