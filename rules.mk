TARGET.LIBS += librapid_loader
librapid_loader.INHERIT = loader
librapid_loader.CDEFS += __ets__
librapid_loader.SRCS += \
  $(libsdk.SRCDIR)/loader/loader.c \
  $(libsdk.SRCDIR)/loader/loader_flash_boot.S

TARGET.LDRS += rapid_loader
rapid_loader.INHERIT = librapid_loader
rapid_loader.DEPLIBS += librapid_loader

TARGET.LIBS += liblwipapi
liblwipapi.INHERIT = liblwip
liblwipapi.SRCS = $(wildcard $(libsdk.SRCDIR)/lwip/api/*.c)

TARGET.LIBS += liblwipapp
liblwipapp.INHERIT = liblwip
liblwipapp.SRCS = $(wildcard $(libsdk.SRCDIR)/lwip/app/*.c)

TARGET.LIBS += liblwipcore
liblwipcore.INHERIT = liblwip
liblwipcore.SRCS = $(wildcard $(libsdk.SRCDIR)/lwip/core/*.c)

TARGET.LIBS += liblwipipv4
liblwipipv4.INHERIT = liblwip
liblwipipv4.SRCS = $(wildcard $(libsdk.SRCDIR)/lwip/core/ipv4/*.c)

TARGET.LIBS += liblwipnetif
liblwipnetif.INHERIT = liblwip
liblwipnetif.SRCS = $(wildcard $(libsdk.SRCDIR)/lwip/netif/*.c)

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
libphy.SRCS = $(wildcard $(libsdk.SRCDIR)/phy/*.c)
libphy.OBJS = $(wildcard $(libsdk.SRCDIR)/phy/blob/*.o)

TARGET.LIBS += libpp
libpp.INHERIT = libsdk
libpp.SRCS = $(wildcard $(libsdk.SRCDIR)/pp/*.c)
libpp.OBJS = $(wildcard $(libsdk.SRCDIR)/pp/blob/*.o)

TARGET.LIBS += libmain
libmain.INHERIT = libsdk
libmain.SRCS = $(wildcard $(addprefix $(libsdk.SRCDIR)/,system/*.c bin/esp_init_data_default.c))
libmain.OBJS = $(wildcard $(libsdk.SRCDIR)/system/blob/*.o)

TARGET.LIBS += libwpa
libwpa.INHERIT = libsdk
libwpa.SRCS = $(wildcard $(libsdk.SRCDIR)/wpa/*.c)
libwpa.OBJS = $(wildcard $(libsdk.SRCDIR)/wpa/blob/*.o)

TARGET.LIBS += libnet80211
libnet80211.INHERIT = libsdk
libnet80211.SRCS = $(wildcard $(libsdk.SRCDIR)/net80211/*.c)
libnet80211.OBJS = $(wildcard $(libsdk.SRCDIR)/net80211/blob/*.o)

TARGET.LIBS += libaxtls
libaxtls.INHERIT = libsdk
libaxtls.SRCS += $(addprefix $(libsdk.SRCDIR)/axtls/, \
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
AXTLS_CERT_PKEY_H := $(addprefix $(libsdk.SRCDIR)/axtls/ssl/,cert.h private_key.h)
$(libsdk.SRCDIR)/axtls/ssl/default.c: $(AXTLS_CERT_PKEY_H)
$(AXTLS_CERT_PKEY_H):
	@echo GEN SSL CERT/PKEY
	$(Q)$(libsdk.SRCDIR)/axtls/tools/make_certs.sh
clean: clean.ssl_certs
clean.ssl_certs:
	@echo CLEAN SSL CERT/PKEY
	$(Q)rm -f $(AXTLS_CERT_PKEY_H)

TARGET.LIBS += libgdbstub
libgdbstub.INHERIT = libsdk
libgdbstub.SRCS += $(wildcard $(addprefix $(libsdk.SRCDIR)/gdbstub/*.,c S))

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
TARGET.OPTS += libsdk
libsdk.OPTS := $(libsdk.SRCDIR)/sdk.cf

# The RTC EEPROM data
TARGET.RDIS += clear_eep
clear.IMGS += clear_eep
clear_eep.INHERIT = rawimg
clear_eep.SRCS += $(libsdk.SRCDIR)/bin/clear_eep.c
clear_eep.ADDR ?= 0x79000

# RF SDK options
TARGET.RDIS += esp_init_data_default
clear.IMGS += esp_init_data_default
esp_init_data_default.INHERIT = rawimg
esp_init_data_default.SRCS += $(libsdk.SRCDIR)/bin/esp_init_data_default.c
esp_init_data_default.ADDR ?= 0x7C000

# Default SDK WiFi config
TARGET.RDIS += blank
clear.IMGS += blank
blank.INHERIT = rawimg
blank.SRCS += $(libsdk.SRCDIR)/bin/blank.c
blank.ADDR ?= 0x7E000
