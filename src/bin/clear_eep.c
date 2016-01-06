#include <stdint.h>

const uint8_t clear_eep[] = {
  [0 ... 0x3000-1] = 0xff
};
