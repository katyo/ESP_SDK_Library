#include <stdint.h>

typedef struct {
  uint8_t _reserved0; /* 0x5 */
  uint8_t _reserved1; /* 0x0 */
  int8_t  _reserved2; /* 4 */
  int8_t  _reserved3; /* 2 */
  int8_t  _reserved4; /* 5 */
  int8_t  _reserved5; /* 5 */
  int8_t  _reserved6; /* 5 */
  int8_t  _reserved7; /* 2 */
  int8_t  _reserved8; /* 5 */
  int8_t  _reserved9; /* 0 */
  int8_t  _reserved10; /* 4 */
  int8_t  _reserved11; /* 5 */
  int8_t  _reserved12; /* 5 */
  int8_t  _reserved13; /* 4 */
  int8_t  _reserved14; /* 5 */
  int8_t  _reserved15; /* 5 */
  int8_t  _reserved16; /* 4 */
  int8_t  _reserved17; /* -2 */
  int8_t  _reserved18; /* -3 */
  int8_t  _reserved19; /* -1 */
  int8_t  _reserved20; /* -16 */
  int8_t  _reserved21; /* -16 */
  int8_t  _reserved22; /* -16 */
  int8_t  _reserved23; /* -32 */
  int8_t  _reserved24; /* -32 */
  int8_t  _reserved25; /* -32 */
  union { /* spur_freq = spur_freq_cfg / spur_freq_cfg_div
             by default 22.5 = 225 / 10 */
    uint8_t _reserved26; /* 255 */
    uint8_t rx_param25;
    uint8_t spur_freq_cfg;
  };
  union {
    uint8_t _reserved27; /* 10 */
    uint8_t rx_param26;
    uint8_t spur_freq_cfg_div;
  };
  union { /* spur_freq_en (little-endian)
             each bit for 1 channel, 1 to select the spur_freq if in band, else 40 */
    union {
      uint8_t _reserved28; /* 0 */
      uint8_t rx_param27;
      uint8_t spur_freq_en_h;
    };
    union {
      uint8_t _reserved29; /* 0 */
      uint8_t rx_param28;
      uint8_t spur_freq_en_l;
    };
    uint16_t spur_freq_en;
  };
  int8_t _reserved30; /* 0xf8 */
  int8_t _reserved31; /* 0 */
  int8_t _reserved32; /* 0xf8 */
  int8_t _reserved33; /* 0xf8 */
  union { /* 82 means target power is 82 / 4 = 20.5dbm */
    uint8_t _reserved34; /* 82 */
    uint8_t tx_param5;
    uint8_t target_power_qdb_0;
  };
  union { /* 78 means target power is 78 / 4 = 19.5dbm */
    uint8_t _reserved35; /* 78 */
    uint8_t tx_param6;
    uint8_t target_power_qdb_1;
  };
  union { /* 74 means target power is 74 / 4 = 18.5dbm */
    uint8_t _reserved36; /* 74 */
    uint8_t tx_param7;
    uint8_t target_power_qdb_2;
  };
  union { /* 68 means target power is 68 / 4 = 17dbm */
    uint8_t _reserved37; /* 68 */
    uint8_t tx_param8;
    uint8_t target_power_qdb_3;
  };
  union { /* 64 means target power is 64 / 4 = 16dbm */
    uint8_t _reserved38; /* 64 */
    uint8_t tx_param9;
    uint8_t target_power_qdb_4;
  };
  union { /* 56 means target power is 56 / 4 = 14dbm */
    uint8_t _reserved39; /* 56 */
    uint8_t tx_param10;
    uint8_t target_power_qdb_5;
  };
  union { /* target power index is 0, means target power is target_power_qdb_0 20.5dbm (1m, 2m, 5.5m, 11m, 6m, 9m) */
    uint8_t _reserved40; /* 0 */
    uint8_t tx_param11;
    uint8_t target_power_index_mcs0;
  };
  union { /* target power index is 0, means target power is target_power_qdb_0 20.5dbm (12m) */
    uint8_t _reserved41; /* 0 */
    uint8_t tx_param12;
    uint8_t target_power_index_mcs1;
  };
  union { /* target power index is 1, means target power is target_power_qdb_1 19.5dbm (18m) */
    uint8_t _reserved42; /* 1 */
    uint8_t tx_param13;
    uint8_t target_power_index_mcs2;
  };
  union { /* target power index is 1, means target power is target_power_qdb_1 19.5dbm (24m) */
    uint8_t _reserved43; /* 1 */
    uint8_t tx_param14;
    uint8_t target_power_index_mcs3;
  };
  union { /* target power index is 2, means target power is target_power_qdb_2 18.5dbm (36m) */
    uint8_t _reserved44; /* 2 */
    uint8_t tx_param15;
    uint8_t target_power_index_mcs4;
  };
  union { /* target power index is 3, means target power is target_power_qdb_3 17dbm (48m) */
    uint8_t _reserved45; /* 3 */
    uint8_t tx_param16;
    uint8_t target_power_index_mcs5;
  };
  union { /* target power index is 4, means target power is target_power_qdb_4 16dbm (54m) */
    uint8_t _reserved46; /* 4 */
    uint8_t tx_param17;
    uint8_t target_power_index_mcs6;
  };
  union { /* target power index is 5, means target power is target_power_qdb_5 14dbm */
    uint8_t _reserved47; /* 5 */
    uint8_t tx_param18;
    uint8_t target_power_index_mcs7;
  };
  union { /* 0: 40MHz
             1: 26MHz
             2: 24MHz */
    uint8_t _reserved48; /* 0 */
    uint8_t soc_param0;
    uint8_t crystal_26m_en;
  };
  uint8_t _reserved49; /* 0 */
  union { /* 0: Auto by pin strapping
             1: SDIO dataoutput is at negative edges (SDIO V1.1)
             2: SDIO dataoutput is at positive edges (SDIO V2.0) */
    uint8_t _reserved50; /* 0 */
    uint8_t soc_param2;
    uint8_t sdio_configure;
  };
  union { /* 0: None (no bluetooth)
             1: GPIO0 -> WLAN_ACTIVE/ANT_SEL_WIFI
             MTMS -> BT_ACTIVE
             MTCK  -> BT_PRIORITY
             U0RXD -> ANT_SEL_BT
             2: None, have bluetooth
             3: GPIO0 -> WLAN_ACTIVE/ANT_SEL_WIFI
             MTMS -> BT_PRIORITY
             MTCK  -> BT_ACTIVE
             U0RXD -> ANT_SEL_BT */
    uint8_t _reserved51; /* 0 */
    uint8_t soc_param3;
    uint8_t bt_configure;
  };
  union { /* 0: WiFi-BT are not enabled. Antenna is for WiFi
             1: WiFi-BT are not enabled. Antenna is for BT
             2: WiFi-BT 2-wire are enabled, (only use BT_ACTIVE), independent ant
             3: WiFi-BT 3-wire are enabled, (when BT_ACTIVE = 0, BT_PRIORITY must be 0), independent ant
             4: WiFi-BT 2-wire are enabled, (only use BT_ACTIVE), share ant
             5: WiFi-BT 3-wire are enabled, (when BT_ACTIVE = 0, BT_PRIORITY must be 0), share ant */
    uint8_t _reserved52; /* 0 */
    uint8_t soc_param4;
    uint8_t bt_protocol;
  };
  union { /* 0: None
             1: dual_ant (antenna diversity for WiFi-only): GPIO0 + U0RXD
             2: T/R switch for External PA/LNA:  GPIO0 is high and U0RXD is low during Tx
             3: T/R switch for External PA/LNA:  GPIO0 is low and U0RXD is high during Tx */
    uint8_t _reserved53; /* 0 */
    uint8_t soc_param5;
    uint8_t dual_ant_configure;
  };
  uint8_t _reserved54; /* 2 */
  union { /* This option is to share crystal clock for BT
             The state of Crystal during sleeping
             0: Off
             1: Forcely On
             2: Automatically On according to XPD_DCDC
             3: Automatically On according to GPIO2 */
    uint8_t _reserved55; /* 0 */
    uint8_t soc_param7;
    uint8_t share_xtal;
  };
  uint8_t _reserved56; /* 0 */
  uint8_t _reserved57; /* 0 */
  uint8_t _reserved58; /* 0 */
  uint8_t _reserved59; /* 0 */
  uint8_t _reserved60; /* 0 */
  uint8_t _reserved61; /* 0 */
  uint8_t _reserved62; /* 0 */
  uint8_t _reserved63; /* 0 */
  union { /* spur_freq_2 = spur_freq_cfg_2 / spur_freq_cfg_div_2
             by default 22.5 = 225 / 10 */
    uint8_t _reserved64; /* 225 */
    uint8_t rx_param29;
    uint8_t spur_freq_cfg_2;
  };
  union {
    uint8_t _reserved65; /* 10 */
    uint8_t rx_param30;
    uint8_t spur_freq_cfg_div_2;
  };
  union { /* spur_freq_en_2 (big-endian)
             each bit for 1 channel, and use [spur_freq_en, spur_freq_en_2] to select the spur's priority */
    union {
      uint8_t _reserved66; /* 0 */
      uint8_t rx_param31;
      uint8_t spur_freq_en_h_2;
    };
    union {
      uint8_t _reserved67; /* 0 */
      uint8_t rx_param32;
      uint8_t spur_freq_en_l_2;
    };
    uint16_t spur_freq_en_2;
  };
  union {
    uint8_t _reserved68; /* 0 */
    uint8_t rx_param33;
    uint8_t spur_freq_cfg_msb;
  };
  union {
    uint8_t _reserved69; /* 0 */
    uint8_t rx_param34;
    uint8_t spur_freq_cfg_2_msb;
  };
  union { /* spur_freq_3 (little-endian)
             spur_freq_3 = spur_freq_cfg_3 / 10 + 2400 */
    union { /* spur_freq_3 = ((spur_freq_cfg_3_high << 8) + spur_freq_cfg_3_low) / 10 + 2400 */
      uint8_t _reserved70; /* 0 */
      uint8_t rx_param35;
      uint8_t spur_freq_cfg_3_low;
    };
    union {
      uint8_t _reserved71; /* 0 */
      uint8_t rx_param36;
      uint8_t spur_freq_cfg_3_high;
    };
    uint16_t spur_freq_cfg_3;
  };
  union { /* spur_freq_4 (little-endian)
             spur_freq_4 = spur_freq_cfg_4 / 10 + 2400 */
    union { /* spur_freq_4 = ((spur_freq_cfg_4_high << 8) + spur_freq_cfg_4_low) / 10 + 2400 */
      uint8_t _reserved72; /* 0 */
      uint8_t rx_param37;
      uint8_t spur_freq_cfg_4_low;
    };
    union {
      uint8_t _reserved73; /* 0 */
      uint8_t rx_param38;
      uint8_t spur_freq_cfg_4_high;
    };
    uint16_t spur_freq_cfg_4;
  };
  uint8_t _reserved74; /* 1 */
  uint8_t _reserved75; /* 0x93 */
  uint8_t _reserved76; /* 0x43 */
  uint8_t _reserved77; /* 0x00 */
  uint8_t _reserved78; /* 0 */
  uint8_t _reserved79; /* 0 */
  uint8_t _reserved80; /* 0 */
  uint8_t _reserved81; /* 0 */
  uint8_t _reserved82; /* 0 */
  uint8_t _reserved83; /* 0 */
  uint8_t _reserved84; /* 0 */
  uint8_t _reserved85; /* 0 */
  uint8_t _reserved86; /* 0 */
  uint8_t _reserved87; /* 0 */
  uint8_t _reserved88; /* 0 */
  uint8_t _reserved89; /* 0 */
  uint8_t _reserved90; /* 0 */
  uint8_t _reserved91; /* 0 */
  uint8_t _reserved92; /* 0 */
  union { /* 0: disable low power mode
             1: enable low power mode */
    uint8_t _reserved93; /* 0 */
    uint8_t tx_param24;
    uint8_t low_power_en;
  };
  union { /* the attenuation of RF gain stage 0 and 1,
             0xf: 0db
             0xe: -2.5db
             0xd: -6db
             0x9: -8.5db
             0xc: -11.5db
             0x8: -14db
             0x4: -17.5
             0x0: -23 */
    uint8_t _reserved94; /* 0xf */
    uint8_t tx_param25;
    uint8_t lp_rf_stg10;
  };
  union { /* the attenuation of BB gain from 0 (0db) to 24 (-6db) with step (-0.25db) */
    uint8_t _reserved95; /* 0 */
    uint8_t tx_param26;
    uint8_t lp_bb_att_ext;
  };
  union { /* 0: 11b power is same as mcs0 and 6m
             1: enable 11b power different with ofdm */
    uint8_t _reserved96; /* 0 */
    uint8_t tx_param27;
    uint8_t pwr_ind_11b_en;
  };
  union { /* 1m, 2m power index [0~5] */
    uint8_t _reserved97; /* 0 */
    uint8_t tx_param28;
    uint8_t pwr_ind_11b_0;
  };
  union { /* 5.5m, 11m power index [0~5] */
    uint8_t _reserved98; /* 0 */
    uint8_t tx_param29;
    uint8_t pwr_ind_11b_1;
  };
  uint8_t _reserved99; /* 0 */
  uint8_t _reserved100; /* 0 */
  uint8_t _reserved101; /* 0 */
  uint8_t _reserved102; /* 0 */
  uint8_t _reserved103; /* 0 */
  uint8_t _reserved104; /* 0 */
  uint8_t _reserved105; /* 0 */
  uint8_t _reserved106; /* 0 */
  union { /* the voltage of PA_VDD
             x=0xff: it can measure VDD33,
             18<=x<=36: use input voltage, the value is voltage*10, 33 is 3.3V, 30 is 3.0V,
             x<18 or x>36: default voltage is 3.3V */
    uint8_t _reserved107; /* 0 */
    uint8_t tx_param37;
    uint8_t vdd33_const;
  };
  uint8_t _reserved108; /* 0 */
  uint8_t _reserved109; /* 0 */
  uint8_t _reserved110; /* 0 */
  uint8_t _reserved111; /* 0 */
  union { /* bit[0]:0->do not correct frequency offset , 1->correct frequency offset .
             bit[1]:0->bbpll is 168M, it can correct + and - frequency offset,  1->bbpll is 160M, it only can correct + frequency offset
             bit[2]:0->auto measure frequency offset and correct it, 1->use 113 byte force_freq_offset to correct frequency offset. 
             
             0: do not correct frequency offset.
             1: auto measure frequency offset and correct it,  bbpll is 168M, it can correct + and - frequency offset.
             3: auto measure frequency offset and correct it,  bbpll is 160M, it only can correct + frequency offset.
             5: use 113 byte force_freq_offset to correct frequency offset, bbpll is 168M, it can correct + and - frequency offset.
             7: use 113 byte force_freq_offset to correct frequency offset, bbpll is 160M , it only can correct + frequency offset . */
    uint8_t _reserved112; /* 0 */
    uint8_t tx_param42;
    uint8_t freq_correct_en;
  };
  union { /* signed? unit is 8khz */
    uint8_t _reserved113; /* 0 */
    uint8_t tx_param43;
    uint8_t force_freq_offset;
  };
  uint8_t _reserved114; /* 0 (2 by default) */
  uint8_t _reserved115; /* 0 */
  uint8_t _reserved116; /* 0 */
  uint8_t _reserved117; /* 0 */
  uint8_t _reserved118; /* 0 */
  uint8_t _reserved119; /* 0 */
  uint8_t _reserved120; /* 0 */
  uint8_t _reserved121; /* 0 */
  uint8_t _reserved122; /* 0 */
  uint8_t _reserved123; /* 0 */
  uint8_t _reserved124; /* 0 */
  uint8_t _reserved125; /* 0 */
  uint8_t _reserved126; /* 0 */
  uint8_t _reserved127; /* 0 */
} esp_init_data_t;
