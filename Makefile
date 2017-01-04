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

include $(MKDIR)/rules.mk
include $(MKDIR)/image.mk
include $(MKDIR)/option.mk
-include config.mk

firmware.CSTD ?= gnu90
firmware.CWARN ?= all extra no-pointer-sign undef pointer-arith error
firmware.COPTS ?= no-tree-ccp optimize-register-move no-inline-functions function-sections data-sections
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

firmware.OPTS += \
  OPT:USE_LOADER:y \
  OPT:USE_ESPCONN:n \
  VAL:USE_MAX_IRAM:48 \
  VAL:STARTUP_CPU_CLK:160 \
  OPT:USE_OPEN_LWIP:y \
  OPT:USE_OPEN_DHCPS:y \
  OPT:USE_US_TIMER:y \
  OPT:USE_OPTIMIZE_PRINTF:y \
  VAL:DEBUG_UART:1 \
  VAL:DEBUG_LEVEL:2 \
  VAL:DEBUG_UART0_BAUD:230400 \
  VAL:DEBUG_UART1_BAUD:230400 \
  STR:SDK_NAME \
  IP4:SOFTAP_GATEWAY \
  IP4:SOFTAP_IP_ADDR \
  IP4:SOFTAP_NETMASK \
  OPT:NO_ESP_CONFIG:n

TARGET.OPTS += firmware
$(foreach grp,$(TARGET.OPTS),$(foreach opt,$($(grp).OPTS),$(eval $(call OPT_RULES,$(grp),$(opt)))))

show.config:
$(foreach grp,$(TARGET.OPTS),$(foreach opt,$($(grp).OPTS),$(eval $(call OPT_SHOW,show.config,$(opt)))))

WITH_EXAMPLES ?= y
WITH_EX_DUMMY_APP ?= $(WITH_EXAMPLES)
WITH_EX_MEM_USAGE ?= $(WITH_EXAMPLES)
WITH_EX_TCP_ECHO ?= $(WITH_EXAMPLES)
WITH_EX_SSL_ECHO ?= $(WITH_EXAMPLES)

ifneq (,$(call OPT_OPT,USE_OPEN_LWIP))
  libsdk.DEPLIBS += liblwip
  firmware.CDEFS += \
    PBUF_RSV_FOR_WLAN \
    LWIP_OPEN_SRC \
    EBUF_LWIP
  ifneq (,$(call OPT_OPT,LWIP_DEBUG))
    firmware.CDEFS += \
      LWIP_DBG_TYPES_ON='(LWIP_DBG_ON|LWIP_DBG_TRACE|LWIP_DBG_STATE|LWIP_DBG_FRESH)' \
      $(patsubst %,%_DEBUG='(LWIP_DBG_LEVEL_ALL|LWIP_DBG_ON)',$(LWIP_DEBUG))
  endif
else
  libsdk.SDKLIBS += \
    liblwipif \
    liblwip
endif

ifeq (,$(call OPT_OPT,USE_OPEN_DHCPS))
  libsdk.SDKLIBS += libdhcps
endif

ifneq (,$(call OPT_OPT,USE_LOADER))
  LOADER ?= rapid_loader
endif

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
liblwip.DEPLIBS += \
  liblwipapi \
  liblwipapp \
  liblwipcore \
  liblwipipv4 \
  liblwipnetif

TARGET.LIBS += libaddphy
libaddphy.INHERIT = libsdk
libaddphy.SRCS = $(wildcard $(SRCDIR)/phy/*.c)

TARGET.LIBS += libaddpp
libaddpp.INHERIT = libsdk
libaddpp.SRCS = $(wildcard $(SRCDIR)/pp/*.c)

TARGET.LIBS += libaddmain
libaddmain.INHERIT = libsdk
libaddmain.SRCS = $(wildcard $(addprefix $(SRCDIR)/,system/*.c bin/esp_init_data_default.c))

TARGET.LIBS += libaddwpa
libaddwpa.INHERIT = libsdk
libaddwpa.SRCS = $(wildcard $(SRCDIR)/wpa/*.c)

TARGET.LIBS += libaxtls
libaxtls.INHERIT = libsdk
firmware.CDEFS += ESP8266 LWIP_RAW=1
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

ifneq (,$(call OPT_OPT,DEBUG))
  firmware.COPT ?= g
  firmware.CDBG ?= gdb3
  firmware.CDEFS += USE_DEBUG
  ifeq (y,$(DEBUG_BREAK))
    firmware.CDEFS += GDBSTUB_BREAK_ON_INIT=1
  endif
  libsdk.DEPLIBS += libgdbstub
  TARGET.LIBS += libgdbstub
  libgdbstub.INHERIT = libsdk
  libgdbstub.SRCS += $(wildcard $(addprefix $(SRCDIR)/gdbstub/*.,c S))
else
  firmware.COPT ?= s
  firmware.CDBG ?= gdb
endif

ifneq (,$(call OPT_OPT,DEBUG_EXCEPT))
  CDEFS += DEBUG_EXCEPTION
endif

TARGET.LIBS += libsdk
libsdk.INHERIT = firmware
libsdk.SDKLIBS += \
  libmain \
  libphy \
  libpp \
  libwpa \
  libnet80211

ifeq (,$(call OPT_OPT,USE_STDLIBS))
  libsdk.SDKLIBS += libgcc
endif

libsdk.DEPLIBS += \
  libaddmain \
  libaddphy \
  libaddpp \
  libaddwpa \
  libaxtls \
  $(addprefix esp/,$(libsdk.SDKLIBS))

# Application
firmware.LDDIRS += $(LDDIR)
firmware.LDSCRIPT ?= $(LDDIR)/eagle.app.v6.ld
firmware.LDSCRIPTS ?= $(firmware.LDSCRIPT) $(LDDIR)/eagle.rom.addr.v6.ld
firmware.LDOPTS ?= EL -gc-sections -no-check-sections -wrap=os_printf_plus static
firmware.UNDEFS ?= call_user_start
firmware.LDFLAGS += -nostartfiles -nodefaultlibs -nostdlib

loader.LDDIRS += $(firmware.LDDIRS)
loader.LDSCRIPT ?= $(LDDIR)/eagle.app.v6-loader.ld
loader.LDSCRIPTS ?= $(loader.LDSCRIPT) $(LDDIR)/eagle.rom.addr.v6.ld
loader.LDOPTS ?= -no-check-sections static
loader.UNDEFS ?= call_user_start loader_flash_boot
loader.LDFLAGS ?= -nostdlib

ifneq (,$(call OPT_OPT,USE_STDLIBS))
  firmware.LDLIBS += $(addprefix -l,c m gcc)
endif

example.INHERIT = firmware

ifeq (y,$(WITH_EX_DUMMY_APP))
  TARGET.LIBS += libdummy_app
  libdummy_app.INHERIT = example
  libdummy_app.SRCS += $(wildcard $(EXDIR)/dummy_app/*.c)

  TARGET.IMGS += dummy_app
  dummy_app.INHERIT = libdummy_app
  dummy_app.DEPLIBS += libsdk libdummy_app
endif

ifeq (y,$(WITH_EX_MEM_USAGE))
  TARGET.LIBS += libmem_usage
  libmem_usage.INHERIT = example
  libmem_usage.SRCS += $(wildcard $(EXDIR)/mem_usage/*.c)

  TARGET.IMGS += mem_usage
  mem_usage.INHERIT = libmem_usage
  mem_usage.DEPLIBS += libsdk libmem_usage
endif

ifeq (y,$(WITH_EX_TCP_ECHO))
  TARGET.LIBS += libtcp_echo
  libtcp_echo.INHERIT = example
  libtcp_echo.SRCS += $(wildcard $(EXDIR)/tcp_echo/*.c)

  TARGET.IMGS += tcp_echo
  tcp_echo.INHERIT = libtcp_echo
  tcp_echo.DEPLIBS += libsdk libtcp_echo
endif

ifeq (y,$(WITH_EX_SSL_ECHO))
  TARGET.LIBS += libssl_echo
  libssl_echo.INHERIT = example
  libssl_echo.SRCS += $(wildcard $(EXDIR)/ssl_echo/*.c)

  TARGET.IMGS += ssl_echo
  ssl_echo.INHERIT = libssl_echo
  ssl_echo.DEPLIBS += libsdk libssl_echo
endif

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
$(foreach lib,$(TARGET.LIBS),$(eval $(call LIB_RULES,$(lib))))
$(foreach rdi,$(TARGET.RDIS),$(eval $(call RDI_RULES,$(rdi))))
$(foreach ldr,$(TARGET.LDRS),$(eval $(call LDR_RULES,$(ldr))))
$(foreach img,$(TARGET.IMGS),$(eval $(call IMG_RULES,$(img))))
