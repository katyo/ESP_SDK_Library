# Path patterns
IMG_P = bin/$(1).bin

# ESP tool
ESPTOOL ?= esptool.py
ESPPORT ?= $(PORT)
ESPBAUD ?= $(BAUD)
ESPOPTION ?= $(if $(ESPBAUD),-b $(ESPBAUD)) $(if $(ESPPORT),-p $(ESPPORT))
ESPOPTION += $(ESPEXTRA)

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

TTYOPTION += $(TTYEXTRA)

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

# Raw-data image rules
define RDI_RULES
$(1).CFLAGS += $$(addprefix -D,$$($(1).CDEFS))
$(1).CFLAGS += $$(addprefix -I,$$($(1).CDIRS))

$$(eval $$(call CC_RULES,$(1),c))

$(1).IMG := $$(call IMG_P,$(1))

build: build.img.$(1)
build.img.$(1): $$($(1).IMG)

$$($(1).IMG): $$($(1).OBJ)
	@echo TARGET $(1) RDI
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(OBJCOPY) -O binary -j '.rodata.*' $$^ $$@

clean: clean.img.$(1)
clean.img.$(1):
	@echo TARGET $(1) RDI CLEAN
	$(Q)rm -f $$($(1).IMG) $$($(1).OBJ) $$($(1).DEP)
endef

# Image rules
define IMG_RULES
$$(eval $$(call BIN_RULES,$(1)))

$(1).IMGS += $(1).IMG1 $(1).IMG2
$(1).IMG1.ADDR ?= $(IMG1.ADDR)
$(1).IMG1.IMG := $$(call IMG_P,$(1)-$(IMG1.ADDR))
$(1).IMG2.ADDR ?= $(IMG2.ADDR)
$(1).IMG2.IMG := $$(call IMG_P,$(1)-$(IMG2.ADDR))

$(1).IMG += $$(foreach img,$$($(1).IMGS),$$($$(img).IMG))

ifneq (,$$($(1).ISLOADER))
  $(1).LDR := $$(call IMG_P,$(1))
else
  ifneq (,$$($(1).LOADER))
    $(1).LDR.IMG := $$($$($(1).LOADER).LDR)
  else
    ifneq (,$$(LOADER))
      $(1).LDR.IMG := $$($$(LOADER).LDR)
    endif
  endif
endif

build: build.img.$(1)

ifneq (y,$$($(1).ISLOADER))
build.img.$(1): $$($(1).IMG)
else
build.img.$(1): $$($(1).LDR)
$$($(1).LDR): $$($(1).IMG)
	@echo TARGET $(1) MAKE LOADER
	$(Q)$(OBJCOPY) -O binary -j .lit4 $$($(1).BIN) $$($(1).BIN)~addld
	$(Q)cat $$($(1).IMG1.IMG) $$($(1).BIN)~addld >$$($(1).LDR)
	$(Q)rm -f $$($(1).BIN)~addld
endif

$$($(1).IMG): $$($(1).BIN) $$($(1).LDR.IMG)
	@echo TARGET $(1) IMAGE
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(ESPTOOL) elf2image -o $$(dir $$(firstword $$($(1).IMG)))$(1)- $(IMG_OPTION) $$($(1).BIN)
ifneq (y,$$($(1).ISLOADER))
  ifdef $(1).LDR.IMG
	@echo TARGET $(1) ADD LOADER
	$(Q)mv -f $$($(1).IMG1.IMG) $$($(1).IMG1.IMG)~orig
	$(Q)cat $$($(1).LDR.IMG) $$($(1).IMG1.IMG)~orig >$$($(1).IMG1.IMG)
	$(Q)rm -f $$($(1).IMG1.IMG)~orig
  endif
endif

info.img.$(1): $$($(1).IMG)
	@echo TARGET $(1) IMAGE INFO
	$(Q)$(ESPTOOL) image_info $$^

clean: clean.img.$(1)
clean.img.$(1):
	@echo TARGET $(1) CLEAN IMAGE
	$(Q)rm -f $$($(1).IMG) $$(call IMG_P,$(1)-addld)

$(1).flash.IMGS += $$($(1).IMGS) # add images to flashing

ifeq (y,$(CLEAR)) # add images to clearing settings
$(1).flash.IMGS += $$(clear.IMGS)
endif

ifneq (y,$$($(1).ISLOADER))
flash.img.$(1): $$(foreach t,$$($(1).flash.IMGS),$$($$(t).IMG))
	@echo TARGET $(1) FLASH IMG
	$(Q)$(ESPTOOL) $(ESPOPTION) write_flash $(IMG_OPTION) $$(foreach t,$$($(1).flash.IMGS),$$($$(t).ADDR) $$($$(t).IMG))
endif

endef

open.tty:
	@echo OPEN TTY
	$(Q)$(TTYTOOL) $(TTYOPTION)

flash.clear: $(foreach img,$(clear.IMGS),$($(img).IMG))
	@echo FLASH CLEAR SETTINGS
	$(Q)$(ESPTOOL) $(ESPOPTION) write_flash $(IMG_OPTION) $(foreach img,$(clear.IMGS),$($(img).ADDR) $($(img).IMG))
