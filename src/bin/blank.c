#include <stdint.h>

const uint8_t blank[] = {
  [0 ... 0x1000-1] = 0xff
};
