#ifndef _sdk_config_h_
#  define _sdk_config_h_

#  ifndef SDK_NAME_STR
#    define SDK_NAME_STR "altSDK"
#  endif

#  define DEF_SDK_VERSION 1410	/* 1302 // ver 1.3.0 + patch (lib_1.3.0_deep_sleep_plus_freq_offset_plus_freedom_callback_02.zip SDK ver: 1.3.0 compiled @ Aug 19 2015 17:50:07) */
#  define SDK_VERSION_STR "1.4.1"

#  define DEBUG_CAT2_(P, S) P##S
#  define DEBUG_CAT2(P, S) DEBUG_CAT2_(P, S)

#  define DEBUG_LEVEL_none 0
#  define DEBUG_LEVEL_error 1
#  define DEBUG_LEVEL_info 2
#  define DEBUG_LEVEL_debug 3
#  define DEBUG_LEVEL_all 5

#  define DEBUG_LEVEL_IS(L) (DEBUG_CAT2(DEBUG_LEVEL_, DEBUG_LEVEL) >= DEBUG_CAT2(DEBUG_LEVEL_, L))

#  ifndef DEBUG_LEVEL
#    define DEBUG_LEVEL none
#  endif

#  define DEBUG_LOG(level, format, ...) os_printf("[" #level "]: " format, ##__VA_ARGS__)

#  if DEBUG_LEVEL_IS(error)
#    define DEBUG_LOG_error(format, ...) DEBUG_LOG(error, format, ##__VA_ARGS__)
#  else
#    define DEBUG_LOG_error(format, ...) 
#  endif

#  if DEBUG_LEVEL_IS(debug)
#    define DEBUG_LOG_debug(format, ...) DEBUG_LOG(debug, format, ##__VA_ARGS__)
#  else
#    define DEBUG_LOG_debug(format, ...) 
#  endif

#  if DEBUG_LEVEL_IS(info)
#    define DEBUG_LOG_info(format, ...) DEBUG_LOG(info, format, ##__VA_ARGS__)
#  else
#    define DEBUG_LOG_info(format, ...) 
#  endif

#  define debug_printf(level, format, ...) DEBUG_CAT2(DEBUG_LOG_, level)(format, ##__VA_ARGS__)

#  define DEBUG_OUTPUT_none 0
#  define DEBUG_OUTPUT_uart0 3
#  define DEBUG_OUTPUT_uart1 4

#  define DEBUG_OUTPUT_IS(S) (DEBUG_CAT2(DEBUG_OUTPUT_, DEBUG_OUTPUT) == DEBUG_CAT2(DEBUG_OUTPUT_, S))

#  ifndef DEBUG_OUTPUT
#    define DEBUG_OUTPUT none
#  endif

#  define _IP4_UINT(a, b, c, d) \
  ((uint32_t)((a) & 0xff) |              \
   ((uint32_t)((b) & 0xff) << 8) |       \
   ((uint32_t)((c) & 0xff) << 16) |      \
   ((uint32_t)((d) & 0xff) << 24))
#  define IP4_UINT(...) _IP4_UINT(__VA_ARGS__)

#  ifndef SOFTAP_GATEWAY
#    define SOFTAP_GATEWAY 192,168,4,1
#  endif

#  ifndef SOFTAP_IP_ADDR
#    define SOFTAP_IP_ADDR SOFTAP_GATEWAY
#  endif

#  ifndef SOFTAP_NETMASK
#    define SOFTAP_NETMASK 255,255,255,0
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

#endif /* _sdk_config_h_ */
