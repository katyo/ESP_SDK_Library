#ifndef _sdk_config_h_
#  define _sdk_config_h_

#  ifndef SDK_NAME_STR
#    define SDK_NAME_STR "meSDK"
#  endif

#  define DEF_SDK_VERSION 1500	/* 1302 // ver 1.3.0 + patch (lib_1.3.0_deep_sleep_plus_freq_offset_plus_freedom_callback_02.zip SDK ver: 1.3.0 compiled @ Aug 19 2015 17:50:07) */
#  define SDK_VERSION_STR "1.5.0"

#  ifndef DEBUGSOO
#    define DEBUGSOO 2		/* 0 - откл вывода, 1 - минимум, 2 - норма, >3 - текушая отладка, >4 - удалить что найдется :) */
#  endif

#  ifndef DEBUG_UART
#    define DEBUG_UART 1	/* включить вывод в загрузчике сообщений, номер UART */
#  endif

#  ifndef DEBUG_UART0_BAUD
#    define DEBUG_UART0_BAUD 115200
#  endif

#  ifndef DEBUG_UART0_BAUD
#    define DEBUG_UART1_BAUD 230400
#  endif

#  define IP4_UINT(a, b, c, d) \
  (((a) & 0xff) |              \
   (((b) & 0xff) << 8) |       \
   (((c) & 0xff) << 16) |      \
   (((d) & 0xff) << 24))

#  ifndef SOFTAP_GATEWAY
#    define SOFTAP_GATEWAY IP4_UINT(192, 168, 4, 1)
#  endif

#  ifndef SOFTAP_IP_ADDR
#    define SOFTAP_IP_ADDR SOFTAP_GATEWAY
#  endif

#  ifndef SOFTAP_NETMASK
#    define SOFTAP_NETMASK IP4_UINT(255, 255, 255, 0)
#  endif

#  define STARTUP_CPU_CLK 160

#  ifndef DATA_IRAM_ATTR
#    define DATA_IRAM_ATTR __attribute__((aligned(4), section(".iram.data")))
#  endif

#  ifndef ENTRY_POINT_ATTR
#    define ENTRY_POINT_ATTR __attribute__ ((section(".entry.text")))
#  endif

#  ifndef ICACHE_RODATA_ATTR
#    define ICACHE_RODATA_ATTR  __attribute__((aligned(4), section(".irom0.rodata")))
#  endif

#  ifndef ICACHE_IRAM_ATTR
#    define ICACHE_IRAM_ATTR __attribute__((section(".iram0.text")))
#  endif

/* #define USE_OPEN_LWIP 140 // использовать OpenLwIP 1.4.0 (назначается в app/MakeFile #USE_OPEN_LWIP = 140)
 #define USE_OPEN_DHCPS 1	 // использовать исходник или либу из SDK (назначается в app/MakeFile #USE_OPEN_DHCP = 1) */

/* #ifndef USE_MAX_IRAM
   #define USE_MAX_IRAM  48 // использовать часть cache под IRAM, IRAM size = 49152 байт
 #endif */

/* USE_FIX_SDK_FLASH_SIZE - включена "песочница" для SDK в 512 килобайт flash. */

/*  USE_FIX_QSPI_FLASH - использовать фиксированную частоту работы QPI
   и 'песочницу' в 512 кбайт для SDK с flash
   Опции:
    80 - 80 MHz QSPI
      другое значение - 40 MHz QSPI */

#  ifdef USE_FIX_QSPI_FLASH
#    define USE_FIX_SDK_FLASH_SIZE
#  endif

/* #define USE_READ_ALIGN_ISR // побайтный доступ к IRAM и cache Flash через EXCCAUSE_LOAD_STORE_ERROR */

/* #define USE_OVERLAP_MODE // используются две и более flash */

/* #define USE_TIMER0 // использовать аппаратный таймер 0 (NMI или стандартное прерывание)
 #define TIMER0_USE_NMI_VECTOR	// использовать NMI вектор для таймера 0 (перенаправление таблицы векторов CPU) (см main-vectors.c) */

/* #define USE_ETS_RUN_NEW // использовать ets_run_new() вместо ets_run() */

#  ifdef USE_ETS_RUN_NEW
#    define ets_run ets_run_new
#  endif

#  ifdef USE_DEBUG
#    include "gdbstub/gdbstub.h"
#  else
#    define gdbstub_init()
#  endif

#endif /* _sdk_config_h_ */
