# Paths patterns
BIN_P = bin/$(1).elf
DYN_P = bin/$(1).so$(if $(2),.$(2))
MAP_P = bin/$(1).map
LIB_P = lib/$(1).a
# <lib> <src> <pfx-ext> <sfx-ext>
GEN_P = gen/$(call FIXPATH,$(1)/$(basename $(2))$(if $(3),.$(3))$(patsubst $(basename $(2))%,%,$(2))$(if $(4),.$(4)))

TC_PROGRAMS := CC:cc AR:ar CCLD:gcc NM:nm CPP:cpp SIZE:size OBJDUMP:objdump OBJCOPY:objcopy GDB:gdb VALGRIND:valgrind
COMMON_TCARGS := $(addprefix SET:,$(foreach p,$(TC_PROGRAMS),$(word 1,$(subst :, ,$(p)))))

define TC_SET_PROGRAM
$(1).$(word 1,$(2)) := $$($(1).TC_PREFIX)$(word 2,$(2))
endef

# Compiler configuration
define SET_TOOLCHAIN
$(1).TC_NAME := $(2)
$(1).TC_PATH := $(3)
$(1).TC_PREFIX := $$(if $$($(1).TC_PATH),$$($(1).TC_PATH)/)$$($(1).TC_NAME)
$$(foreach p,$(TC_PROGRAMS),$$(eval $$(call TC_SET_PROGRAM,$(1),$$(subst :, ,$$(p)))))
endef

use_toolchain = $(foreach t,$(1),$(eval $(call SET_TOOLCHAIN,$(t),$(2),$(3))))

build:
clean:

define ANALYZE_RULES
analyze.$(1): $(2)
	@echo ANALYZE $(1)
	$(Q)$$($(1).NM) -Srt d --size-sort $$< | sed -r 's/^[0-9]*\s*0*//g'

size.$(1): $(2)
	@echo SIZE $(1)
	$(Q)$$($(1).SIZE) $$<

dump.sym.$(1): $(2)
	@echo DUMP SYMBOLS $(1)
	$(Q)$$($(1).OBJDUMP) $$($(1).DUMPOPTS) -t $$<

dump.asm.$(1): $(2)
	@echo DUMP DISASSEMBLE $(1)
	$(Q)$$($(1).OBJDUMP) $$($(1).DUMPOPTS) -D $$<

dump.src.$(1): $(2)
	@echo DUMP SOURCE
	$(Q)$$($(1).OBJDUMP) $$($(1).DUMPOPTS) -S $$<

dump.hex.$(1): $(2)
	@echo DUMP HEXADECIMAL
	$(Q)$$($(1).OBJDUMP) $$($(1).DUMPOPTS) -s $$<
endef

# <library> <c|S> <orig-source> <source> <source-args> <rest-rules>
NEXT_RULE = $(if $(6),$(call $(firstword $(6)),$(1),$(2),$(3),$(4),$(5),$(wordlist 2,$(words $(6)),$(6))))

CC_GET_SOURCE = $(word 1,$(subst ?, ,$(1)))
CC_GET_PARAMS = $(word 2,$(subst ?, ,$(1)))
CC_GET_VALUE = $(strip $(foreach p,$(subst &, ,$(2)),$(if $(filter $(1),$(word 1,$(subst =, ,$(p)))),$(word 2,$(subst =, ,$(p))))))
PARAMS_TO_DEFS = $(addprefix -D,$(subst &, ,$(1)))
FILTER_SOURCES = $(foreach f,$(2),$(if $(filter $(1),$(call CC_GET_SOURCE,$(f))),$(f)))

define CPP_RULE # <library> <c|S> <orig-source> <source> <source-args> <rest-rules>
$(1).DEP += $(call GEN_P,$(1),$(3),,d)
$(1).TMP += $(call GEN_P,$(1),$(3),e)
$(call GEN_P,$(1),$(3),e): $(4)
	@echo TARGET $(1) CPP $(2) $$< $(5)
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$$($(1).CC) -MD -MF $(call GEN_P,$(1),$(3),,d) -E $$($(1).CFLAGS_EXPANDED) $(call PARAMS_TO_DEFS,$(5)) -o $$@ $$<
$(call NEXT_RULE,$(1),$(2),$(3),$(call GEN_P,$(1),$(3),e),$(5),$(6))
endef

define OBJ_RULE # <library> <c|S> <orig-source> <source> <destination> <source-args> <rest-rules>
$(call GEN_P,$(1),$(3),,o): $(4)
	@echo TARGET $(1) OBJ $(2) $$< $(5)
	$(Q)$$($(1).CC) -c -fpreprocessed $$(filter-out -D%,$$($(1).CFLAGS_EXPANDED)) -o $$@ $$<
$(call NEXT_RULE,$(1),$(2),$(3),$(call GEN_P,$(1),$(3),,o),$(5),$(6))
endef

define CPPOBJ_RULE # <library> <c|S> <orig-source> <source> <source-args> <rest-rules>
$(1).DEP += $(call GEN_P,$(1),$(3),,d)
$(call GEN_P,$(1),$(3),,o): $(4)
	@echo TARGET $(1) CC OBJ $(2) $$< $(5)
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$$($(1).CC) -MD -MF $(call GEN_P,$(1),$(3),,d) -c $$($(1).CFLAGS_EXPANDED) -o $$@ $$<
$(call NEXT_RULE,$(1),$(2),$(3),$(call GEN_P,$(1),$(3),,o),$(5),$(6))
endef

CC_BLOB_NAME = $(subst .,_,$(notdir $(1)))

define CCPRE_RULE # <library> <c|S> <orig-source> <source> <source-args> <rest-rules>
ifeq (,$(filter c S,$(2)))
$(1).TMP += $(call GEN_P,$(1),$(3),,S)
$(call GEN_P,$(1),$(3),,S): symbol_prefix=$(or $(call CC_GET_VALUE,symbol,$(5)),$(call CC_BLOB_NAME,$(3)))
$(call GEN_P,$(1),$(3),,S): $(4)
	@echo TARGET $(1) GEN BLOB $$(notdir $$<)
	$(Q)mkdir -p $$(dir $$@)
	$(Q)echo '  .section $$(or $(call CC_GET_VALUE,section,$(5)),$$($(1).RODATA),.rodata)' > $$@
	$(Q)echo '  .align $(or $(call CC_GET_VALUE,align,$(5)),4)' >> $$@
	$(Q)echo '  /* pointer to data array */' >> $$@
	$(Q)echo '  /* const unsigned char $$(symbol_prefix)[]; */' >> $$@
	$(Q)echo '  .global $$(symbol_prefix)' >> $$@
	$(Q)echo '  /* size of data array */' >> $$@
	$(Q)echo '  /* const unsigned int $$(symbol_prefix)_len; */' >> $$@
	$(Q)echo '  .global $$(symbol_prefix)_len' >> $$@
	$(Q)echo '  .global $$(symbol_prefix)_size' >> $$@
	$(Q)echo '  /* pointer to beginning of data */' >> $$@
	$(Q)echo '  /* const unsigned char $$(symbol_prefix)_start[]; */' >> $$@
	$(Q)echo '  .global $$(symbol_prefix)_start' >> $$@
	$(Q)echo '  /* pointer to end of data */' >> $$@
	$(Q)echo '  /* const unsigned char $$(symbol_prefix)_end[]; */' >> $$@
	$(Q)echo '  .global $$(symbol_prefix)_end' >> $$@
	$(Q)echo '$$(symbol_prefix):' >> $$@
	$(Q)echo '$$(symbol_prefix)_start:' >> $$@
	$(Q)echo '  .incbin "$$<"' >> $$@
	$(Q)echo '$$(symbol_prefix)_end:' >> $$@
	$(Q)echo '$$(symbol_prefix)_len:' >> $$@
	$(Q)echo '$$(symbol_prefix)_size:' >> $$@
	$(Q)echo '  .word $$(symbol_prefix)_end - $$(symbol_prefix)_start' >> $$@
$(call NEXT_RULE,$(1),$(2),$(3),$(call GEN_P,$(1),$(3),,S),$(5),$(6))
else
$(call NEXT_RULE,$(1),$(2),$(3),$(4),$(5),$(6))
endif
endef

define CCEND_RULE # <library> <c|S> <orig-source> <source> <source-args> <rest-rules>
$(1).OBJ += $(4)
endef

define CC_RULE # <library> <c|S> <source>
$$(eval $$(call NEXT_RULE,$(1),$(2),$(call CC_GET_SOURCE,$(3)),$(call CC_GET_SOURCE,$(3)),$(call CC_GET_PARAMS,$(3)),$$(or $$($(1).CCPIPE.$(2)),$$($(1).CCPIPE),CCPRE_RULE CPPOBJ_RULE) CCEND_RULE))
# flymake support
ifneq (,$$(filter $$(patsubst %.$(2),%_flymake.$(2),$(3)),$$(CHK_SOURCES)))
check-syntax: check-syntax-$(3)
check-syntax-$(3): $$(patsubst %.$(2),%_flymake.$(2),$(call CC_GET_SOURCE,$(3)))
	$(Q)$$($(1).CC) -c -DFLYMAKE $$($(1).CFLAGS_EXPANDED) $(call PARAMS_TO_DEFS,$(call CC_GET_PARAMS,$(3))) -o /dev/null $$<
endif
endef

UNIQ_FILE_EXTS = $(sort $(foreach f,$(1),$(patsubst $(basename $(call CC_GET_SOURCE,$(f))).%,%,$(call CC_GET_SOURCE,$(f)))))

# Compilation rules
define CC_RULES # <library>
$$(foreach e,$$(call UNIQ_FILE_EXTS,$$($(1).SRCS)),\
$$(foreach f,$$(call FILTER_SOURCES,%.$$(e),$$($(1).SRCS)),\
$$(eval $$(call CC_RULE,$(1),$$(e),$$(f)))))
endef

COMMON_CCARGS := ADD:SPECS ADD:CFLAGS ADD:CDIRS ADD:CDEFS \
  SET:CSTD ADD:CWARN SET:COPT SET:CDBG ADD:COPTS ADD:CMACH \
  SET:CCPIPE SET:CCPIPE.c SET:CCPIPE.S ADD:CCARGS ADD:DUMPOPTS \
  SET:RODATA

INHERITS_ARGS = $(foreach g,$(COMMON_TCARGS) $(COMMON_$(2)) $($(1).$(2)),\
$(call INHERITS,$(1),$(firstword $(subst :, ,$(g))),$(lastword $(subst :, ,$(g)))))

# Expand profile flags
define CFLAGS_EXPAND
ifndef $(1).CFLAGS_EXPANDED
$$(foreach parent,$$($(1).INHERIT),$$(eval $$(call CFLAGS_EXPAND,$$(parent))))

$$(call INHERITS_ARGS,$(1),CCARGS)

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
$$(eval $$(call CC_RULES,$(1)))

-include $$($(1).DEP)

$(1).OBJS += $$(foreach lib,$$(filter-out $(1),$$($(1).DEPLIBS*)),$$($$(lib).OBJS))
$(1).OBJS += $$($(1).OBJ)

$(1).NAME ?= $(1)
$(1).LIB := $$(call LIB_P,$$($(1).NAME))

build: build.lib.$(1)
build.lib.$(1): $$($(1).LIB)

$$($(1).LIB): $$($(1).OBJS)
	@echo TARGET $(1) LIB
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$$($(1).AR) ru $$@ $$^
	$(Q)$$($(1).AR) s $$@

clean: clean.lib.$(1)
clean.lib.$(1):
	@echo TARGET $(1) LIB CLEAN
	$(Q)rm -f $$($(1).LIB) $$($(1).OBJ) $$($(1).DEP) $$($(1).TMP)

$$(eval $$(call ANALYZE_RULES,$(1),$$($(1).LIB)))
endef

LD_WHOLE = $(if $(strip $(1)),-Wl$(strip ,)--whole-archive $(1) -Wl$(strip ,)--no-whole-archive)
LD_GROUP = $(if $(strip $(1)),-Wl$(strip ,)--start-group $(1) -Wl$(strip ,)--end-group)

COMMON_LDARGS := ADD:CMACH ADD:SPECS ADD:LDFLAGS ADD:LDDIRS \
  SET:LDSCRIPT ADD:LDSCRIPTS ADD:UNDEFS ADD:LDOPTS ADD:DEPLIBS \
  ADD:DEPLIBS* ADD:DEPLIBS& ADD:LDLIBS ADD:GDBOPTS ADD:DUMPOPTS \
  ADD:ENVIRON ADD:CMDLINE

# Expand profile flags
define LDFLAGS_EXPAND
ifndef $(1).LDFLAGS_EXPANDED
$$(foreach parent,$$($(1).INHERIT),$$(eval $$(call LDFLAGS_EXPAND,$$(parent))))

$$(call INHERITS_ARGS,$(1),LDARGS)

$(1).LDFLAGS_EXPANDED := \
  $$(addprefix -m,$$($(1).CMACH) $$($(1).CMACH!)) \
  $$($(1).LDFLAGS) $$($(1).LDFLAGS!) \
  $$(patsubst %,--specs=%.specs,$$($(1).SPECS) $$($(1).SPECS!)) \
  $$(addprefix -L,$$($(1).LDDIRS) $$($(1).LDDIRS!)) \
  $$(if $$($(1).LDSCRIPT),-T$$($(1).LDSCRIPT)) \
  $$(addprefix -u ,$$($(1).UNDEFS) $$($(1).UNDEFS!)) \
  $$(addprefix -Wl$$(strip ,)-,$$($(1).LDOPTS) $$($(1).LDOPTS!))
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

$(1).NAME ?= $(1)
$(1).DYN := $$(call DYN_P,$$($(1).NAME),$$($(1).DYNVER))
$(1).DYN_NAME := $$(call DYN_P,$$($(1).NAME),$$(word 1,$$(subst ., ,$$($(1).DYNVER))))
$(1).DYN_PURE := $$(call DYN_P,$$($(1).NAME))
$(1).MAP := $$(call MAP_P,$$($(1).NAME))

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
	$(Q)$$($(1).CCLD) -shared $$($(1).LDFLAGS_EXPANDED) -Wl,-soname,$$(notdir $$($(1).DYN_NAME)) -Wl,-Map -Wl,$$($(1).MAP) $$(call LD_WHOLE,$$($(1).DEPLIBS_EXPANDED*)) $$($(1).DEPLIBS_EXPANDED) $$(call LD_GROUP,$$($(1).LDLIBS_EXPANDED)) -o $$@
	$(Q)$$($(1).SIZE) $$@

clean: clean.dyn.$(1)
clean.dyn.$(1):
	@echo TARGET $(1) DYN CLEAN
	$(Q)rm -f $$($(1).DYN) $$($(1).MAP)

$$(eval $$(call ANALYZE_RULES,$(1),$$($(1).DYN)))
endef

# Binary rules
define BIN_RULES
$$(eval $$(call LDFLAGS_EXPAND,$(1)))

$(1).NAME ?= $(1)
$(1).BIN := $$(call BIN_P,$$($(1).NAME))
$(1).MAP := $$(call MAP_P,$$($(1).NAME))

build: build.bin.$(1)
build.bin.$(1): $$($(1).BIN)

$$($(1).BIN): $$($(1).DEPLIBS_EXPANDED_) $$($(1).LDSCRIPTS)
	@echo TARGET $(1) BIN
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$$($(1).CCLD) $$($(1).LDFLAGS_EXPANDED) -Wl,-Map -Wl,$$($(1).MAP) $$(call LD_WHOLE,$$($(1).DEPLIBS_EXPANDED*)) $$($(1).DEPLIBS_EXPANDED) $$(call LD_GROUP,$$($(1).LDLIBS_EXPANDED)) -o $$@
	$(Q)$$($(1).SIZE) $$@

clean: clean.bin.$(1)
clean.bin.$(1):
	@echo TARGET $(1) BIN CLEAN
	$(Q)rm -f $$($(1).BIN) $$($(1).MAP)

run.$(1): $$($(1).BIN)
	@echo RUN $(1)
	$(Q)$$(if $$($(1).ENVIRON),$$($(1).ENVIRON) )$$($(1).BIN)$$(if $$($(1).CMDLINE), $$($(1).CMDLINE))

debug.$(1): $$($(1).BIN)
	@echo RUN GDB $(1)
	$(Q)$$(if $$($(1).ENVIRON),$$($(1).ENVIRON) )$$($(1).GDB) -ex 'file $$($(1).BIN)'$$(if $$($(1).CMDLINE), -ex 'set args $$($(1).CMDLINE)') $$($(1).GDBOPTS)

valgrind.$(1): $$($(1).BIN)
	@echo RUN VALGRIND $(1)
	$(Q)$$(if $$($(1).ENVIRON),$$($(1).ENVIRON) )$$($(1).VALGRIND) --leak-check=full --show-leak-kinds=all --track-origins=yes -v --log-file=$$($(1).BIN).valgrind $$($(1).BIN)$$(if $$($(1).CMDLINE), $$($(1).CMDLINE))

$$(eval $$(call ANALYZE_RULES,$(1),$$($(1).BIN)))
endef
