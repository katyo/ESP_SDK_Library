ifndef MACRO_MK
MACRO_MK:=

#
# Common definitions
#

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
COMMA := ,
PAREN_OPEN := (
PAREN_CLOSE := )

FIXPATH = $(subst ./,,$(subst ../,--/,$(1)))

ifneq ($(V),)
  Q :=
else
  Q := @
endif

#
# Command-line seq command emulation
#

# $1   $2   $3        $4             $5
# step last [counter] [step counter] [sequence accumulator]
__seq4=$(if $(filter $(2),$(words $(3))),\
$(if $(filter $(1),$(words $(4))),$(5) $(words $(3)),$(5)),\
$(if $(filter $(1),$(words $(4))),\
$(call __seq4,$(1),$(2),$(3) .,.,$(5) $(words $(3))),\
$(call __seq4,$(1),$(2),$(3) .,$(4) .,$(5))))

# $1    $2   $3   $4
# first step last [counter]
__seq3=$(if $(filter $(1),$(words $(4))),\
$(call __seq4,$(2),$(3),$(4),,$(words $(4))),\
$(call __seq3,$(1),$(2),$(3),$(4) .))

# $1    $2   $3
# first step last
__seq2=$(if $(filter 0,$(3)),,\
$(call __seq3,$(1),$(2),$(3)))

# [first [step ]]last
__seq1=\
$(if $(filter 1,$(2)),$(call __seq2,1,1,$(1)),\
$(if $(filter 2,$(2)),$(call __seq2,$(word 1,$(1)),1,$(word 2,$(1))),\
$(if $(filter 3,$(2)),$(call __seq2,$(word 1,$(1)),\
$(word 2,$(1)),$(word 3,$(1))),)))

__seq0=$(call __seq1,$(1),$(words $(1)))

seq=$(strip $(call __seq0,$(strip $(1) $(2) $(3))))

equal = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))
tail = $(wordlist 2,$(words $(1)),$(1))
head = $(wordlist 1,$(words $(call tail,$(1))),$(1))
#uniq- = $(if $(1),$(firstword $(1)) $(call uniq-,$(filter-out $(firstword $(1)),$(1))))
#uniq = $(strip $(call uniq-,$(1)))
uniq = $(if $(filter 0,$(words $(1))),,$(word 1,$(1)) $(filter-out $(word 1,$(1)),$(call uniq,$(wordlist 2,$(words $(1)),$(1)))))

#
# Options inheritance
#

define INHERIT_SET
ifneq (,$$($(2).$(3)))
$(1).$(3) ?= $$($(2).$(3))
endif
endef

define INHERIT_ADD
ifneq (,$$($(2).$(3)))
ifeq (,$$(findstring $$($(2).$(3)),$$($(1).$(3))))
$(1).$(3) := $$($(1).$(3)) $$($(2).$(3))
endif
#$(1).$(3) := $$(strip $$(call uniq,$$($(1).$(3)) $$($(2).$(3))))
endif
endef

define INHERIT_ALL # child action option
$$(foreach parent,$$($(1).INHERIT),$$(eval $$(call $(2),$(1),$$(parent),$(3))))
endef

INHERITS = $(eval $(call INHERIT_ALL,$(1),INHERIT_$(2),$(3)))

ADDRULES2 = $(foreach t,$($(2)),$(eval $(call $(1),$(t))))
ADDRULES1 = $(call ADDRULES2,$(word 1,$(1)),$(word 2,$(1)))
ADDRULES = $(foreach e,$(1),$(call ADDRULES1,$(subst :, ,$(e))))

ifdef TEST_MACRO
__test3=$(and $(findstring x $(1),x $(2)),$(findstring x $(2),x $(1)))
__test2=$(if $(call __test3,$(2),$(3)),$(info test seq $(1) pass),\
$(info test seq $(1) fail (expected "$(2)" but actual "$(3)")))
__test1=$(call __test2,$(4),$(strip $(shell seq $(4))),$(call seq,$(1),$(2),$(3)))
test=$(call __test1,$(1),$(2),$(3),$(strip $(1) $(2) $(3)))

$(call test,0)
$(call test,1)
$(call test,10)
$(call test,2,5)
$(call test,0,1,9)
$(call test,0,4,10)
$(call test,2,3,11)
endif

endif # MACRO_MK
