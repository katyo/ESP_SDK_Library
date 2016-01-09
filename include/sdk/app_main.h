/******************************************************************************
* FileName: aap_main.h
* Description: Alternate SDK (libmain.a)
* Author: PV`
* (c) PV` 2015
******************************************************************************/

#ifndef _INCLUDE_APP_MAIN_H_
#  define _INCLUDE_APP_MAIN_H_

#  include "sdk/libmain.h"

extern struct s_info info;	/* ip,mask,gw,mac AP, ST */
extern init_done_cb_t done_cb;
extern ETSTimer check_timeouts_timer;	/* timer_lwip */
extern uint8_t user_init_flag;

/* =============================================================================
   funcs libmain.a: app_main.o
   ----------------------------------------------------------------------------- */
void sflash_something(uint32_t flash_speed);
void read_macaddr_from_otp(uint8_t * mac);
void user_uart_wait_tx_fifo_empty(uint32_t n, uint32_t x);
void
startup(void)
  ICACHE_FLASH_ATTR;
     void read_wifi_config(void) ICACHE_FLASH_ATTR;
     void init_wifi(uint8_t * init_data, uint8_t * mac) ICACHE_FLASH_ATTR;
     void uart_wait_tx_fifo_empty(void) ICACHE_FLASH_ATTR;
     void user_uart_wait_tx_fifo_empty(uint32_t uart_num, uint32_t x);

/* ----------------------------------------------------------------------------- */
     void uart1_write_char(char c);
     void uart0_write_char(char c);

#endif /* _INCLUDE_APP_MAIN_H_ */
