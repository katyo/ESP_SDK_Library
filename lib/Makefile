# Compiler configuration
COMPILER_PREFIX ?= $(if $(COMPILER_PATH),$(COMPILER_PATH)/)xtensa-lx106-elf-

AR := $(COMPILER_PREFIX)ar
OBJDUMP := $(COMPILER_PREFIX)objdump
OBJCOPY := $(COMPILER_PREFIX)objcopy

LIB_NAMES += gcc main phy wpa net80211 pp

SOURCE_LIBP ?= esp141/lib%.a
TARGET_LIBP ?= esp/lib%.a

#SOURCE_LIBS := $(patsubst %,$(SOURCE_LIBP),$(LIB_NAMES))
TARGET_LIBS := $(patsubst %,$(TARGET_LIBP),$(LIB_NAMES))

gcc.DELETE_OBJECTS := \
  _fixunsdfsi _umoddi3 _umodsi3 _extendsfdf2 _fixdfsi _divsi3 _divdf3 _divdi3 _fixunssfsi \
  _floatsidf _floatsisf _floatunsidf _floatunsisf _muldf3 _muldi3 _mulsf3 _truncdfsf2 \
  _udivdi3 _udivsi3 _umulsidi3 _addsubdf3 _addsubsf3

#main.DELETE_OBJECTS := \
#  eagle_lib ets_timer mem_manager user_interface eagle_lwip_if \
#  spi_flash app_main ets_timer eagle_lwip_if mem_manager eagle_lib

main.NEEDED_OBJECTS := \
  user_interface

#phy.DELETE_OBJECTS := \
#  phy phy_chip_v6 phy_chip_v6_ana phy_chip_v6_cal phy_sleep \
#  ate_test phy_chip_v6_unused

phy.NEEDED_OBJECTS := \
  phy phy_chip_v6 phy_chip_v6_ana phy_chip_v6_cal phy_sleep

wpa.NEEDED_OBJECTS := \
  aes-internal-enc aes-wrap ap_config common ieee802_1x \
  sta_info wpa wpa_auth wpa_auth_ie wpa_common wpa_ie \
  wpa_main wpabuf wpas_glue

RENAME_SECTIONS := \
  .literal=.iram0.literal \
  .text=.iram0.text \
#  .rodata=.dram0.rodata

REDEFINE_SYMBOLS_ := \
  pvPortZalloc=port_zalloc \
  pvPortMalloc=port_malloc \
  pvPortCalloc=port_calloc \
  pvPortRealloc=port_realloc \
  vPortFree=port_free \
  xPortGetFreeHeapSize=port_free_heap \
  xPortWantedSizeAlign=port_size_align

OBJCOPY_FLAGS += $(addprefix --rename-section ,$(RENAME_SECTIONS))
OBJCOPY_FLAGS += $(addprefix --redefine-sym ,$(REDEFINE_SYMBOLS))

default: $(TARGET_LIBS)

$(TARGET_LIBP): $(SOURCE_LIBP)
	mkdir -p $(dir $@)
	$(OBJCOPY) $(OBJCOPY_FLAGS) $< $@
	$(if $($*.DELETE_OBJECTS),$(AR) d $@ $(patsubst %,%.o,$($*.DELETE_OBJECTS)))
	$(if $($*.NEEDED_OBJECTS), \
	  mkdir $*~content && \
	  cd $*~content && \
	  $(AR) x $(abspath $@) && \
	  rm -f $(abspath $@) && \
	  $(AR) ru $(abspath $@) $(patsubst %,%.o,$($*.NEEDED_OBJECTS)) && \
	  cd - && \
	  rm -rf $*~content)

clean:
	rm -rf $(TARGET_LIBS)

diff:
	$(OBJDUMP) -S $(subst %,*,$(TARGET_LIBP)) > t.dump
	$(OBJDUMP) -S $(subst %,*,$(SOURCE_LIBP)) > s.dump
	diff s.dump t.dump | less
	rm -f t.dump s.dump
