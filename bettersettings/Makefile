include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BetterSettings
BetterSettings_FILES = BSPPreferenceController.m
BetterSettings_INSTALL_PATH = /Library/PreferenceBundles
BetterSettings_FRAMEWORKS = UIKit 
BetterSettings_PRIVATE_FRAMEWORKS = Preferences
BetterSettings_LIBRARIES = imagepicker
BetterSettings_CFLAGS += -fobjc-arc
BetterSettings_LDFLAGS +=  -lCSPreferences -lCSColorPicker -lCSPUtilities

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BetterSettings.plist$(ECHO_END)
