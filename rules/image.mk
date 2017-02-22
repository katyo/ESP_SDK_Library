# Path patterns
IMG_P = bin/$(1).bin

# ESP tool
ESPTOOL = $(esptool.name)
ESPOPTION = $(if $(esptool.baud),-b $(esptool.baud)) $(if $(esptool.port),-p $(esptool.port)) $(esptool.extra)

# Serial terminal tool
TTYTOOLS := minicom picocom miniterm miniterm.py

TTYOPTION.minicom = $(if $(ttytool.baud),-b $(ttytool.baud)) $(if $(ttytool.port),-D $(ttytool.port))
TTYOPTION.picocom = $(if $(ttytool.baud),-b $(ttytool.baud)) $(ttytool.port))
TTYOPTION.miniterm = $(if $(ttytool.baud),-b $(ttytool.baud)) $(if $(ttytool.port),-p $(ttytool.port))
TTYOPTION.miniterm.py = $(TTYOPTION.miniterm)

TTYTOOL = $(ttytool.name)
TTYOPTION = $(TTYOPTION.$(ttytool.name)) $(ttytool.extra)

# <size> <id> <user_kb> <mbits>
FLASH_SIZE_CONFIGS := 256:1:256:2 512:0:512:4 1024:2:1024:8 2048:3:1024:16 4096:4:1024:32
# field number
flash_size_query = $(strip $(foreach c,$(FLASH_SIZE_CONFIGS),$(if $(filter $(2),$(word 1,$(subst :, ,$(c)))),$(word $(1),$(subst :, ,$(c))))))
#flash_size_id = $(call flash_size_query,2,$(1))
#flash_size_user_kb = $(call flash_size_query,3,$(1))
flash_size_mbits = $(call flash_size_query,4,$(1))

IMG_OPTION = -ff $(esptool.flash.freq)m -fm $(esptool.flash.mode) -fs $(call flash_size_mbits,$(esptool.flash.size))m

# Raw-data image rules
define RDI_RULES
$(1).IS ?= default

$$(eval $$(call CFLAGS_EXPAND,$$($(1).IS)))
$$(eval $$(call CFLAGS_EXPAND,$(1)))
$(1).CFLAGS += $$($$($(1).IS).CFLAGS)

$$(eval $$(call CC_RULES,$(1),c))

$(1).IMG := $$(call IMG_P,$(1))

build: build.img.$(1)
build.img.$(1): $$($(1).IMG)

$$($(1).IMG): $$($(1).OBJ)
	@echo TARGET $(1) RDI
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$$($(1).OBJCOPY) -O binary -j .irom0.rodata $$^ $$@

clean: clean.img.$(1)
clean.img.$(1):
	@echo TARGET $(1) RDI CLEAN
	$(Q)rm -f $$($(1).IMG) $$($(1).OBJ) $$($(1).DEP)

flash.clear: $$($(1).IMG)

read.img.$(1): $$($(1).IMG)
	@echo TARGET $(1) READ IMG
	$(Q)$(ESPTOOL) $(ESPOPTION) read_flash $$($(1).ADDR) $$(firstword $$(shell wc -c $$($(1).IMG))) $$($(1).IMG)~readed
endef

# Image rules
define IMG_RULES
$$(eval $$(call BIN_RULES,$(1)))

ifneq (,$$(LOADER))
$(1).LOADER ?= $$(LOADER)
endif

$(1).IMGS += $(1).IMG1 $(1).IMG2
$(1).IMG1.ADDR ?= $(IMG1.ADDR)
$(1).IMG1.IMG := $$(call IMG_P,$(1)-$(IMG1.ADDR))
$(1).IMG2.ADDR ?= $(IMG2.ADDR)
$(1).IMG2.IMG := $$(call IMG_P,$(1)-$(IMG2.ADDR))

$(1).IMG += $$(foreach img,$$($(1).IMGS),$$($$(img).IMG))

ifneq (,$$($(1).LOADER))
$(1).LOADER.LDR := $$($$($(1).LOADER).LDR)
endif

build: build.img.$(1)
build.img.$(1): $$($(1).IMG)
$$($(1).IMG): $$($(1).BIN) $$($(1).LOADER.LDR)
	@echo TARGET $(1) IMAGE
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(ESPTOOL) elf2image -o $$(dir $$(firstword $$($(1).IMG)))$(notdir $(1))- $(IMG_OPTION) $$($(1).BIN)
ifneq (,$$($(1).LOADER))
	@echo TARGET $(1) ADD LOADER
	$(Q)mv -f $$($(1).IMG1.IMG) $$($(1).IMG1.IMG)~orig
	$(Q)cat $$($(1).LOADER.LDR) $$($(1).IMG1.IMG)~orig >$$($(1).IMG1.IMG)
	$(Q)rm -f $$($(1).IMG1.IMG)~orig
endif

info.img.$(1): $$($(1).IMG)
	@echo TARGET $(1) IMAGE INFO
	$(Q)$(ESPTOOL) image_info $$<

clean: clean.img.$(1)
clean.img.$(1):
	@echo TARGET $(1) CLEAN IMAGE
	$(Q)rm -f $$($(1).IMG)

$(1).flash.IMGS += $$($(1).IMGS) # add images to flashing

ifeq (y,$(CLEAR)) # add images to clearing settings
$(1).flash.IMGS += $$(clear.IMGS)
endif

flash.img.$(1): $$(foreach t,$$($(1).flash.IMGS),$$($$(t).IMG))
	@echo TARGET $(1) FLASH IMG
	$(Q)$(ESPTOOL) $(ESPOPTION) write_flash $(IMG_OPTION) $$(foreach t,$$($(1).flash.IMGS),$$($$(t).ADDR) $$($$(t).IMG))
endef

define LDR_RULES
$(1).LOADER :=
$$(eval $$(call IMG_RULES,$(1)))

$(1).LDR = $$(call IMG_P,$(1))

build: build.ldr.$(1)
build.ldr.$(1): $$($(1).LDR)
$$($(1).LDR): $$($(1).IMG)
	@echo TARGET $(1) MAKE LOADER
	$(Q)$$($(1).OBJCOPY) -O binary -j .lit4 $$($(1).BIN) $$($(1).BIN)~addld
	$(Q)cat $$($(1).IMG1.IMG) $$($(1).BIN)~addld >$$($(1).LDR)
	$(Q)rm -f $$($(1).BIN)~addld

clean: clean.ldr.$(1)
clean.ldr.$(1):
	@echo TARGET $(1) CLEAN LOADER
	$(Q)rm -f $$($(1).LDR)
endef

open.tty:
	@echo OPEN TTY
	$(Q)$(TTYTOOL) $(TTYOPTION)

flash.clear:
	@echo FLASH CLEAR SETTINGS
	$(Q)$(ESPTOOL) $(ESPOPTION) write_flash $(IMG_OPTION) $(foreach img,$(clear.IMGS),$($(img).ADDR) $($(img).IMG))

flash.run:
	@echo FLASH RUN
	$(Q)$(ESPTOOL) $(ESPOPTION) run
