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

# Options inherits
define INHERIT_SET
ifneq (,$$($(2).$(3)))
$(1).$(3) ?= $$($(2).$(3))
endif
endef

uniq = $(if $(1),$(firstword $(1)) $(call uniq,$(filter-out $(firstword $(1)),$(1))))

define INHERIT_ADD
ifneq (,$$($(2).$(3)))
$(1).$(3) := $$(call uniq,$$($(1).$(3)) $$($(2).$(3)))
endif
endef

define INHERIT_ALL # child action option
$$(foreach parent,$$($(1).INHERIT),$$(eval $$(call $(2),$(1),$$(parent),$(3))))
endef

INHERITS = $(eval $(call INHERIT_ALL,$(1),INHERIT_$(2),$(3)))

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
	$(Q)$(CC) -MD -MF $$(call DEP_P,$(1)/$$*.$(2)) -c $$($(1).CFLAGS_EXPANDED) -o $$@ $$<

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
ifndef $(1).CFLAGS_EXPANDED
$$(foreach parent,$$($(1).INHERIT),$$(eval $$(call CFLAGS_EXPAND,$$(parent))))

$$(call INHERITS,$(1),ADD,CFLAGS)
$$(call INHERITS,$(1),ADD,CDIRS)
$$(call INHERITS,$(1),ADD,CDEFS)
$$(call INHERITS,$(1),SET,CSTD)
$$(call INHERITS,$(1),ADD,CWARN)
$$(call INHERITS,$(1),SET,COPT)
$$(call INHERITS,$(1),SET,CDBG)
$$(call INHERITS,$(1),ADD,COPTS)
$$(call INHERITS,$(1),ADD,CMACH)

$(1).CFLAGS_EXPANDED := \
  $$($(1).CFLAGS) \
  $$(addprefix -I,$$($(1).CDIRS)) \
  $$(addprefix -D,$$($(1).CDEFS)) \
  $$(if $$($(1).CSTD),-std=$$($(1).CSTD)) \
  $$(addprefix -W,$$($(1).CWARN)) \
  $$(if $$($(1).COPT),-O$$($(1).COPT)) \
  $$(if $$($(1).CDBG),-g$$($(1).CDBG)) \
  $$(addprefix -f,$$($(1).COPTS)) \
  $$(addprefix -m,$$($(1).CMACH))
endif
endef

# Library rules
define LIB_RULES
$$(eval $$(call CFLAGS_EXPAND,$(1)))

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
ifndef $(1).LDFLAGS_EXPANDED
$$(foreach parent,$$($(1).INHERIT),$$(eval $$(call LDFLAGS_EXPAND,$$(parent))))

$$(call INHERITS,$(1),ADD,LDFLAGS)
$$(call INHERITS,$(1),ADD,LDDIRS)
$$(call INHERITS,$(1),SET,LDSCRIPT)
$$(call INHERITS,$(1),ADD,LDSCRIPTS)
$$(call INHERITS,$(1),ADD,UNDEFS)
$$(call INHERITS,$(1),ADD,LDOPTS)
$$(call INHERITS,$(1),ADD,DEPLIBS)
$$(call INHERITS,$(1),ADD,LDLIBS)

$(1).LDFLAGS_EXPANDED := \
  $$($(1).LDFLAGS) \
  $$(addprefix -L,$$($(1).LDDIRS)) \
  $$(if $$($(1).LDSCRIPT),-T$$($(1).LDSCRIPT)) \
  $$(addprefix -u ,$$($(1).UNDEFS)) \
  $$(addprefix -Wl$$(COMMA)-,$$($(1).LDOPTS))
$(1).DEPLIBS_EXPANDED := \
  $$(foreach lib,$$($(1).DEPLIBS),$$($$(lib).LIB))
$(1).LDLIBS_EXPANDED := \
  $$($(1).LDLIBS) \
  $$($(1).DEPLIBS_EXPANDED)
endif
endef

# Binary rules
define BIN_RULES
$$(eval $$(call LDFLAGS_EXPAND,$(1)))

$(1).BIN := $$(call BIN_P,$(1))
$(1).MAP := $$(call MAP_P,$(1))

build: build.bin.$(1)
build.bin.$(1): $$($(1).BIN)

$$($(1).BIN): $$($(1).DEPLIBS_EXPANDED) $$($(1).LDSCRIPTS)
	@echo TARGET $(1) BIN
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(LD) $$($(1).LDFLAGS_EXPANDED) -Wl,-Map -Wl,$$($(1).MAP) -Wl,--start-group $$($(1).LDLIBS_EXPANDED) -Wl,--end-group -o $$@

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
