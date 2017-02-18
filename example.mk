example.INHERIT = firmware

define EXAMPLE_RULES
TARGET.LIBS += example/lib$(1)
example/lib$(1).INHERIT = example
example/lib$(1).SRCS += $$(wildcard $(libsdk.EXAMPLEDIR)/$(1)/*.c)

TARGET.IMGS += example/$(1)
example/$(1).INHERIT = example/lib$(1)
example/$(1).DEPLIBS& = libsdk example/lib$(1)
endef

EXAMPLES ?= dummy_app mem_usage tcp_echo ssl_echo

$(foreach e,$(EXAMPLES),$(eval $(call EXAMPLE_RULES,$(e))))
