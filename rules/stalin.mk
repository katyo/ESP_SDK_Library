debug.COPT = g
debug.CDBG = gdb3
debug.CDEFS += USE_DEBUG=1

release.COPT = s
release.CDBG = gdb3
release.CDEFS += USE_DEBUG=0
#release.COPTS += omit-frame-pointer strict-aliasing

tyrant.CWARN = all extra shadow undef implicit-function-declaration redundant-decls missing-prototypes strict-prototypes no-pointer-sign pointer-arith
gentle.CWARN = error

stalin.mode ?= release
stalin.role ?= tyrant

stalin.BASEPATH := $(dir $(lastword $(MAKEFILE_LIST)))
stalin.INHERIT = $(stalin.mode) $(stalin.role)
stalin.CSTD = gnu99
stalin.CDEFS = _GNU_SOURCE
stalin.COPTS = function-sections data-sections
#stalin.COPTS += no-exceptions no-common
stalin.COPTS += no-inline-functions

stalin.OPTS = $(stalin.BASEPATH)stalin.cf
TARGET.OPTS += stalin
