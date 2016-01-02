/*
 * C types
 */

#ifndef _C_TYPES_H_
#define _C_TYPES_H_

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

typedef int8_t   sint8_t;
typedef int16_t  sint16_t;
typedef int32_t  sint32_t;
typedef int64_t  sint64_t;
typedef uint64_t u_int64_t;
typedef float    real32_t;
typedef double   real64_t;

typedef uint8_t  uint8;
typedef uint8_t  u8;
typedef int8_t   sint8;
typedef int8_t   int8;
typedef int8_t   s8;
typedef uint16_t uint16;
typedef uint16_t u16;
typedef int16_t  sint16;
typedef int16_t  s16;
typedef uint32_t uint32;
typedef uint32_t u_int;
typedef uint32_t u32;
typedef int32_t  sint32;
typedef int32_t  s32;
typedef int32_t  int32;
typedef int64_t  sint64;
typedef uint64_t uint64;
typedef uint64_t u64;
typedef real32_t real32;
typedef real64_t real64;

#define __le16 u16

typedef signed char  err_t;


#define __packed        __attribute__((packed))

#define LOCAL       static

#ifndef NULL
#define NULL (void *)0
#endif /* NULL */

/* probably should not put STATUS here */
typedef enum {
    OK = 0,
    FAIL,
    PENDING,
    BUSY,
    CANCEL,
} STATUS;

#define BIT(nr)                 (1UL << (nr))

#define REG_SET_BIT(_r, _b)  (*(volatile uint32_t*)(_r) |= (_b))
#define REG_CLR_BIT(_r, _b)  (*(volatile uint32_t*)(_r) &= ~(_b))

#define DMEM_ATTR __attribute__((section(".bss")))
#define SHMEM_ATTR

#ifdef ICACHE_FLASH
#define ICACHE_FLASH_ATTR __attribute__((section(".irom0.text")))
#define ICACHE_RODATA_ATTR __attribute__((aligned(4),section(".irom.text")))
#else
#define ICACHE_FLASH_ATTR
#define ICACHE_RODATA_ATTR
#endif

#ifndef DATA_IRAM_ATTR
#define DATA_IRAM_ATTR __attribute__((aligned(4), section(".iram.data")))
#endif

#define __forceinline __attribute__((always_inline)) inline

#ifndef __cplusplus

#define BOOL  bool
#define TRUE  true
#define FALSE false

#endif /* !__cplusplus */

#endif /* _C_TYPES_H_ */
