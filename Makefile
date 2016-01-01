include rules.mk
include image.mk
-include config.mk

CFLAGS += -std=gnu90 -Os
CFLAGS += -Wall -Wno-pointer-sign
CFLAGS += -fno-tree-ccp -foptimize-register-move
CFLAGS += -mno-target-align -mno-serialize-volatile

CDEFS += ICACHE_FLASH

CFLAGS += -Wundef -Wpointer-arith -Werror
CFLAGS += -Wl,-EL -fno-inline-functions -nostdlib
CFLAGS += -mlongcalls -mtext-section-literals

CDIRS += include

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
UART0_BAUD ?= 115200
UART1_BAUD ?= 230400

WITH_EX_DUMMY_APP ?= y
WITH_EX_MEM_USAGE ?= y

ifneq (,$(DEBUG_UART))
  CDEFS += DEBUG_UART=$(DEBUG_UART)
endif

ifneq (,$(DEBUG_LEVEL))
  CDEFS += DEBUGSOO=$(DEBUG_LEVEL)
endif

ifneq (,$(UART0_BAUD))
  CDEFS += DEBUG_UART0_BAUD=$(UART0_BAUD)
endif

ifneq (,$(UART1_BAUD))
  CDEFS += DEBUG_UART1_BAUD=$(UART1_BAUD)
endif

ifeq (y,$(USE_ESPCONN))
  CDEFS += USE_ESPCONN
endif

ifneq (,$(USE_MAX_IRAM))
  CDEFS += USE_MAX_IRAM=$(USE_MAX_IRAM)
endif

ifneq (,$(STARTUP_CPU_CLK))
  CDEFS += STARTUP_CPU_CLK=$(STARTUP_CPU_CLK)
endif

ifeq (y,$(USE_US_TIMER))
  CDEFS += USE_US_TIMER
endif

ifeq (y,$(USE_OPTIMIZE_PRINTF))
  CDEFS += USE_OPTIMIZE_PRINTF
endif

ifeq (y,$(USE_OPEN_LWIP))
  libsdk.DEPLIBS += lwip/liblwip
  CDEFS += \
    USE_OPEN_LWIP \
    PBUF_RSV_FOR_WLAN \
    LWIP_OPEN_SRC \
    EBUF_LWIP
else
  libsdk.SDKLIBS += \
    liblwipif \
    libmlwip
endif

ifeq (y,$(USE_OPEN_DHCPS))
  CDEFS += USE_OPEN_DHCPS
else
  libsdk.SDKLIBS += libdhcps
endif

ifeq (y,$(USE_LOADER))
  LOADER ?= rapid_loader
endif

TARGET.LIBS += librapid_loader
librapid_loader.CDEFS += __ets__
librapid_loader.SRCS += \
  src/loader/loader.c \
  src/loader/loader_flash_boot.S

TARGET.IMGS += rapid_loader
rapid_loader.ISLOADER = y
rapid_loader.DEPLIBS += librapid_loader

TARGET.LIBS += lwip/api/liblwipapi
lwip/api/liblwipapi.SRCS = $(wildcard src/lwip/api/*.c)

TARGET.LIBS += lwip/app/liblwipapp
lwip/app/liblwipapp.SRCS = $(wildcard src/lwip/app/*.c)

TARGET.LIBS += lwip/core/liblwipcore
lwip/core/liblwipcore.SRCS = $(wildcard src/lwip/core/*.c)

TARGET.LIBS += lwip/core/ipv4/liblwipipv4
lwip/core/ipv4/liblwipipv4.SRCS = $(wildcard src/lwip/core/ipv4/*.c)

TARGET.LIBS += lwip/netif/liblwipnetif
lwip/netif/liblwipnetif.SRCS = $(wildcard src/lwip/netif/*.c)

TARGET.LIBS += lwip/liblwip
lwip/liblwip.DEPLIBS += \
  lwip/api/liblwipapi \
  lwip/app/liblwipapp \
  lwip/core/liblwipcore \
  lwip/core/ipv4/liblwipipv4 \
  lwip/netif/liblwipnetif

TARGET.LIBS += phy/libaddmphy
phy/libaddmphy.SRCS = $(wildcard src/phy/*.c)

TARGET.LIBS += pp/libaddpp
pp/libaddpp.SRCS = $(wildcard src/pp/*.c)

TARGET.LIBS += system/libaddmmain
system/libaddmmain.SRCS = $(wildcard src/system/*.c)

TARGET.LIBS += wpa/libaddwpa
wpa/libaddwpa.SRCS = $(wildcard src/wpa/*.c)

TARGET.LIBS += libsdk
libsdk.SDKLIBS += \
  libmgcc \
  libmmain \
  libmphy \
  libpp \
  libmwpa \
  libnet80211
libsdk.DEPLIBS += \
  system/libaddmmain \
  phy/libaddmphy \
  pp/libaddpp \
  wpa/libaddwpa \
  $(addprefix esp/,$(libsdk.SDKLIBS))

# Application

LOADER.LDSCRIPTS += \
  ld/eagle.app.v6-loader.ld \
  ld/eagle.rom.addr.v6-loader.ld

LOADER.LDFLAGS += \
	-nostdlib \
  -Tld/eagle.app.v6-loader.ld \
	-Wl,--no-check-sections	\
  -u call_user_start \
	-u loader_flash_boot \
  -Wl,-static

FIRMWARE.LDSCRIPTS += \
  ld/eagle.app.v6.ld \
  ld/eagle.rom.addr.v6.ld

FIRMWARE.LDFLAGS += \
  -nostartfiles \
	-nodefaultlibs \
	-nostdlib \
  -Tld/eagle.app.v6.ld \
	-Wl,--no-check-sections	\
  -u call_user_start \
  -Wl,-static

ifeq (y,$(WITH_EX_DUMMY_APP))
  TARGET.LIBS += libdummy_app
  libdummy_app.SRCS += $(wildcard example/dummy_app/*.c)

  TARGET.IMGS += dummy_app
  dummy_app.DEPLIBS += libsdk libdummy_app
endif

ifeq (y,$(WITH_EX_MEM_USAGE))
  TARGET.LIBS += libmem_usage
  libmem_usage.SRCS += $(wildcard example/mem_usage/*.c)

  TARGET.IMGS += mem_usage
  mem_usage.DEPLIBS += libsdk libmem_usage
endif

$(foreach lib,$(TARGET.LIBS),$(eval $(call LIB_RULES,$(lib))))
$(foreach img,$(TARGET.IMGS),$(eval $(call IMG_RULES,$(img))))
