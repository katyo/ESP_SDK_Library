# Path patterns
IMG_P = bin/$(1).bin

# Serial port setup
PORT ?= /dev/ttyUSB0
BAUD ?= 256000

# ESP tool
ESPTOOL ?= esptool.py
ESPPORT ?= $(PORT)
ESPBAUD ?= $(BAUD)
ESPOPTION ?= $(if $(ESPBAUD),-b $(ESPBAUD)) $(if $(ESPPORT),-p $(ESPPORT))

# Serial terminal tool
TTYTOOLS ?= minicom picocom miniterm miniterm.py
TTYTOOL ?= $(firstword $(foreach tool,$(TTYTOOLS),$(if $(shell which $(tool)),$(tool),)))
TTYPORT ?= $(PORT)
TTYBAUD ?= $(BAUD)

ifeq (minicom,$(notdir $(TTYTOOL)))
  TTYOPTION ?= $(if $(TTYBAUD),-b $(TTYBAUD)) $(if $(TTYPORT),-D $(TTYPORT))
endif

ifeq (picocom,$(notdir $(TTYTOOL)))
  TTYOPTION ?= $(if $(TTYBAUD),-b $(TTYBAUD)) $(TTYPORT)
endif

ifeq (miniterm,$(basename $(notdir $(TTYTOOL))))
  TTYOPTION ?= $(if $(TTYBAUD),-b $(TTYBAUD)) $(if $(TTYPORT),-p $(TTYPORT))
endif

# Image
DEFAULT_ADDR := 0x7C000
DEFAULT_BIN := $(call BIN_P,esp_init_data_default)

BLANK_ADDR := 0x7E000
BLANK_BIN := $(call BIN_P,blank)

CLEAR_EEP_ADDR := 0x79000
CLEAR_EEP_BIN := $(call BIN_P,clear_eep)

# 40 or 80 [MHz]
FLASH_SPEED_MHZ ?= 80
# QIO, DIO, QOUT, DOUT
FLASH_MODE ?= QIO
# Use 512 for all size Flash (512 kbytes .. 16 Mbytes Flash autodetect)
FLASH_SIZE_KB ?= 512

ifeq ($(FLASH_SPEED_MHZ),26.7)
  FLASH_FREQ_DIV := 1
  FLASH_FREQ := 26
else
  ifeq ($(FLASH_SPEED_MHZ),20)
    FLASH_FREQ_DIV := 2
    FLASH_FREQ := 20
  else
    ifeq ($(FLASH_SPEED_MHZ),80)
      FLASH_FREQ_DIV := 15
      FLASH_FREQ := 80
    else
      FLASH_FREQ_DIV := 0
      FLASH_FREQ := 40
    endif
  endif
endif

ifeq ($(FLASH_MODE),QOUT)
  FLASH_MODE_ID := 1
  FLASH_MODE_NAME := qout
else
  ifeq ($(FLASH_MODE),DIO)
    FLASH_MODE_ID := 2
    FLASH_MODE_NAME := dio
  else
    ifeq ($(FLASH_MODE),DOUT)
      FLASH_MODE_ID := 3
      FLASH_MODE_NAME := dout
    else
      FLASH_MODE_ID := 0
      FLASH_MODE_NAME := qio
    endif
  endif
endif

# flash larger than 1024KB only use 1024KB to storage user1.bin and user2.bin
ifeq ($(FLASH_SIZE_KB),256)
  FLASH_SIZE_ID := 1
  FLASH_SIZE_USER_KB := 256
  FLASH_SIZE_MBITS := 2
else
  ifeq ($(FLASH_SIZE_KB),1024)
    FLASH_SIZE_ID := 2
    FLASH_SIZE_USER_KB := 1024
    FLASH_SIZE_MBITS := 8
  else
    ifeq ($(FLASH_SIZE_KB),2048)
      FLASH_SIZE_ID := 3
      FLASH_SIZE_USER_KB := 1024
      FLASH_SIZE_MBITS := 16
    else
      ifeq ($(FLASH_SIZE_KB),4096)
        FLASH_SIZE_ID := 4
        FLASH_SIZE_USER_KB := 1024
        FLASH_SIZE_MBITS := 32
      else
        FLASH_SIZE_ID := 0
        FLASH_SIZE_USER_KB := 512
        FLASH_SIZE_MBITS := 4
      endif
    endif
  endif
endif

CDEFS += USE_FIX_QSPI_FLASH=$(FLASH_SPEED_MHZ)

IMG_OPTION ?= -ff $(FLASH_FREQ)m -fm $(FLASH_MODE_NAME) -fs $(FLASH_SIZE_MBITS)m

IMG1_ADDR := 0x00000
IMG2_ADDR := 0x40000

# Image rules
define IMG_RULES
$$(eval $$(call BIN_RULES,$(1)))

$(1).IMG1 := $$(call IMG_P,$(1)-$(IMG1_ADDR))
$(1).IMG2 := $$(call IMG_P,$(1)-$(IMG2_ADDR))

ifneq (,$$($(1).ISLOADER))
  $(1).IMG := $$(call IMG_P,$(1))
else
  $(1).IMG := $$($(1).IMG1) $$($(1).IMG2)

  ifneq (,$$($(1).LOADER))
    $(1).LDR := $$($$($(1).LOADER).IMG)
  else
    ifneq (,$$(LOADER))
      $(1).LDR := $$($$(LOADER).IMG)
    endif
  endif
endif

build: build.img.$(1)
build.img.$(1): $$($(1).IMG)

$$($(1).IMG): $$($(1).BIN) $$($(1).LDR)
	@echo TARGET $(1) IMAGE
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(ESPTOOL) elf2image -o $$(dir $$(firstword $$($(1).IMG)))$(1)- $(IMG_OPTION) $$($(1).BIN)
	$(Q)$(ESPTOOL) image_info $$($(1).IMG1)
ifneq (,$$($(1).ISLOADER))
	@echo TARGET $(1) MAKE LOADER
	$(Q)$(OBJCOPY) --only-section .lit4 -O binary $$< $$($(1).IMG)~addld
	$(Q)cp -f $$($(1).IMG1) $$($(1).IMG)
	$(Q)dd if=$$($(1).IMG)~addld >>$$($(1).IMG)
	$(Q)rm -f $$($(1).IMG)~addld
else
  ifdef $(1).LDR
	@echo TARGET $(1) ADD LOADER
	$(Q)mv -f $$($(1).IMG1) $$($(1).IMG1)~orig
	$(Q)dd if=$$($(1).LDR) >$$($(1).IMG1)
	$(Q)dd if=$$($(1).IMG1)~orig >>$$($(1).IMG1)
	$(Q)rm -f $$($(1).IMG1)~orig
  endif
endif

clean: clean.img.$(1)
clean.img.$(1):
	@echo TARGET $(1) IMG CLEAN
	$(Q)rm -f $$($(1).IMG) $$(call IMG_P,$(1)-addld) $$(call IMG_P,$(1)-$(IMG1_ADDR)) $$(call IMG_P,$(1)-$(IMG2_ADDR))

flash.img.$(1): $$($(1).IMG)
	@echo TARGET $(1) IMG FLASH
	$(Q)$(ESPTOOL) $(ESPOPTION) write_flash $(IMG_OPTION) $(IMG1_ADDR) $$($(1).IMG1) $(IMG2_ADDR) $$($(1).IMG2)
ifneq (,$(OPENTTY))
	$(Q)$(TTYTOOL) $(TTYOPTION)
endif

open.tty.$(1):
	$(Q)$(TTYTOOL) $(TTYOPTION)
endef
