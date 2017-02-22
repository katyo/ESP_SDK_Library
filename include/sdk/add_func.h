
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
uint32_t system_get_checksum(uint8_t * ptr, uint32_t len);
uint32_t system_get_test_result(void);
bool system_overclock(void);	/* if(system_get_cpu_freq()==80) { cpu_overclock = 1, system_update_cpu_freq(160) } */

uint32_t system_phy_temperature_alert(void);	/* phy_get_check_flag(0); */
void system_pp_recycle_rx_pkt(void *eb);	/* ?system_pp_recycle_rx_pkt(); // ppRecycleRxPkt()-> lldesc_num2link() wDev_AppendRxBlocks() esf_buf_recycle() */

uint32_t system_relative_time(uint32_t x);	/* (*((uint32*)0x3FF20C00))- x */

bool system_restoreclock(void);	/* if(cpu_overclock) system_update_cpu_freq(80) else return 0 */
bool system_upgrade_userbin_set(uint32_t flag);	/* system_get_boot_version(), store flags */
#  endif

//int atoi(const char *str);

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
