export ARCHS= armv7 arm64
export TARGET=iphone:latest:4.3
SDKVERSION = 7.0

include theos/makefiles/common.mk

TWEAK_NAME = InboxCount
InboxCount_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileMail"
