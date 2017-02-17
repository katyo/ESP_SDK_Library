# Serial port setup
PORT ?= /dev/ttyUSB0
BAUD ?= 230400

# Base path to build root
libsdk.BASEPATH := $(subst $(dir $(abspath $(CURDIR)/xyz)),,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

libsdk.INCDIR := $(libsdk.BASEPATH)include
libsdk.SRCDIR := $(libsdk.BASEPATH)src
libsdk.LDDIR := $(libsdk.BASEPATH)ld
libsdk.MKDIR := $(libsdk.BASEPATH)rules
libsdk.EXAMPLEDIR := $(libsdk.BASEPATH)example

include $(libsdk.MKDIR)/macro.mk
include $(libsdk.MKDIR)/build.mk
include $(libsdk.MKDIR)/image.mk
include $(libsdk.MKDIR)/option.mk
include $(libsdk.MKDIR)/stalin.mk
-include config.mk

option-wrap.ipv4 = IP4_UINT($(1))
option-wrap.mac = {$(1)}
