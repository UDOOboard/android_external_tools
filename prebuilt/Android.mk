# Prebuilt APK
# - Stability Test - not included in automatic compilation

LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

# Stability Test
include $(CLEAR_VARS)

LOCAL_MODULE := StabilityTest
LOCAL_MODULE_TAGS := optional
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_PATH := $(TARGET_OUT_APPS)
LOCAL_SRC_FILES := $(LOCAL_MODULE).apk
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_REQUIRED_MODULES := libstabilitytest.so

include $(BUILD_PREBUILT)

# Stability Test library, it is required a separate installation
include $(CLEAR_VARS)

LOCAL_MODULE := libstabilitytest.so
LOCAL_MODULE_TAGS := optional
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)
LOCAL_SRC_FILES := $(LOCAL_MODULE)

include $(BUILD_PREBUILT)

# additionally, build unit tests in a separate .apk
include $(call all-makefiles-under,$(LOCAL_PATH))
