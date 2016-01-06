#include "esp_init_data.h"

const esp_init_data_t esp_init_data_default = {
  /* spur_freq = spur_freq_cfg / spur_freq_cfg_div
     22.5 = 225 / 10 */
  .spur_freq_cfg = 225,
  .spur_freq_cfg_div = 10,

  /* spur_freq_2 = spur_freq_cfg_2 / spur_freq_cfg_div_2
     22.5 = 225 / 10 */
  .spur_freq_cfg_2 = 225,
  .spur_freq_cfg_div_2 = 10,
  
  /* each bit for 1 channel, 1 to select the spur_freq if in band, else 40 */
  .spur_freq_en = 0xffff, /* 0 */
  
  /* each bit for 1 channel, and use [spur_freq_en, spur_freq_en_2] to select the spur's priority */
  .spur_freq_en_2 = 0,
  
  .spur_freq_cfg_msb = 0,
  .spur_freq_cfg_2_msb = 0,
  
  /* spur_freq_X = spur_freq_cfg_X / 10 + 2400 */
  .spur_freq_cfg_3 = 0,
  .spur_freq_cfg_4 = 0,
  
  /* target_power_dbm = target_power_qdb / 4 */
  .target_power_qdb_0 = 82, /* 82 / 4 = 20.5dbm (1m, 2m, 5.5m, 11m, 6m, 9m or 12m) */
  .target_power_qdb_1 = 78, /* 78 / 4 = 19.5dbm (18m or 24m) */
  .target_power_qdb_2 = 74, /* 74 / 4 = 18.5dbm (36m) */
  .target_power_qdb_3 = 68, /* 68 / 4 = 17dbm (48m) */
  .target_power_qdb_4 = 64, /* 64 / 4 = 16dbm (54m) */
  .target_power_qdb_5 = 56, /* 56 / 4 = 14dbm */
  
  /* target power index is X, means target power is target_power_qdb_X */
  .target_power_index_mcs0 = 0,
  .target_power_index_mcs1 = 0,
  .target_power_index_mcs2 = 1,
  .target_power_index_mcs3 = 1,
  .target_power_index_mcs4 = 2,
  .target_power_index_mcs5 = 3,
  .target_power_index_mcs6 = 4,
  .target_power_index_mcs7 = 5,
  
  /* 0: 40MHz
     1: 26MHz
     2: 24MHz */
  .crystal_26m_en = 1, /* 0 */
  
  /* 0: Auto by pin strapping
     1: SDIO dataoutput is at negative edges (SDIO V1.1)
     2: SDIO dataoutput is at positive edges (SDIO V2.0) */
  .sdio_configure = 0,

  /* 0: None (no bluetooth)
     1: GPIO0 -> WLAN_ACTIVE/ANT_SEL_WIFI
     MTMS -> BT_ACTIVE
     MTCK  -> BT_PRIORITY
     U0RXD -> ANT_SEL_BT
     2: None, have bluetooth
     3: GPIO0 -> WLAN_ACTIVE/ANT_SEL_WIFI
     MTMS -> BT_PRIORITY
     MTCK  -> BT_ACTIVE
     U0RXD -> ANT_SEL_BT */
  .bt_configure = 0,

  /* 0: WiFi-BT are not enabled. Antenna is for WiFi
     1: WiFi-BT are not enabled. Antenna is for BT
     2: WiFi-BT 2-wire are enabled, (only use BT_ACTIVE), independent ant
     3: WiFi-BT 3-wire are enabled, (when BT_ACTIVE = 0, BT_PRIORITY must be 0), independent ant
     4: WiFi-BT 2-wire are enabled, (only use BT_ACTIVE), share ant
     5: WiFi-BT 3-wire are enabled, (when BT_ACTIVE = 0, BT_PRIORITY must be 0), share ant */
  .bt_protocol = 0,
  
  /* 0: None
     1: dual_ant (antenna diversity for WiFi-only): GPIO0 + U0RXD
     2: T/R switch for External PA/LNA:  GPIO0 is high and U0RXD is low during Tx
     3: T/R switch for External PA/LNA:  GPIO0 is low and U0RXD is high during Tx */
  .dual_ant_configure = 0,

  /* This option is to share crystal clock for BT
     The state of Crystal during sleeping
     0: Off
     1: Forcely On
     2: Automatically On according to XPD_DCDC
     3: Automatically On according to GPIO2 */
  .share_xtal = 0,

  /* 0: disable low power mode
     1: enable low power mode */
  .low_power_en = 0,

  /* the attenuation of RF gain stage 0 and 1,
     0xf: 0db (default)
     0xe: -2.5db
     0xd: -6db
     0x9: -8.5db
     0xc: -11.5db
     0x8: -14db
     0x4: -17.5db
     0x0: -23db */
  .lp_rf_stg10 = 0x0, /* 0x0 by default */
  
  /* the attenuation of BB gain from 0 (0db) to 24 (-6db) with step (-0.25db) */
  .lp_bb_att_ext = 0,

  /* 0: 11b power is same as mcs0 and 6m
     1: enable 11b power different with ofdm */
  .pwr_ind_11b_en = 0,

  /* 1m, 2m power index [0~5] */
  .pwr_ind_11b_0 = 0,
  
  /* 5.5m, 11m power index [0~5] */
  .pwr_ind_11b_1 = 0,

  /* the voltage of PA_VDD
     x=0xff: it can measure VDD33,
     18<=x<=36: use input voltage, the value is voltage*10, 33 is 3.3V, 30 is 3.0V,
     x<18 or x>36: default voltage is 3.3V */
  .vdd33_const = 0,

  /* bit[0]:0->do not correct frequency offset , 1->correct frequency offset .
     bit[1]:0->bbpll is 168M, it can correct + and - frequency offset,  1->bbpll is 160M, it only can correct + frequency offset
     bit[2]:0->auto measure frequency offset and correct it, 1->use 113 byte force_freq_offset to correct frequency offset. 
     
     0: do not correct frequency offset (by default).
     1: auto measure frequency offset and correct it,  bbpll is 168M, it can correct + and - frequency offset.
     3: auto measure frequency offset and correct it,  bbpll is 160M, it only can correct + frequency offset.
     5: use 113 byte force_freq_offset to correct frequency offset, bbpll is 168M, it can correct + and - frequency offset.
     7: use 113 byte force_freq_offset to correct frequency offset, bbpll is 160M , it only can correct + frequency offset . */
  .freq_correct_en = 3, /* 0 */
  
  /* signed? unit is 8khz */
  .force_freq_offset = 0,
  
  ._reserved0 = 0x5,
  ._reserved1 = 0x0,
  ._reserved2 = 4,
  ._reserved3 = 2,
  
  ._reserved4 = 5,
  ._reserved5 = 5,
  ._reserved6 = 5,
  ._reserved7 = 2,
  ._reserved8 = 5,
  ._reserved9 = 0,
  ._reserved10 = 4,
  ._reserved11 = 5,
  ._reserved12 = 5,
  ._reserved13 = 4,
  ._reserved14 = 5,
  ._reserved15 = 5,
  ._reserved16 = 4,
  ._reserved17 = -2,
  ._reserved18 = -3,
  ._reserved19 = -1,
  
  ._reserved20 = -16,
  ._reserved21 = -16,
  ._reserved22 = -16,
  
  ._reserved23 = -32,
  ._reserved24 = -32,
  ._reserved25 = -32,

  ._reserved30 = 0xf8,
  ._reserved32 = 0xf8,
  ._reserved33 = 0xf8,

  ._reserved54 = 2,
  
  ._reserved74 = 1,
  ._reserved75 = 0x93,
  ._reserved76 = 0x43,

  ._reserved114 = 2, /* 0 */
};
