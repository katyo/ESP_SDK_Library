/******************************************************************************
 * FileName: gpio_bios.h
 * Description: rtc & dtm funcs in ROM-BIOS
 * Alternate SDK
 * Author: PV`
 * (c) PV` 2015
 *******************************************************************************/
#ifndef _BIOS_RTC_DTM_H_
#  define _BIOS_RTC_DTM_H_

#  include "c_types.h"

/*
   PROVIDE ( ets_rtc_int_register = 0x40002a40 );
   PROVIDE ( ets_enter_sleep = 0x400027b8 );
   PROVIDE ( rtc_enter_sleep = 0x40002870 );
   PROVIDE ( rtc_get_reset_reason = 0x400025e0 );
   PROVIDE ( rtc_intr_handler = 0x400029ec );
   PROVIDE ( rtc_set_sleep_mode = 0x40002668 );
   PROVIDE ( dtm_get_intr_mask = 0x400026d0 );
   PROVIDE ( dtm_params_init = 0x4000269c );
   PROVIDE ( dtm_set_intr_mask = 0x400026c8 );
   PROVIDE ( dtm_set_params = 0x400026dc );
   PROVIDE ( software_reset = 0x4000264c );
   PROVIDE ( save_rxbcn_mactime = 0x400027a4 );
   PROVIDE ( save_tsf_us = 0x400027ac );
 */

struct sdtm_params {		/* RAM_BIOS:3FFFDD64 */
  ETSTimer timer;		/* +0x00..0x14 */
  uint32_t dtm_14;		/* +0x14 // a6 dtm_set_params */
  uint32_t rxbcn_mactime;		/* +0x18 */
  uint32_t tsf_us;		/* +0x1C */
  uint32_t sleep_time;		/* +0x20 time */
  uint32_t timer_us;		/* +0x24 */
  uint32_t time_ms;		/* +0x28 */
  uint32_t dtm_2C;		/* +0x2C // a4 dtm_set_params */
  uint32_t mode;			/* +0x30 */
  uint32_t cycles;		/* +0x34 timer cycles */
  uint32_t intr_mask;		/* +0x38 */
  uint32_t sleep_func;		/* +0x3C */
  uint32_t int_func;		/* +0x40 */
  uint32_t dtm_44;		/* +0x44 */
};

/* RAM_BIOS:3FFFDD64 */
extern struct sdtm_params dtm_params;	/* 64 bytes */

/* RAM_BIOS:3FFFC700 */
extern uint32_t rtc_claib;	/* ~ = 0x7073 */

/* software_reset: Not work for any mode! */
void software_reset(void);
void rtc_set_sleep_mode(uint32_t a, uint32_t t, uint32_t m);

/*rtc_reset_reason: =1 - ch_pd,  =2 - reset, =4 - Wdt Reset ... > 7 unknown reset */
uint32_t rtc_get_reset_reason(void);
void save_rxbcn_mactime(uint32_t t);
void save_tsf_us(uint32_t us);
void dtm_set_intr_mask(uint32_t mask);
uint32_t dtm_get_intr_mask(void);
void dtm_params_init(void *sleep_func, void *int_func);
void dtm_set_params(int mode, int time_ms_a3, int a4, int cycles, int a6);
void rtc_intr_handler(void);
void rtc_enter_sleep(void);
void ets_rtc_int_register(void);

/* { ets_set_idle_cb(rtc_enter_sleep, 0); } */
void ets_enter_sleep(void);

#endif /* _BIOS_RTC_DTM_H_ */
