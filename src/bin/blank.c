#include <stdint.h>
#include "user_interface.h"

const uint8_t blank[] ICACHE_RODATA_ATTR = {
  [0 ... 0x1000-1] = 0xff
};
