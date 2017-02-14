
#ifndef _INCLUDE_ADD_FUNC_H_
#  define _INCLUDE_ADD_FUNC_H_

#  include "user_config.h"
#  include "ets_sys.h"
#  include "mem_manager.h"
#  include "sdk/ets_run_new.h"

struct s_info {
  uint32_t ap_ip;			/* +00 */
  uint32_t ap_mask;		/* +04 */
  uint32_t ap_gw;			/* +08 */
  uint32_t st_ip;			/* +0C */
  uint32_t st_mask;		/* +10 */
  uint32_t st_gw;			/* +14 */
  uint8_t ap_mac[6];		/* +18 */
  uint8_t st_mac[6];		/* +1E */
} __attribute__ ((packed, aligned(4)));

#  if DEF_SDK_VERSION > 999	/* SDK > 0.9.6 b1 */
/* uint32_t system_adc_read(void); // user_interface.h
   void system_deep_sleep(uint32_t time_in_us); // user_interface.h
   bool system_deep_sleep_set_option(uint8_t option); // user_interface.h
   uint32_t system_get_boot_mode(void); // user_interface.h
   uint32_t system_get_boot_version(void); // user_interface.h */
uint32_t system_get_checksum(uint8_t * ptr, uint32_t len);

/* uint32_t system_get_chip_id(void); // user_interface.h
   uint32_t system_get_cpu_freq(void); // user_interface.h // ets_get_cpu_frequency
   uint32_t system_get_free_heap_size(void); // user_interface.h */
/* bool system_get_os_print(void); */ /* return os_print_enable */
/* uint32_t system_get_rtc_time(void); */ /* return (uint32)(*((uint32*)0x6000071C)) */

/* const uint8_t *system_get_sdk_version(void); // user_interface.h */
uint32_t system_get_test_result(void);

/* uint32_t system_get_time(void); // x1 us, return WdevTimOffSet + (uint32)(*((uint32*)0x3FF20C00)) // user_interface.h */
/* uint32_t phy_get_mactime(void); */ /* x1 us, return (uint32)(*((uint32*)0x3FF20C00)) */
/* uint32_t system_get_userbin_addr(void); */

/* uint32_t system_get_vdd33(void); // user_interface.h
   void system_init_done_cb(init_done_cb_t cb); typedef void (* init_done_cb_t)(void); // user_interface.h
   uint64_t system_mktime(uint32_t year, uint32_t mon, uint32_t day, uint32_t hour, uint32_t min, uint32_t sec); // user_interface.h
   bool system_os_post(uint8_t prio, os_signal_t sig, os_param_t par); // user_interface.h
   bool system_os_task(os_task_t task, uint8_t prio, os_event_t *queue, uint8_t qlen); // user_interface.h */
bool system_overclock(void);	/* if(system_get_cpu_freq()==80) { cpu_overclock = 1, system_update_cpu_freq(160) } */

/* ?system_param_error(); */
uint32_t system_phy_temperature_alert(void);	/* phy_get_check_flag(0); */
void system_pp_recycle_rx_pkt(void *eb);	/* ?system_pp_recycle_rx_pkt(); // ppRecycleRxPkt()-> lldesc_num2link() wDev_AppendRxBlocks() esf_buf_recycle() */

/* void system_print_meminfo(void); // user_interface.h */
uint32_t system_relative_time(uint32_t x);	/* (*((uint32*)0x3FF20C00))- x */

/* void system_restart(void); // user_interface.h
   void system_restart_enhance(uint32_t *bin); // system_get_boot_version() "failed: need boot >= 1.3\n" system_get_userbin_addr(), "restart to use user bin", wifi_param_save_protect(), system_restart()
   void system_restore(void); // user_interface.h */
bool system_restoreclock(void);	/* if(cpu_overclock) system_update_cpu_freq(80) else return 0 */

/* uint32_t system_rtc_clock_cali_proc(void); // user_interface.h
   bool system_rtc_mem_read(uint8_t src_addr, void *des_addr, uint16_t load_size); // user_interface.h
   bool system_rtc_mem_write(uint8_t des_addr, const void *src_addr, uint16_t save_size); // user_interface.h
   void system_set_os_print(uint8_t onoff); // user_interface.h
   void system_station_got_ip_set(ip_addr_t * ip_addr, ip_addr_t *sn_mask, ip_addr_t *gw_addr); //?system_station_got_ip_set(a,b,c); // print"ip:%d.%d.%d.%d,mask:%d.%d.%d.%d,gw:%d.%", ets_timer_disarm(sta_con_timer)
   void system_timer_reinit(void); // user_interface.h // устанавливает делитель таймера на :16 вместо :256 и т.д.
   void system_uart_swap(void); // user_interface.h
   bool system_update_cpu_freq(uint32_t cpu_freq); // ets_update_cpu_frequency + bit0 0x3FF00014 // user_interface.h
   uint8_t system_upgrade_flag_check(); // user_interface.h
   void system_upgrade_flag_set(uint8_t flag); // user_interface.h
   void system_upgrade_reboot(void); // user_interface.h
   uint8_t system_upgrade_userbin_check(void); // user_interface.h */
bool system_upgrade_userbin_set(uint32_t flag);	/* system_get_boot_version(), store flags */
#  endif

int atoi(const char *str);

/* int os_printf_plus(const char *format, ...); */
int ets_sprintf(char *str, const char *format, ...);

void wifi_softap_set_default_ssid(void);
void wDev_Set_Beacon_Int(uint32_t);
extern void wDev_ProcessFiq(void);
void ets_timer_arm_new(ETSTimer * ptimer, uint32_t milliseconds,
                       int repeat_flag, int isMstimer);
void sleep_reset_analog_rtcreg_8266(void);
void wifi_softap_cacl_mac(uint8_t * mac_out,
                          uint8_t * mac_in);
int wifi_mode_set(int mode);
int wifi_station_start(void);

#  if DEF_SDK_VERSION >= 1200
int wifi_softap_start(int);
int wifi_softap_stop(int);
#  else
int wifi_softap_start(void);
#  endif
int register_chipv6_phy(uint8_t * esp_init_data);	/* esp_init_data_default[128] */
void ieee80211_phy_init(int phy_mode);	/* ieee80211_setup_ratetable() */
void lmacInit(void);
void wDev_Initialize(uint8_t * mac);
void pp_attach(void);
void ieee80211_ifattach(void *_g_ic);	/* g_ic in main\Include\libmain.h */
void pm_attach(void);
int fpm_attach(void);	/* all return  1 */
void cnx_attach(void *_g_ic);	/* g_ic in main\Include\libmain.h */
void wDevEnableRx(void);	/* io(0x3FF20004) |= 0x80000000; */

/* in mem_manager.h
   void *pvPortMalloc(size_t xWantedSize);
   void *pvPortRealloc(void * rmem, size_t newsize);
   void vPortFree(void *pv);
   size_t xPortGetFreeHeapSize(void);
   void vPortInitialiseBlocks(void);
   void *pvPortZalloc(size_t size);
 */
uint32_t readvdd33(void);
int get_noisefloor_sat(void);
int read_hw_noisefloor(void);
int ram_get_fm_sar_dout(int);

/* noise_init(), rom_get_noisefloor(), ram_set_noise_floor(), noise_check_loop(), ram_start_noisefloor()
   void sys_check_timeouts(void *timer_arg); // lwip */
/* void read_macaddr_from_otp(uint8_t * mac); */

void wifi_station_set_default_hostname(const uint8_t * mac);

void user_init(void);

#  ifdef USE_TIMER0
void timer0_start(uint32_t us, bool repeat_flg);
void timer0_stop(void);

#    ifdef TIMER0_USE_NMI_VECTOR
void timer0_init(void *func, uint32_t par, bool nmi_flg);
#    else
void timer0_init(void *func, void *par);
#    endif
#  endif

/* void wifi_param_save_protect_with_check(uint16_t startsector, int sectorsize, void *pdata, uint16_t len); */
void wifi_param_save_protect_with_check(int startsector, int sectorsize,
                                        void *pdata, int len);

#  if DEF_SDK_VERSION >= 1300
#    define deep_sleep_option ((RTC_RAM_BASE[0x6C>>2] >> 16) & 0xFF)
#  else
#    define deep_sleep_option (RTC_RAM_BASE[0x60>>2] >> 16)
#  endif

extern struct rst_info rst_if;

#endif /* _INCLUDE_ADD_FUNC_H_ */
