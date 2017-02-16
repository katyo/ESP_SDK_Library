/******************************************************************************
 * FileName: phy_chip_v6_unused.c
 * Description: Alternate SDK (libphy.a)
 * (c) PV` 2015
 *******************************************************************************/
#include "user_config.h"
#include "bios.h"
#include "hw/esp8266.h"
#include "phy/phy.h"

/* (!) закоменитрованы неиспользуемые функции */

/* вызывается из phy_chip_v6.o */
void
chip_v6_set_sense(void) {
  /* ret.n */
}

/*
   voidchip_v6_get_sense(void)
   {
   // ret.n
   }
 */

/* вызывается из phy_chip_v6.o */
int
chip_v6_unset_chanfreq(void) {
  return 0;
}

/*
   intdata_collect(void)
   {
   ???
   }

   voidoperation_test(void)
   {
   ???
   }


   // используется из slop_test()
   voidslop_wdt_feed(void)
   {
   WDT_FEED = WDT_FEED_MAGIC;
   }

   voidslop_test(void)
   {

   os_printf_plus("slop_test\n");
   CLK_PRE_PORT |= 1;
   i2c_writeReg_Mask(106, 2, 8, 4, 0, 0);
   uint32_t x = IOREG(0x3FF20C00);
   RFChannelSel(14);
   int i;
   for(i=0; i<200; i++) {
    slop_wdt_feed();
    IOREG(0x60000738) = operation_test();
    pm_set_sleep_mode(2);
    pm_wakeup_opt(8, 0);
    pm_set_sleep_cycles(170);
    x = IOREG(0x3FF20C00);
    pm_goto_sleep(2);
    pm_wait4wakeup(2);
    pm_wakeup_init(2, 0);
    x = IOREG(0x3FF20C00);
   }
   }

   voidwd_reset_cnt(void)
   {
   uint32_t x = rtc_get_reset_reason();
   if(x == 4)	os_printf("wd_reset %d\n", RTC_RAM_BASE[0xFC>>2]);
   else if(x == 2 || x != 1) {
    RTC_RAM_BASE[0xFC>>2] = 0;
    os_printf("wd_reset %d\n", RTC_RAM_BASE[0xFC>>2]);
   }
   }
 */
