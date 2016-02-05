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

include $(BASEPATH)rules.mk
include $(BASEPATH)image.mk
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
  -ex 'set remotebaud $(GDBBAUD)' \
  -ex 'target remote $(GDBPORT)'

loader.CSTD ?= $(firmware.CSTD)
loader.COPT ?= $(firmware.COPT)
loader.CDBG ?= $(firmware.CDBG)
loader.CWARN ?= $(firmware.CWARN)
loader.COPTS ?= $(firmware.COPTS)
loader.CMACH ?= $(firmware.CMACH)
loader.CDIRS ?= $(firmware.CDIRS)

USE_LOADER ?= y

USE_ESPCONN ?= n
USE_MAX_IRAM ?= 48
STARTUP_CPU_CLK ?= 160
USE_OPEN_LWIP ?= y
USE_OPEN_DHCPS ?= y
USE_US_TIMER ?= y
USE_OPTIMIZE_PRINTF ?= y

DEBUG_UART ?= 1
DEBUG_LEVEL ?= 2
UART0_BAUD ?= 230400
UART1_BAUD ?= 230400

WITH_EXAMPLES ?= y
WITH_EX_DUMMY_APP ?= $(WITH_EXAMPLES)
WITH_EX_MEM_USAGE ?= $(WITH_EXAMPLES)
WITH_EX_TCP_ECHO ?= $(WITH_EXAMPLES)

ifneq (,$(SDK_NAME))
  firmware.CDEFS += SDK_NAME_STR='"$(SDK_NAME)"'
endif

ifneq (,$(DEBUG_UART))
  firmware.CDEFS += DEBUG_UART=$(DEBUG_UART)
endif

ifneq (,$(DEBUG_LEVEL))
  firmware.CDEFS += DEBUGSOO=$(DEBUG_LEVEL)
endif

ifneq (,$(UART0_BAUD))
  firmware.CDEFS += DEBUG_UART0_BAUD=$(UART0_BAUD)
endif

ifneq (,$(UART1_BAUD))
  firmware.CDEFS += DEBUG_UART1_BAUD=$(UART1_BAUD)
endif

ifeq (y,$(USE_ESPCONN))
  firmware.CDEFS += USE_ESPCONN
endif

ifneq (,$(USE_MAX_IRAM))
  firmware.CDEFS += USE_MAX_IRAM=$(USE_MAX_IRAM)
endif

ifneq (,$(STARTUP_CPU_CLK))
  firmware.CDEFS += STARTUP_CPU_CLK=$(STARTUP_CPU_CLK)
endif

ifeq (y,$(USE_US_TIMER))
  firmware.CDEFS += USE_US_TIMER
endif

ifeq (y,$(USE_OPTIMIZE_PRINTF))
  firmware.CDEFS += USE_OPTIMIZE_PRINTF
endif

ifeq (y,$(USE_OPEN_LWIP))
  libsdk.DEPLIBS += liblwip
  firmware.CDEFS += \
    USE_OPEN_LWIP \
    PBUF_RSV_FOR_WLAN \
    LWIP_OPEN_SRC \
    EBUF_LWIP
  ifneq (,$(LWIP_DEBUG))
    firmware.CDEFS += \
      LWIP_DEBUG \
      LWIP_DBG_TYPES_ON='(LWIP_DBG_ON|LWIP_DBG_TRACE|LWIP_DBG_STATE|LWIP_DBG_FRESH)' \
      $(patsubst %,%_DEBUG='(LWIP_DBG_LEVEL_ALL|LWIP_DBG_ON)',$(LWIP_DEBUG))
  endif
else
  libsdk.SDKLIBS += \
    liblwipif \
    liblwip
endif

ifeq (y,$(USE_OPEN_DHCPS))
  firmware.CDEFS += USE_OPEN_DHCPS
else
  libsdk.SDKLIBS += libdhcps
endif

POINT_CHAR := .
COMMA_CHAR := ,
IP4_ADDR = 'IP4_UINT($(subst $(POINT_CHAR),$(COMMA_CHAR),$(1)))'

ifneq (,$(SOFTAP_GATEWAY))
  firmware.CDEFS += SOFTAP_GATEWAY=$(call IP4_ADDR,$(SOFTAP_GATEWAY))
endif

ifneq (,$(SOFTAP_IP_ADDR))
  firmware.CDEFS += SOFTAP_IP_ADDR=$(call IP4_ADDR,$(SOFTAP_IP_ADDR))
endif

ifneq (,$(SOFTAP_NETMASK))
  firmware.CDEFS += SOFTAP_NETMASK=$(call IP4_ADDR,$(SOFTAP_NETMASK))
endif

ifeq (y,$(NO_ESP_CONFIG))
  firmware.CDEFS += NO_ESP_CONFIG
endif

ifeq (y,$(USE_LOADER))
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

ifeq (y,$(DEBUG))
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

ifeq (y,$(DEBUG_EXCEPT))
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

ifneq (y,$(USE_STDLIBS))
  libsdk.SDKLIBS += libgcc
endif

libsdk.DEPLIBS += \
  libaddmain \
  libaddphy \
  libaddpp \
  libaddwpa \
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

ifeq (y,$(USE_STDLIBS))
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
# (don't used when NO_ESP_CONFIG is y)
ifneq (y,$(NO_ESP_CONFIG))
  TARGET.RDIS += blank
  clear.IMGS += blank
  blank.INHERIT = rawimg
  blank.SRCS += $(SRCDIR)/bin/blank.c
  blank.ADDR ?= 0x7E000
endif

# Provide rules
$(foreach lib,$(TARGET.LIBS),$(eval $(call LIB_RULES,$(lib))))
$(foreach rdi,$(TARGET.RDIS),$(eval $(call RDI_RULES,$(rdi))))
$(foreach ldr,$(TARGET.LDRS),$(eval $(call LDR_RULES,$(ldr))))
$(foreach img,$(TARGET.IMGS),$(eval $(call IMG_RULES,$(img))))
