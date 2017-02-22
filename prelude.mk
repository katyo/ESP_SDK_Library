# Serial port setup
PORT ?= /dev/ttyUSB0
BAUD ?= 230400

# Base path to build root
espsdk.BASEPATH := $(subst $(dir $(abspath $(CURDIR)/xyz)),,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

espsdk.INCDIR := $(espsdk.BASEPATH)include
espsdk.SRCDIR := $(espsdk.BASEPATH)src
espsdk.LDDIR := $(espsdk.BASEPATH)ld
espsdk.MKDIR := $(espsdk.BASEPATH)rules
espsdk.EXAMPLEDIR := $(espsdk.BASEPATH)example

include $(espsdk.MKDIR)/macro.mk
include $(espsdk.MKDIR)/build.mk
include $(espsdk.MKDIR)/image.mk
include $(espsdk.MKDIR)/option.mk
include $(espsdk.MKDIR)/stalin.mk
include $(espsdk.MKDIR)/ssl.mk
-include config.mk
