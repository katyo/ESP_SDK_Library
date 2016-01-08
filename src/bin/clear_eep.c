#include <stdint.h>
#include "user_interface.h"

const uint8_t clear_eep[] ICACHE_RODATA_ATTR = {
  [0 ... 0x3000-1] = 0xff
};
