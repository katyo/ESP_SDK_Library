OPT_P = gen/option/$(call FIXPATH,$(1)).mk

# <path>
option-pure = $(notdir $(basename $(1)))

# <owner>
option-list = $($(1).option)
# <owner> <option> <field>
option-read = $($(1).option.$(2).$(3))
# <owner> <option> <field>
option-has = $(filter-out undefined,$(flavor $(1).option.$(2).$(3)))

option-eq- = $(and $(filter x$(1),x$(2)),$(filter x$(2),x$(1)))
option-eq = $(call option-eq-,$(strip $(1)),$(strip $(2)))

option-flag = $(if $(call option-has,$(1),$(2),gen),generated,$(if $(call option-has,$(1),$(2),def),$(if $(call option-eq,$(call option-read,$(1),$(2),def),$($(2))),default,custom)))

option-true = $(filter yes on true enable y 1,$(1))

# <key> <val>
option-put.def = $(if $(call option-true,$(2)),-D$(1))
option-put.opt = -D$(1)=$(if $(call option-true,$(2)),1,0)
option-put.val = -D$(1)='$(2)'
option-put.str = -D$(1)='"$(2)"'
option-wrap.ver = _($(1))
option-put.ver = -D$(1)='$(call option-wrap.ver,$(subst .,$(strip ,),$(2)))' -D$(1)_NUM='{$(subst .,$(strip ,),$(2))}' -D$(1)_STR='"$(2)"'
option-put.sym = -D$(1)='$(2)' -D$(1)_STR='"$(2)"'
option-put.set = -D$(1)='$(subst $(strip) ,,$(patsubst %,_(%),$(2)))'

option-wrap.ipv4 = $(1)
option-put.ipv4 = -D$(1)='$(call option-wrap.ipv4,$(subst .,$(strip ,),$(2)))'
option-wrap.mac = $(1)
option-put.mac = -D$(1)='$(call option-wrap.mac,0x$(subst :,$(strip ,0x),$(2)))'

# <style> <text>
option-pretty = $(option-style-$(1))$(2)\e[0m\e[39m\e[49m
option-pretty-flag = $(if $(1),$(call option-pretty,$(1),[$(1)]))

option-style-type = \e[1m\e[31m
option-style-name = \e[0m\e[94m
option-style-value = \e[0m\e[92m
option-style-key = \e[1m\e[36m
option-style-generated = \e[95m
option-style-default = \e[2m\e[97m
option-style-custom = \e[93m
option-style-info = \e[37m

# <owner> <option> <target>
define OPT_PROC
$(2) ?= $$(call option-read,$(1),$(2),def)
ifneq (,$$(call option-read,$(1),$(2),key))
$(3).CFLAGS += $$(call option-put.$$(call option-read,$(1),$(2),type),$$(call option-read,$(1),$(2),key),$$(strip $$($(2))))
endif
show.option.$(1).$(2):
	@echo -e '$$(call option-pretty,type,$$(call option-read,$(1),$(2),type)) $$(call option-pretty,name,$(2)) = $$(call option-pretty,value,$$($(2))) \
	  $$(call option-pretty-flag,$$(call option-flag,$(1),$(2))) \
	  $$(if $$(call option-read,$(1),$(2),key),$$(call option-pretty,key,#$$(call option-read,$(1),$(2),key)#))'
info.option.$(1).$(2): show.option.$(1).$(2)
	@echo -e '  $$(call option-pretty,info,$$(call option-read,$(1),$(2),info))'
.PHONY: show.option.$(1).$(2) info.option.$(1).$(2)
endef

# <owner> <def-file> <target>
define OPT_MAKE
ifndef $(call OPT_P,$(2))
$(call OPT_P,$(2)) := p
$(call OPT_P,$(2)): $(2)
	@echo OPT PARSE $(1) FROM $(2)
	$(Q)mkdir -p $$(dir $$@)
	$(Q)echo option=$$(call uniq,$$(patsubst option.%,%,$$(shell git config -f '$$<' --list | grep '^option\.' | sed 's/^\([^=]*\)$$$$/\1=/g' | sed 's/^\([^=]*\)\.[^=]*=.*/\1/g'))) >'$$@'
	$(Q)git config -f '$$<' --list | grep '^option\.' | sed 's/^\([^=]*\)$$$$/\1=/g' >>'$$@'
	$(Q)sed -i 's/^/$(subst /,\/,$(1))./g' '$$@'
-include $(call OPT_P,$(2))
endif
$$(foreach o,$$(call option-list,$(1)),$$(eval $$(call OPT_PROC,$(1),$$(o),$(3))))
show.option: show.option.$(1)
info.option: info.option.$(1)
show.option.$(1): $$(addprefix show.option.$(1).,$$(call option-list,$(1)))
info.option.$(1): $$(addprefix info.option.$(1).,$$(call option-list,$(1)))
.PHONY: show.option.$(1) info.option.$(1)
endef

.PHONY: show.option info.option

define OPT_APPLY
ifneq (,$(strip $(2)))
ifndef $(1).$(call option-pure,$(firstword $(2))).option
#$$(info undefined $(1).$(firstword $(2)).option)
$(1).$(call option-pure,$(firstword $(2))).option := 1
#$$(info $($(1).$(firstword $(2)).option))
$$(eval $$(call OPT_MAKE,$(1).$(call option-pure,$(firstword $(2))),$(firstword $(2)),$(1)))
$$(eval $$(call OPT_RULES,$(1)))
else
#$$(info 2:$(2))
$$(eval $$(call OPT_APPLY,$(1),$(wordlist 2,$(words $(2)),$(2))))
endif
endif
endef

define OPT_RULES
ifdef $(1).OPTS
$$(eval $$(call OPT_APPLY,$(1),$$($(1).OPTS)))
endif
endef
