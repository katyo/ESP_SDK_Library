xtensa.INHERIT := stalin
$(call use_toolchain,xtensa,xtensa-lx106-elf-)

firmware.INHERIT := xtensa
firmware.CDIRS += $(espsdk.INCDIR)
firmware.COPTS ?= no-tree-ccp optimize-register-move
firmware.CMACH ?= no-target-align no-serialize-volatile longcalls text-section-literals
firmware.ALIGN := 4
firmware.SIZEB := 4
firmware.RODATA ?= .irom0.rodata

GDBBAUD ?= $(BAUD)
GDBPORT ?= $(PORT)
firmware.GDBOPTS += \
  -ex 'set remote hardware-breakpoint-limit 1' \
  -ex 'set remote hardware-watchpoint-limit 1' \
  -ex 'set debug xtensa 4' \
  -ex 'set serial baud $(GDBBAUD)' \
  -ex 'target remote $(GDBPORT)'

LOADER ?= $(if $(call option-true,$(espsdk.use_loader)),rapid_loader)

loader.INHERIT := firmware

# Application
firmware.LDDIRS += $(espsdk.LDDIR)
firmware.LDSCRIPT ?= $(espsdk.LDDIR)/eagle.app.v6.ld
firmware.LDSCRIPTS ?= $(firmware.LDSCRIPT) $(espsdk.LDDIR)/eagle.rom.addr.v6.ld
firmware.LDOPTS ?= EL -gc-sections -no-check-sections -wrap=os_printf_plus static
loader.UNDEFS ?= call_user_start
firmware.LDFLAGS += -nostartfiles -nodefaultlibs -nostdlib

loader.LDSCRIPT ?= $(espsdk.LDDIR)/eagle.app.v6-loader.ld
loader.LDSCRIPTS ?= $(loader.LDSCRIPT) $(espsdk.LDDIR)/eagle.rom.addr.v6.ld
loader.LDOPTS ?= -no-check-sections static
loader.UNDEFS ?= call_user_start loader_flash_boot
loader.LDFLAGS ?= -nostdlib

firmware.LDLIBS += $(addprefix -l,c m gcc)

# Image
rawimg.INHERIT := firmware

# Program codes IRAM/RAM
IMG1.ADDR ?= 0x00000

# Program codes Cache Flash
IMG2.ADDR ?= 0x07000

TARGET.RULES.PRE += \
OPT_RULES:TARGET.OPTS

TARGET.RULES += \
LIB_RULES:TARGET.LIBS\
RDI_RULES:TARGET.RDIS\
LDR_RULES:TARGET.LDRS\
IMG_RULES:TARGET.IMGS

TARGET.RULES.POST +=

# Provide rules
$(call ADDRULES,\
$(TARGET.RULES.PRE)\
$(TARGET.RULES)\
$(TARGET.RULES.POST))
