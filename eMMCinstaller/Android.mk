
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_DEX_PREOPT := false
LOCAL_MODULE_TAGS := optional

LOCAL_SRC_FILES := $(call all-java-files-under, src) 
LOCAL_RESOURCE_DIR := $(LOCAL_PATH)/res

LOCAL_PACKAGE_NAME := eMMCinstaller
LOCAL_MODULE_PATH := $(TARGET_OUT_APPS)

# LOCAL_CERTIFICATE := platform
LOCAL_PRIVILEGED_MODULE := true

include $(BUILD_PACKAGE)

