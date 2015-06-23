#Konrad Eisele<eiselekd@web.de>,2004

targets = arm 
arm_target  = .dummy
arm_subdirs = arm

TARGET_arm=y
-include .config

BUILD_DIR=arm
ifeq ($(TARGET_sparc),y)
BUILD_DIR=sparc
else
endif 

switchtarget:
	-$(MAKE) -f build/Makefile.switch obj=soft/tbenchsoft/$(BUILD_DIR) dobuild

