OPT_OPT = $(if $(filter y yes t true on,$($(1))),$(1))
OPT_VAL = $(1)=$($(1))
OPT_STR = $(1)=\"$($(1))\"

POINT_CHAR := .
COMMA_CHAR := ,
OPT_IP4 = $(1)='IP4_UINT($(subst $(POINT_CHAR),$(COMMA_CHAR),$($(1))))'

COL_WORDS = $(words $(subst :, ,$(1)_))
COL_WORD = $(word $(1),$(subst :, ,$(2)))

define OPT_RULES
ifeq (3,$$(call COL_WORDS,$(2)))
$$(call COL_WORD,2,$(2)).DEF := $$(call COL_WORD,3,$(2))
$$(call COL_WORD,2,$(2)) ?= $$(call COL_WORD,3,$(2))
endif
ifdef $$(call COL_WORD,2,$(2))
$(1).CDEFS += $$(call OPT_$$(call COL_WORD,1,$(2)),$$(call COL_WORD,2,$(2)))
endif
endef

define OPT_SHOW
$(1): $(1)-option.$$(call COL_WORD,2,$(2))
$(1)-option.$$(call COL_WORD,2,$(2)):
ifdef $$(call COL_WORD,2,$(2)).DEF
	@echo [$$(call COL_WORD,1,$(2))] $$(call COL_WORD,2,$(2)) = $$($$(call COL_WORD,2,$(2))) $$(if $$(filter $$($$(call COL_WORD,2,$(2)).DEF),$$($$(call COL_WORD,2,$(2)))),[default],[custom])
else
ifdef $$(call COL_WORD,2,$(2))
	@echo [$$(call COL_WORD,1,$(2))] $$(call COL_WORD,2,$(2)) = $$($$(call COL_WORD,2,$(2)))
else
	@echo [$$(call COL_WORD,1,$(2))] $$(call COL_WORD,2,$(2)) = [undefined]
endif
endif
endef
