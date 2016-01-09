/******************************************************************************
 * FileName: wdt.h
 * Description: Alternate SDK (libmain.a)
 * Author: PV`
 * (c) PV` 2015
 * ver 0.0.0 (b0)
 *******************************************************************************/

#ifndef _INCLUDE_WDT_H_
#  define _INCLUDE_WDT_H_

#  include "ets_sys.h"
#  include "sdk/fatal_errs.h"

#  if DEF_SDK_VERSION >= 1119	/* (SDK 1.1.1..1.1.2) */
void
wdt_init(int flg)
  ICACHE_FLASH_ATTR;
#  else
void
wdt_init(void)
  ICACHE_FLASH_ATTR;
     void wdt_feed(void);
     void wdt_task(ETSEvent * e);
#  endif

/* #define DEBUG_EXCEPTION // для отладки */

#  ifdef DEBUG_EXCEPTION
     struct exception_frame {
       uint32_t epc;
       uint32_t ps;
       uint32_t sar;
       uint32_t unused;
       union {
	 struct {
	   uint32_t a0;
	   /* note: no a1 here! */
	   uint32_t a2;
	   uint32_t a3;
	   uint32_t a4;
	   uint32_t a5;
	   uint32_t a6;
	   uint32_t a7;
	   uint32_t a8;
	   uint32_t a9;
	   uint32_t a10;
	   uint32_t a11;
	   uint32_t a12;
	   uint32_t a13;
	   uint32_t a14;
	   uint32_t a15;
	 };
	 uint32_t a_reg[15];
       };
       uint32_t cause;
     };
     void default_exception_handler(struct exception_frame *ef, uint32_t cause);
#  else
     void default_exception_handler(void);
#  endif

     void store_exception_error(uint32_t errn);

     void os_print_reset_error(void) ICACHE_FLASH_ATTR;


#endif /* _INCLUDE_WDT_H_ */
