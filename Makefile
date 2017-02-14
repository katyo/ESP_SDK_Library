# Compiler
COMPILER_NAME ?= xtensa-lx106-elf-

# Serial port setup
PORT ?= /dev/ttyUSB0
BAUD ?= 230400

# Base path to build root
BASEPATH := $(subst $(dir $(abspath $(CURDIR)/xyz)),,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

INCDIR := $(BASEPATH)include
SRCDIR := $(BASEPATH)src
EXDIR := $(BASEPATH)example
LDDIR := $(BASEPATH)ld
MKDIR := $(BASEPATH)rules

include $(MKDIR)/macro.mk
include $(MKDIR)/build.mk
include $(MKDIR)/image.mk
include $(MKDIR)/option.mk
include $(MKDIR)/stalin.mk
-include config.mk

firmware.INHERIT := stalin
#firmware.CSTD ?= gnu90
#firmware.CWARN ?= all extra no-pointer-sign undef pointer-arith error
#firmware.COPTS ?= function-sections data-sections no-inline-functions
firmware.COPTS ?= no-tree-ccp optimize-register-move
firmware.CMACH ?= no-target-align no-serialize-volatile longcalls text-section-literals
firmware.CDIRS ?= $(INCDIR)

GDBBAUD ?= $(BAUD)
GDBPORT ?= $(PORT)
firmware.GDBOPTS += \
  -ex 'set remote hardware-breakpoint-limit 1' \
  -ex 'set remote hardware-watchpoint-limit 1' \
  -ex 'set debug xtensa 4' \
  -ex 'set serial baud $(GDBBAUD)' \
  -ex 'target remote $(GDBPORT)'

loader.CSTD ?= $(firmware.CSTD)
loader.COPT ?= $(firmware.COPT)
loader.CDBG ?= $(firmware.CDBG)
loader.CWARN ?= $(firmware.CWARN)
loader.COPTS ?= $(firmware.COPTS)
loader.CMACH ?= $(firmware.CMACH)
loader.CDIRS ?= $(firmware.CDIRS)

TARGET.OPTS += libsdk
libsdk.OPTS := $(SRCDIR)/sdk.cf

$(call ADDRULES,\
OPT_RULES:TARGET.OPTS)

firmware.CDEFS += \
  ESP8266 \
	LWIP_RAW=1 \
  USE_OPEN_LWIP \
  USE_OPEN_DHCPS \
  USE_OPEN_DHCPC \
  PBUF_RSV_FOR_WLAN \
  LWIP_OPEN_SRC \
  EBUF_LWIP \
	$(if $(call option-true,$(espsdk.debug.lwip)), \
  LWIP_DBG_TYPES_ON='(LWIP_DBG_ON|LWIP_DBG_TRACE|LWIP_DBG_STATE|LWIP_DBG_FRESH)' \
  $(patsubst %,%_DEBUG='(LWIP_DBG_LEVEL_ALL|LWIP_DBG_ON)',$(espsdk.debug.lwip.parts)))

LOADER ?= $(if $(call option-true,$(espsdk.use_loader)),rapid_loader)

TARGET.LIBS += librapid_loader
librapid_loader.INHERIT = loader
librapid_loader.CDEFS += __ets__
librapid_loader.SRCS += \
  $(SRCDIR)/loader/loader.c \
  $(SRCDIR)/loader/loader_flash_boot.S

TARGET.LDRS += rapid_loader
rapid_loader.INHERIT = librapid_loader
rapid_loader.DEPLIBS += librapid_loader

TARGET.LIBS += liblwipapi
liblwipapi.INHERIT = liblwip
liblwipapi.SRCS = $(wildcard $(SRCDIR)/lwip/api/*.c)

TARGET.LIBS += liblwipapp
liblwipapp.INHERIT = liblwip
liblwipapp.SRCS = $(wildcard $(SRCDIR)/lwip/app/*.c)

TARGET.LIBS += liblwipcore
liblwipcore.INHERIT = liblwip
liblwipcore.SRCS = $(wildcard $(SRCDIR)/lwip/core/*.c)

TARGET.LIBS += liblwipipv4
liblwipipv4.INHERIT = liblwip
liblwipipv4.SRCS = $(wildcard $(SRCDIR)/lwip/core/ipv4/*.c)

TARGET.LIBS += liblwipnetif
liblwipnetif.INHERIT = liblwip
liblwipnetif.SRCS = $(wildcard $(SRCDIR)/lwip/netif/*.c)

TARGET.LIBS += liblwip
liblwip.INHERIT = libsdk
liblwip.DEPLIBS* += \
  liblwipapi \
  liblwipapp \
  liblwipcore \
  liblwipipv4 \
  liblwipnetif

TARGET.LIBS += libphy
libphy.INHERIT = libsdk
libphy.SRCS = $(wildcard $(SRCDIR)/phy/*.c)
libphy.OBJS = $(wildcard $(SRCDIR)/phy/blob/*.o)

TARGET.LIBS += libpp
libpp.INHERIT = libsdk
libpp.SRCS = $(wildcard $(SRCDIR)/pp/*.c)
libpp.OBJS = $(wildcard $(SRCDIR)/pp/blob/*.o)

TARGET.LIBS += libmain
libmain.INHERIT = libsdk
libmain.SRCS = $(wildcard $(addprefix $(SRCDIR)/,system/*.c bin/esp_init_data_default.c))
libmain.OBJS = $(wildcard $(SRCDIR)/system/blob/*.o)

TARGET.LIBS += libwpa
libwpa.INHERIT = libsdk
libwpa.SRCS = $(wildcard $(SRCDIR)/wpa/*.c)
libwpa.OBJS = $(wildcard $(SRCDIR)/wpa/blob/*.o)

TARGET.LIBS += libnet80211
libnet80211.INHERIT = libsdk
libnet80211.SRCS = $(wildcard $(SRCDIR)/net80211/*.c)
libnet80211.OBJS = $(wildcard $(SRCDIR)/net80211/blob/*.o)

TARGET.LIBS += libaxtls
libaxtls.INHERIT = libsdk
libaxtls.SRCS += $(addprefix $(SRCDIR)/axtls/, \
  $(addprefix crypto/, \
    aes.c \
    bigint.c \
    md2.c \
    rc4.c \
    rsa.c \
    misc.c) \
  $(addprefix replacements/, \
    time.c) \
  $(addprefix ssl/, \
    default.c \
    asn1.c \
    gen_cert.c \
    loader.c \
    os_port.c \
    p12.c \
    tls1.c \
    tls1_clnt.c \
    tls1_svr.c \
    x509.c) \
  $(addprefix compat/, \
    lwipr_compat.c))
AXTLS_CERT_PKEY_H := $(addprefix $(SRCDIR)/axtls/ssl/,cert.h private_key.h)
$(SRCDIR)/axtls/ssl/default.c: $(AXTLS_CERT_PKEY_H)
$(AXTLS_CERT_PKEY_H):
	@echo GEN SSL CERT/PKEY
	$(Q)$(SRCDIR)/axtls/tools/make_certs.sh
clean: clean.ssl_certs
clean.ssl_certs:
	@echo CLEAN SSL CERT/PKEY
	$(Q)rm -f $(AXTLS_CERT_PKEY_H)

TARGET.LIBS += libgdbstub
libgdbstub.INHERIT = libsdk
libgdbstub.SRCS += $(wildcard $(addprefix $(SRCDIR)/gdbstub/*.,c S))

TARGET.LIBS += libsdk
libsdk.INHERIT = firmware
libsdk.DEPLIBS* += \
  libmain \
  libphy \
  libpp \
  libwpa \
  libnet80211 \
  liblwip \
  libaxtls \
  libgdbstub

# Application
firmware.LDDIRS += $(LDDIR)
firmware.LDSCRIPT ?= $(LDDIR)/eagle.app.v6.ld
firmware.LDSCRIPTS ?= $(firmware.LDSCRIPT) $(LDDIR)/eagle.rom.addr.v6.ld
firmware.LDOPTS ?= EL -gc-sections -no-check-sections -wrap=os_printf_plus static
firmware.LDFLAGS += -nostartfiles -nodefaultlibs -nostdlib

loader.LDDIRS += $(firmware.LDDIRS)
loader.LDSCRIPT ?= $(LDDIR)/eagle.app.v6-loader.ld
loader.LDSCRIPTS ?= $(loader.LDSCRIPT) $(LDDIR)/eagle.rom.addr.v6.ld
loader.LDOPTS ?= -no-check-sections static
loader.UNDEFS ?= call_user_start loader_flash_boot
loader.LDFLAGS ?= -nostdlib

#ifneq (,$(call option-true,$(espsdk.use_stdlibs)))
firmware.LDLIBS += $(addprefix -l,c m gcc)
#endif

example.INHERIT = firmware

define EXAMPLE_RULES
TARGET.LIBS += example/lib$(1)
example/lib$(1).INHERIT = example
example/lib$(1).SRCS += $$(wildcard $(EXDIR)/$(1)/*.c)

TARGET.IMGS += example/$(1)
example/$(1).INHERIT = example/lib$(1)
example/$(1).DEPLIBS = example/lib$(1)
example/$(1).DEPLIBS* = libsdk
endef

$(foreach e,$(espsdk.with_examples),$(eval $(call EXAMPLE_RULES,$(e))))

# Image
rawimg.INHERIT = firmware

# Program codes IRAM/RAM
IMG1.ADDR ?= 0x00000

 # Program codes Cache Flash
IMG2.ADDR ?= 0x07000

# The RTC EEPROM data
TARGET.RDIS += clear_eep
clear.IMGS += clear_eep
clear_eep.INHERIT = rawimg
clear_eep.SRCS += $(SRCDIR)/bin/clear_eep.c
clear_eep.ADDR ?= 0x79000

# RF SDK options
TARGET.RDIS += esp_init_data_default
clear.IMGS += esp_init_data_default
esp_init_data_default.INHERIT = rawimg
esp_init_data_default.SRCS += $(SRCDIR)/bin/esp_init_data_default.c
esp_init_data_default.ADDR ?= 0x7C000

# Default SDK WiFi config
TARGET.RDIS += blank
clear.IMGS += blank
blank.INHERIT = rawimg
blank.SRCS += $(SRCDIR)/bin/blank.c
blank.ADDR ?= 0x7E000

# Provide rules
$(call ADDRULES,\
LIB_RULES:TARGET.LIBS\
RDI_RULES:TARGET.RDIS\
LDR_RULES:TARGET.LDRS\
IMG_RULES:TARGET.IMGS)
