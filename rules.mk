ifneq ($(V),)
  Q :=
else
  Q := @
endif

# Paths patterns
BIN_P = bin/$(1).elf
MAP_P = bin/$(1).map
LIB_P = lib/$(1).a
DEP_P = obj/$(1).d
OBJ_P = obj/$(1).o
SRC_P = $(1).$(2)

# Compiler configuration
COMPILER_PREFIX ?= $(if $(COMPILER_PATH),$(COMPILER_PATH)/)xtensa-lx106-elf-

CC := $(COMPILER_PREFIX)gcc
AR := $(COMPILER_PREFIX)ar
LD := $(COMPILER_PREFIX)gcc
NM := $(COMPILER_PREFIX)nm
CPP := $(COMPILER_PREFIX)cpp
OBJDUMP := $(COMPILER_PREFIX)objdump
OBJCOPY := $(COMPILER_PREFIX)objcopy
GDB := $(COMPILER_PREFIX)gdb

build:
clean:

# Compilation rules
define CC_RULES
$(1).SRC.$(2) += $$(filter %.$(2),$$($(1).SRCS))
$(1).SRC += $$($(1).SRC.$(2))

$(1).OBJ.$(2) := $$(patsubst $$(call SRC_P,%,$(2)),$$(call OBJ_P,$(1)/%.$(2)),$$($(1).SRC.$(2)))
$(1).OBJ += $$($(1).OBJ.$(2))

$(1).DEP.$(2) := $$(patsubst $$(call SRC_P,%,$(2)),$$(call DEP_P,$(1)/%.$(2)),$$($(1).SRC.$(2)))
$(1).DEP += $$($(1).DEP.$(2))

$$(call OBJ_P,$(1)/%.$(2)): $$(call SRC_P,%,$(2))
	@echo TARGET $(1) CC $(2) $$<
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(CC) -MD -MF $$(call DEP_P,$(1)/$$*.$(2)) -c $$($(1).CFLAGS) -o $$@ $$<

-include $$($(1).DEP.$(2))
endef

# Extracting library
define LIBOBJ_RULES
ifndef $(1).LIB
$(1).LIB := $(BASEPATH)$$(call LIB_P,$(1))
ifneq (,$$(wildcard $$($(1).LIB)))
$(1).DIR := $$(patsubst %.o,%,$$(call OBJ_P,$(1)))
$(1).OBJ := $$(addprefix $$($(1).DIR)/,$$(shell $(AR) t $$($(1).LIB)))
$$($(1).OBJ): $$($(1).LIB)
	@echo TARGET $(1) AR X
	$(Q)mkdir -p $$($(1).DIR)
	$(Q)cd $$($(1).DIR) && $(AR) x $$(realpath $$<)
endif
endif
endef

# Expand profile flags
define CFLAGS_EXPAND
ifneq (y,$$($(1).CFLAGS_EXPANDED))
$(1).CFLAGS_EXPANDED := y

$(1).CFLAGS += $$(addprefix -I,$$($(1).CDIRS))
$(1).CFLAGS += $$(addprefix -D,$$($(1).CDEFS))

$(1).CFLAGS += $$(if $$($(1).CSTD),-std=$$($(1).CSTD))
$(1).CFLAGS += $$(addprefix -W,$$($(1).CWARN))
$(1).CFLAGS += $$(if $$($(1).COPT),-O$$($(1).COPT))
$(1).CFLAGS += $$(if $$($(1).CDBG),-g$$($(1).CDBG))
$(1).CFLAGS += $$(addprefix -f,$$($(1).COPTS))
$(1).CFLAGS += $$(addprefix -m,$$($(1).CMACH))
endif
endef

# Library rules
define LIB_RULES
$(1).IS ?= default

$$(eval $$(call CFLAGS_EXPAND,$$($(1).IS)))
$$(eval $$(call CFLAGS_EXPAND,$(1)))
$(1).CFLAGS += $$($$($(1).IS).CFLAGS)

$$(eval $$(call CC_RULES,$(1),c))
$$(eval $$(call CC_RULES,$(1),S))

$$(foreach lib,$$($(1).DEPLIBS),$$(eval $$(call LIBOBJ_RULES,$$(lib))))

$(1).OBJ += $$(foreach lib,$$($(1).DEPLIBS),$$($$(lib).OBJ))

$(1).LIB := $$(call LIB_P,$(1))

build: build.lib.$(1)
build.lib.$(1): $$($(1).LIB)

$$($(1).LIB): $$($(1).OBJ)
	@echo TARGET $(1) LIB
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(AR) ru $$@ $$^

clean: clean.lib.$(1)
clean.lib.$(1):
	@echo TARGET $(1) LIB CLEAN
	$(Q)rm -f $$($(1).LIB) $$($(1).OBJ) $$($(1).DEP)
endef

COMMA := ,

# Expand profile flags
define LDFLAGS_EXPAND
ifneq (y,$$($(1).LDFLAGS_EXPANDED))
$(1).LDFLAGS_EXPANDED := y

$(1).LDFLAGS += $$(if $$($(1).LDSCRIPT),-T$$($(1).LDSCRIPT))
$(1).LDFLAGS += $$(addprefix -u ,$$($(1).UNDEFS))
$(1).LDFLAGS += $$(addprefix -Wl$$(COMMA)-,$$($(1).LDOPTS))
$(1).LDFLAGS += $$(addprefix -L,$$($(1).LDDIRS))
$(1).LDLIBS += $$(foreach lib,$$($(1).DEPLIBS),$$($$(lib).LIB))
endif
endef

# Binary rules
define BIN_RULES
$(1).IS ?= default

$$(eval $$(call LDFLAGS_EXPAND,$$($(1).IS)))
$$(eval $$(call LDFLAGS_EXPAND,$(1)))

$(1).LDFLAGS += $$($$($(1).IS).LDFLAGS)
$(1).LDLIBS += $$($$($(1).IS).LDLIBS)

$(1).BIN := $$(call BIN_P,$(1))
$(1).MAP := $$(call MAP_P,$(1))

build: build.bin.$(1)
build.bin.$(1): $$($(1).BIN)

$$($(1).BIN): $$($(1).DEPLIBS_FULL) $$($(1).LDSCRIPTS)
	@echo TARGET $(1) BIN
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(LD) $$($(1).LDFLAGS) -Wl,-Map -Wl,$$($(1).MAP) -Wl,--start-group $$($(1).LDLIBS) -Wl,--end-group -o $$@

clean: clean.bin.$(1)
clean.bin.$(1):
	@echo TARGET $(1) BIN CLEAN
	$(Q)rm -f $$($(1).BIN) $$($(1).MAP)

debug.$(1):
	@echo RUN GDB STUB
	@$(GDB) -ex 'file $$($(1).BIN)' $$(GDBCMDS)
endef

GDBBAUD ?= $(BAUD)
GDBPORT ?= $(PORT)
GDBCMDS += \
  -ex 'set remote hardware-breakpoint-limit 1' \
  -ex 'set remote hardware-watchpoint-limit 1' \
  -ex 'set debug xtensa 4' \
  -ex 'set remotebaud $(GDBBAUD)' \
  -ex 'target remote $(GDBPORT)'
