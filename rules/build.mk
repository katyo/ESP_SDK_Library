# Paths patterns
BIN_P = bin/$(1).elf
DYN_P = bin/$(1).so$(if $(2),.$(2))
MAP_P = bin/$(1).map
LIB_P = lib/$(1).a
DEP_P = obj/$(call FIXPATH,$(1)).d
OBJ_P = obj/$(call FIXPATH,$(1)).o
SRC_P = $(1)

# Compiler configuration
COMPILER_NAME ?= 
COMPILER_PREFIX ?= $(if $(COMPILER_PATH),$(COMPILER_PATH)/)$(COMPILER_NAME)

CC := $(COMPILER_PREFIX)gcc
AR := $(COMPILER_PREFIX)ar
CCLD := $(COMPILER_PREFIX)gcc
NM := $(COMPILER_PREFIX)nm
CPP := $(COMPILER_PREFIX)cpp
SIZE := $(COMPILER_PREFIX)size
OBJDUMP := $(COMPILER_PREFIX)objdump
OBJCOPY := $(COMPILER_PREFIX)objcopy
GDB := $(COMPILER_PREFIX)gdb
VALGRIND := valgrind

build:
clean:

define ANALYZE_RULES
analyze.$(1): $(2)
	@echo ANALYZE LIBRARY $(1)
	$(Q)$(NM) -Srt d --size-sort $$< | sed -r 's/^[0-9]*\s*0*//g'

dump.sym.$(1): $(2)
	@echo DUMP SYMBOLS $(1)
	$(Q)$(OBJDUMP) $$($(1).DUMPOPTS) -t $$<

dump.asm.$(1): $(2)
	@echo DUMP DISASSEMBLE $(1)
	$(Q)$(OBJDUMP) $$($(1).DUMPOPTS) -D $$<

dump.src.$(1): $(2)
	@echo DUMP SOURCE
	$(Q)$(OBJDUMP) $$($(1).DUMPOPTS) -S $$<

dump.hex.$(1): $(2)
	@echo DUMP HEXADECIMAL
	$(Q)$(OBJDUMP) $$($(1).DUMPOPTS) -s $$<
endef

pure_source = $(word 1,$(subst ?, ,$(1)))
pure_params = $(word 2,$(subst ?, ,$(1)))
params_to_defs = $(addprefix -D,$(subst &, ,$(1)))
filter_with_params = $(foreach f,$(2),$(if $(filter $(1),$(call pure_source,$(f))),$(f)))

define CC_RULE
$$(call OBJ_P,$(1)/$(3)): $$(call SRC_P,$(call pure_source,$(3)))
	@echo TARGET $(1) CC $(2) $$< $(call pure_params,$(3))
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(CC) -MD -MF $$(call DEP_P,$(1)/$(3)) -c $$($(1).CFLAGS_EXPANDED) $(call params_to_defs,$(call pure_params,$(3))) -o $$@ $$<
# flymake support
ifneq (,$$(filter $$(patsubst %.$(2),%_flymake.$(2),$$(call SRC_P,$(3))),$$(CHK_SOURCES)))
check-syntax: check-syntax-$(3)
check-syntax-$(3): $$(patsubst %.$(2),%_flymake.$(2),$$(call SRC_P,$(call pure_source,$(3))))
	$(Q)$(CC) -c $$($(1).CFLAGS_EXPANDED) $(call params_to_defs,$(call pure_params,$(3))) -o /dev/null $$<
endif
endef

# Compilation rules
define CC_RULES
$(1).SRC.$(2) += $$(call filter_with_params,%.$(2),$$($(1).SRCS))
$(1).SRC.$(2).PURE := $$(patsubst $$(call SRC_P,%),%,$$($(1).SRC.$(2)))
$(1).SRC += $$($(1).SRC.$(2))

$(1).OBJ.$(2) := $$(foreach f,$$($(1).SRC.$(2).PURE),$$(call OBJ_P,$(1)/$$(f)))
$(1).OBJ += $$($(1).OBJ.$(2))

$(1).DEP.$(2) := $$(foreach f,$$($(1).SRC.$(2).PURE),$$(call DEP_P,$(1)/$$(f)))
$(1).DEP += $$($(1).DEP.$(2))

$$(foreach f,$$($(1).SRC.$(2).PURE),$$(eval $$(call CC_RULE,$(1),$(2),$$(f))))

-include $$($(1).DEP.$(2))
endef

# Blob packing rules
define PK_RULES
$(1).SRC.PK += $$(filter-out $$(addprefix %.,$(2)),$$($(1).SRCS))
$(1).SRC += $$($(1).SRC.PK)

$(1).OBJ.PK := $$(patsubst $$(call SRC_P,%),$$(call OBJ_P,$(1)/%),$$($(1).SRC.PK))
$(1).OBJ += $$($(1).OBJ.PK)

$$(call OBJ_P,$(1)/%): $$(call SRC_P,%)
	@echo TARGET $(1) PK $$<
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(OBJCOPY) -I binary -O $$(firstword $$(OBJECT_ARCH)) -B $$(lastword $$(OBJECT_ARCH)) $$< $$@
endef

# Expand profile flags
define CFLAGS_EXPAND
ifndef $(1).CFLAGS_EXPANDED
$$(foreach parent,$$($(1).INHERIT),$$(eval $$(call CFLAGS_EXPAND,$$(parent))))

$$(call INHERITS,$(1),ADD,SPECS)
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
  $$($(1).CFLAGS) $$($(1).CFLAGS!) \
  $$(patsubst %,--specs=%.specs,$$($(1).SPECS) $$($(1).SPECS!)) \
  $$(addprefix -I,$$($(1).CDIRS) $$($(1).CDIRS!)) \
  $$(addprefix -D,$$($(1).CDEFS) $$($(1).CDEFS!)) \
  $$(if $$($(1).CSTD),-std=$$($(1).CSTD)) \
  $$(addprefix -W,$$($(1).CWARN) $$($(1).CWARN!)) \
  $$(if $$($(1).COPT),-O$$($(1).COPT)) \
  $$(if $$($(1).CDBG),-g$$($(1).CDBG)) \
  $$(addprefix -f,$$($(1).COPTS) $$($(1).COPTS!)) \
  $$(addprefix -m,$$($(1).CMACH) $$($(1).CMACH!))
endif
endef

# Library rules
define LIB_RULES
$$(eval $$(call CFLAGS_EXPAND,$(1)))

$$(eval $$(call CC_RULES,$(1),c))
$$(eval $$(call CC_RULES,$(1),S))
$$(eval $$(call PK_RULES,$(1),c S))

$(1).OBJS += $$(foreach lib,$$($(1).DEPLIBS*),$$($$(lib).OBJS))
$(1).OBJS += $$($(1).OBJ)

$(1).LIB := $$(call LIB_P,$(1))

build: build.lib.$(1)
build.lib.$(1): $$($(1).LIB)

$$($(1).LIB): $$($(1).OBJS)
	@echo TARGET $(1) LIB
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(AR) ru $$@ $$^
	$(Q)$(AR) s $$@

clean: clean.lib.$(1)
clean.lib.$(1):
	@echo TARGET $(1) LIB CLEAN
	$(Q)rm -f $$($(1).LIB) $$($(1).OBJ) $$($(1).DEP)

$$(eval $$(call ANALYZE_RULES,$(1),$$($(1).LIB)))
endef

LD_WHOLE = $(if $(strip $(1)),-Wl$(COMMA)--whole-archive $(1) -Wl$(COMMA)--no-whole-archive)
LD_GROUP = $(if $(strip $(1)),-Wl$(COMMA)--start-group $(1) -Wl$(COMMA)--end-group)

# Expand profile flags
define LDFLAGS_EXPAND
ifndef $(1).LDFLAGS_EXPANDED
$$(foreach parent,$$($(1).INHERIT),$$(eval $$(call LDFLAGS_EXPAND,$$(parent))))

$$(call INHERITS,$(1),ADD,CMACH)
$$(call INHERITS,$(1),ADD,SPECS)
$$(call INHERITS,$(1),ADD,LDFLAGS)
$$(call INHERITS,$(1),ADD,LDDIRS)
$$(call INHERITS,$(1),SET,LDSCRIPT)
$$(call INHERITS,$(1),ADD,LDSCRIPTS)
$$(call INHERITS,$(1),ADD,UNDEFS)
$$(call INHERITS,$(1),ADD,LDOPTS)
$$(call INHERITS,$(1),ADD,DEPLIBS)
$$(call INHERITS,$(1),ADD,DEPLIBS*)
$$(call INHERITS,$(1),ADD,DEPLIBS&)
$$(call INHERITS,$(1),ADD,LDLIBS)
$$(call INHERITS,$(1),ADD,GDBOPTS)
$$(call INHERITS,$(1),ADD,DUMPOPTS)
$$(call INHERITS,$(1),ADD,ENVIRON)
$$(call INHERITS,$(1),ADD,CMDLINE)

$(1).LDFLAGS_EXPANDED := \
  $$(addprefix -m,$$($(1).CMACH) $$($(1).CMACH!)) \
  $$($(1).LDFLAGS) $$($(1).LDFLAGS!) \
  $$(patsubst %,--specs=%.specs,$$($(1).SPECS) $$($(1).SPECS!)) \
  $$(addprefix -L,$$($(1).LDDIRS) $$($(1).LDDIRS!)) \
  $$(if $$($(1).LDSCRIPT),-T$$($(1).LDSCRIPT)) \
  $$(addprefix -u ,$$($(1).UNDEFS) $$($(1).UNDEFS!)) \
  $$(addprefix -Wl$$(COMMA)-,$$($(1).LDOPTS) $$($(1).LDOPTS!))
$(1).DEPLIBS_EXPANDED := \
  $$(foreach lib,$$($(1).DEPLIBS),$$($$(lib).LIB))
$(1).DEPLIBS_EXPANDED& := \
  $$(foreach lib,$$($(1).DEPLIBS&),$$($$(lib).LIB))
$(1).DEPLIBS_EXPANDED* := \
  $$(foreach lib,$$($(1).DEPLIBS*),$$($$(lib).LIB))
$(1).LDLIBS_EXPANDED := \
  $$($(1).LDLIBS) $$($(1).LDLIBS!) \
  $$($(1).DEPLIBS_EXPANDED&)
$(1).DEPLIBS_EXPANDED_ := \
  $$($(1).DEPLIBS_EXPANDED) \
  $$($(1).DEPLIBS_EXPANDED*) \
  $$($(1).DEPLIBS_EXPANDED&)
endif
endef

# Shared library rules
define DYN_RULES
$$(eval $$(call LDFLAGS_EXPAND,$(1)))

$(1).DYN := $$(call DYN_P,$(1),$$($(1).DYNVER))
$(1).DYN_NAME := $$(call DYN_P,$(1),$$(word 1,$$(subst ., ,$$($(1).DYNVER))))
$(1).DYN_PURE := $$(call DYN_P,$(1))
$(1).MAP := $$(call MAP_P,$(1))

build: build.dyn.$(1)
build.dyn.$(1): $$($(1).DYN_PURE)
ifneq ($$($(1).DYN_PURE),$$($(1).DYN_NAME))
$$($(1).DYN_PURE): $$($(1).DYN_NAME)
	@echo TARGET $(1) DYN ALIAS
	$(Q)ln -sf $$(notdir $$<) $$@
clean.dyn.$(1): clean.dyn-pure.$(1)
clean.dyn-pure.$(1):
	@echo TARGET $(1) DYN ALIAS CLEAN
	$(Q)rm -f $$($(1).DYN_PURE)
endif
ifneq ($$($(1).DYN_NAME),$$($(1).DYN))
$$($(1).DYN_NAME): $$($(1).DYN)
	@echo TARGET $(1) DYN ALIAS
	$(Q)ln -sf $$(notdir $$<) $$@
clean.dyn.$(1): clean.dyn-name.$(1)
clean.dyn-name.$(1):
	@echo TARGET $(1) DYN ALIAS CLEAN
	$(Q)rm -f $$($(1).DYN_NAME)
endif
$$($(1).DYN): $$($(1).DEPLIBS_EXPANDED_) $$($(1).LDSCRIPTS)
	@echo TARGET $(1) DYN
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(CCLD) -shared $$($(1).LDFLAGS_EXPANDED) -Wl,-soname,$$(notdir $$($(1).DYN_NAME)) -Wl,-Map -Wl,$$($(1).MAP) $$(call LD_WHOLE,$$($(1).DEPLIBS_EXPANDED*)) $$($(1).DEPLIBS_EXPANDED) $$(call LD_GROUP,$$($(1).LDLIBS_EXPANDED)) -o $$@
	$(Q)$(SIZE) $$@

clean: clean.dyn.$(1)
clean.dyn.$(1):
	@echo TARGET $(1) DYN CLEAN
	$(Q)rm -f $$($(1).DYN) $$($(1).MAP)

$$(eval $$(call ANALYZE_RULES,$(1),$$($(1).DYN)))
endef

# Binary rules
define BIN_RULES
$$(eval $$(call LDFLAGS_EXPAND,$(1)))

$(1).BIN := $$(call BIN_P,$(1))
$(1).MAP := $$(call MAP_P,$(1))

build: build.bin.$(1)
build.bin.$(1): $$($(1).BIN)

$$($(1).BIN): $$($(1).DEPLIBS_EXPANDED_) $$($(1).LDSCRIPTS)
	@echo TARGET $(1) BIN
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(CCLD) $$($(1).LDFLAGS_EXPANDED) -Wl,-Map -Wl,$$($(1).MAP) $$(call LD_WHOLE,$$($(1).DEPLIBS_EXPANDED*)) $$($(1).DEPLIBS_EXPANDED) $$(call LD_GROUP,$$($(1).LDLIBS_EXPANDED)) -o $$@
	$(Q)$(SIZE) $$@

clean: clean.bin.$(1)
clean.bin.$(1):
	@echo TARGET $(1) BIN CLEAN
	$(Q)rm -f $$($(1).BIN) $$($(1).MAP)

run.$(1): $$($(1).BIN)
	@echo RUN $(1)
	$(Q)$$(if $$($(1).ENVIRON),$$($(1).ENVIRON) )$$($(1).BIN)$$(if $$($(1).CMDLINE), $$($(1).CMDLINE))

debug.$(1): $$($(1).BIN)
	@echo RUN GDB $(1)
	$(Q)$$(if $$($(1).ENVIRON),$$($(1).ENVIRON) )$(GDB) -ex 'file $$($(1).BIN)'$$(if $$($(1).CMDLINE), -ex 'set args $$($(1).CMDLINE)') $$($(1).GDBOPTS)

valgrind.$(1): $$($(1).BIN)
	@echo RUN VALGRIND $(1)
	$(Q)$$(if $$($(1).ENVIRON),$$($(1).ENVIRON) )$(VALGRIND) --leak-check=full --show-leak-kinds=all --track-origins=yes -v --log-file=$$($(1).BIN).valgrind $$($(1).BIN)$$(if $$($(1).CMDLINE), $$($(1).CMDLINE))

$$(eval $$(call ANALYZE_RULES,$(1),$$($(1).BIN)))
endef
