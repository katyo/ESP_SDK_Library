/*
 * FileName: pplibadd.c
 * Description: Alternate SDK (libpp.a)
 * (c) PV` 2015
 */
#include "c_types.h"
#include "user_config.h"

#if DEF_SDK_VERSION >= 1300
/* bit_popcount() используется из SDK libpp.a: if_hwctrl.o и trc.o */
uint32_t
bit_popcount(uint32_t x) {
  uint32_t ret = 0;

  while (x) {
    ret += x & 1;
    x >>= 1;
  }
  return ret;
}
#endif
