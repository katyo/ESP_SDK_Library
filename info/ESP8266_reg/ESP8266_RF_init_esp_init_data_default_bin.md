  -----------------------------------------------------------------------------------------------------------------------------
  uint8\_no            uint8\_name          param                                     lab\_value           description
  -------------------- -------------------- -------------------- -------------------- -------------------- --------------------
  0                    Reserved             Reserved             unsigned             0x5                  do not change

  1                    Reserved             Reserved             unsigned             0x0                  do not change

  2                    Reserved             Reserved             signed               4                    do not change

  3                    Reserved             Reserved             signed               2                    do not change

  4                    Reserved             Reserved             signed               5                    do not change

  5                    Reserved             Reserved             signed               5                    do not change

  6                    Reserved             Reserved             signed               5                    do not change

  7                    Reserved             Reserved             signed               2                    do not change

  8                    Reserved             Reserved             signed               5                    do not change

  9                    Reserved             Reserved             signed               0                    do not change

  10                   Reserved             Reserved             signed               4                    do not change

  11                   Reserved             Reserved             signed               5                    do not change

  12                   Reserved             Reserved             signed               5                    do not change

  13                   Reserved             Reserved             signed               4                    do not change

  14                   Reserved             Reserved             signed               5                    do not change

  15                   Reserved             Reserved             signed               5                    do not change

  16                   Reserved             Reserved             signed               4                    do not change

  17                   Reserved             Reserved             signed               -2                   do not change

  18                   Reserved             Reserved             signed               -3                   do not change

  19                   Reserved             Reserved             signed               -1                   do not change

  20                   Reserved             Reserved             signed               -16                  do not change

  21                   Reserved             Reserved             signed               -16                  do not change

  22                   Reserved             Reserved             signed               -16                  do not change

  23                   Reserved             Reserved             signed               -32                  do not change

  24                   Reserved             Reserved             signed               -32                  do not change

  25                   Reserved             Reserved             signed               -32                  do not change

  26                   rx\_param25          spur\_freq\_cfg      unsigned             225                  spur\_freq=spur\_fre
                                                                                                           q\_cfg/spur\_freq\_c
                                                                                                           fg\_div

  27                   rx\_param26          spur\_freq\_cfg\_div unsigned             10                   

  28                   rx\_param27          spur\_freq\_en\_h    unsigned             0                    each bit for 1
                                                                                                           channel, 1 to select
                                                                                                           the spur\_freq if in
                                                                                                           band, else 40

  29                   rx\_param28          spur\_freq\_en\_l    unsigned             0                    

  30                   Reserved             Reserved             signed               0xf8                 do not change

  31                   Reserved             Reserved             signed               0                    do not change

  32                   Reserved             Reserved             signed               0xf8                 do not change

  33                   Reserved             Reserved             signed               0xf8                 do not change

  34                   tx\_param5           target\_power\_qdb\_ unsigned             82                   82 means target
                                            0                                                              power is
                                                                                                           82/4=20.5dbm

  35                   tx\_param6           target\_power\_qdb\_ unsigned             78                   78 means target
                                            1                                                              power is
                                                                                                           78/4=19.5dbm

  36                   tx\_param7           target\_power\_qdb\_ unsigned             74                   74 means target
                                            2                                                              power is
                                                                                                           74/4=18.5dbm

  37                   tx\_param8           target\_power\_qdb\_ unsigned             68                   68 means target
                                            3                                                              power is 68/4=17dbm

  38                   tx\_param9           target\_power\_qdb\_ unsigned             64                   64 means target
                                            4                                                              power is 64/4=16dbm

  39                   tx\_param10          target\_power\_qdb\_ unsigned             56                   56 means target
                                            5                                                              power is 56/4=14dbm

  40                   tx\_param11          target\_power\_index unsigned             0                    target power index
                                            \_mcs0                                                         is 0, means target
                                                                                                           power is
                                                                                                           target\_power\_qdb\_
                                                                                                           0
                                                                                                           20.5dbm;
                                                                                                           (1m,2m,5.5m,11m,6m,9
                                                                                                           m)

  41                   tx\_param12          target\_power\_index unsigned             0                    target power index
                                            \_mcs1                                                         is 0, means target
                                                                                                           power is
                                                                                                           target\_power\_qdb\_
                                                                                                           0
                                                                                                           20.5dbm; (12m)

  42                   tx\_param13          target\_power\_index unsigned             1                    target power index
                                            \_mcs2                                                         is 1, means target
                                                                                                           power is
                                                                                                           target\_power\_qdb\_
                                                                                                           1
                                                                                                           19.5dbm; (18m)

  43                   tx\_param14          target\_power\_index unsigned             1                    target power index
                                            \_mcs3                                                         is 1, means target
                                                                                                           power is
                                                                                                           target\_power\_qdb\_
                                                                                                           1
                                                                                                           19.5dbm; (24m)

  44                   tx\_param15          target\_power\_index unsigned             2                    target power index
                                            \_mcs4                                                         is 2, means target
                                                                                                           power is
                                                                                                           target\_power\_qdb\_
                                                                                                           2
                                                                                                           18.5dbm; (36m)

  45                   tx\_param16          target\_power\_index unsigned             3                    target power index
                                            \_mcs5                                                         is 3, means target
                                                                                                           power is
                                                                                                           target\_power\_qdb\_
                                                                                                           3
                                                                                                           17dbm; (48m)

  46                   tx\_param17          target\_power\_index unsigned             4                    target power index
                                            \_mcs6                                                         is 4, means target
                                                                                                           power is
                                                                                                           target\_power\_qdb\_
                                                                                                           4
                                                                                                           16dbm; (54m)

  47                   tx\_param18          target\_power\_index unsigned             5                    target power index
                                            \_mcs7                                                         is 5, means target
                                                                                                           power is
                                                                                                           target\_power\_qdb\_
                                                                                                           5
                                                                                                           14dbm

  48                   soc\_param0          crystal\_26m\_en     unsigned             0                    0: 40MHz\
                                                                                                           1: 26MHz\
                                                                                                           2: 24MHz

  49                   Reserved             Reserved             unsigned             0                    do not change

  50                   soc\_param2          sdio\_configure      unsigned             0                    0: Auto by pin
                                                                                                           strapping\
                                                                                                           1: SDIO dataoutput
                                                                                                           is at negative edges
                                                                                                           (SDIO V1.1)\
                                                                                                           2: SDIO dataoutput
                                                                                                           is at positive edges
                                                                                                           (SDIO V2.0)

  51                   soc\_param3          bt\_configure        unsigned             0                    0: None,no
                                                                                                           bluetooth\
                                                                                                           1: GPIO0 -&gt;
                                                                                                           WLAN\_ACTIVE/ANT\_SE
                                                                                                           L\_WIFI\
                                                                                                           MTMS -&gt;
                                                                                                           BT\_ACTIVE\
                                                                                                           MTCK -&gt;
                                                                                                           BT\_PRIORITY\
                                                                                                           U0RXD -&gt;
                                                                                                           ANT\_SEL\_BT\
                                                                                                           2: None, have
                                                                                                           bluetooth\
                                                                                                           3: GPIO0 -&gt;
                                                                                                           WLAN\_ACTIVE/ANT\_SE
                                                                                                           L\_WIFI\
                                                                                                           MTMS -&gt;
                                                                                                           BT\_PRIORITY\
                                                                                                           MTCK -&gt;
                                                                                                           BT\_ACTIVE\
                                                                                                           U0RXD -&gt;
                                                                                                           ANT\_SEL\_BT

  52                   soc\_param4          bt\_protocol         unsigned             0                    0: WiFi-BT are not
                                                                                                           enabled. Antenna is
                                                                                                           for WiFi\
                                                                                                           1: WiFi-BT are not
                                                                                                           enabled. Antenna is
                                                                                                           for BT\
                                                                                                           2: WiFi-BT 2-wire
                                                                                                           are enabled, (only
                                                                                                           use BT\_ACTIVE),
                                                                                                           independent ant\
                                                                                                           3: WiFi-BT 3-wire
                                                                                                           are enabled, (when
                                                                                                           BT\_ACTIVE = 0,
                                                                                                           BT\_PRIORITY must be
                                                                                                           0), independent ant\
                                                                                                           4: WiFi-BT 2-wire
                                                                                                           are enabled, (only
                                                                                                           use BT\_ACTIVE),
                                                                                                           share ant\
                                                                                                           5: WiFi-BT 3-wire
                                                                                                           are enabled, (when
                                                                                                           BT\_ACTIVE = 0,
                                                                                                           BT\_PRIORITY must be
                                                                                                           0), share ant

  53                   soc\_param5          dual\_ant\_configure unsigned             0                    0: None\
                                                                                                           1: dual\_ant
                                                                                                           (antenna diversity
                                                                                                           for WiFi-only):
                                                                                                           GPIO0 + U0RXD\
                                                                                                           2: T/R switch for
                                                                                                           External PA/LNA:
                                                                                                           GPIO0 is high and
                                                                                                           U0RXD is low during
                                                                                                           Tx\
                                                                                                           3: T/R switch for
                                                                                                           External PA/LNA:
                                                                                                           GPIO0 is low and
                                                                                                           U0RXD is high during
                                                                                                           Tx

  54                   Reserved             Reserved             unsigned             2                    do not change

  55                   soc\_param7          share\_xtal          unsigned             0                    This option is to
                                                                                                           share crystal clock
                                                                                                           for BT\
                                                                                                           The state of Crystal
                                                                                                           during sleeping\
                                                                                                           0: Off\
                                                                                                           1: Forcely On\
                                                                                                           2: Automatically On
                                                                                                           according to
                                                                                                           XPD\_DCDC\
                                                                                                           3: Automatically On
                                                                                                           according to GPIO2

  56                   Reserved             Reserved             unsigned             0                    do not change

  57                   Reserved             Reserved             unsigned             0                    do not change

  58                   Reserved             Reserved             unsigned             0                    do not change

  59                   Reserved             Reserved             unsigned             0                    

  60                   Reserved             Reserved             unsigned             0                    

  61                   Reserved             Reserved             unsigned             0                    

  62                   Reserved             Reserved             unsigned             0                    

  63                   Reserved             Reserved             unsigned             0                    

  64                   rx\_param29          spur\_freq\_cfg\_2   unsigned             225                  spur\_freq\_2=spur\_
                                                                                                           freq\_cfg\_2/spur\_f
                                                                                                           req\_cfg\_div\_2

  65                   rx\_param30          spur\_freq\_cfg\_div unsigned             10                   
                                            \_2                                                            

  66                   rx\_param31          spur\_freq\_en\_h\_2 unsigned             0                    each bit for 1
                                                                                                           channel, and use
                                                                                                           \[spur\_freq\_en,
                                                                                                           spur\_freq\_en\_2\]
                                                                                                           to select the spur's
                                                                                                           priority

  67                   rx\_param32          spur\_freq\_en\_l\_2 unsigned             0                    \
                                                                                                           

  68                   rx\_param33          spur\_freq\_cfg\_msb unsigned             0                    \
                                                                                                           

  69                   rx\_param34          spur\_freq\_cfg\_2\_ unsigned             0                    \
                                            msb                                                            

  70                   rx\_param35          spur\_freq\_cfg\_3\_ unsigned             0                    spur\_freq\_3=((spur
                                            low                                                            \_freq\_cfg\_3\_high
                                                                                                           &lt;&lt;8)+spur\_fre
                                                                                                           q\_cfg\_3\_low)/10+2
                                                                                                           400

  71                   rx\_param36          spur\_freq\_cfg\_3\_ unsigned             0                    \
                                            high                                                           

  72                   rx\_param37          spur\_freq\_cfg\_4\_ unsigned             0                    spur\_freq\_4=((spur
                                            low                                                            \_freq\_cfg\_4\_high
                                                                                                           &lt;&lt;8)+spur\_fre
                                                                                                           q\_cfg\_4\_low)/10+2
                                                                                                           400

  73                   rx\_param38          spur\_freq\_cfg\_4\_ unsigned             0                    \
                                            high                                                           

  74                   Reserved             Reserved             unsigned             1                    do not change

  75                   Reserved             Reserved             unsigned             0x93                 do not change

  76                   Reserved             Reserved             unsigned             0x43                 do not change

  77                   Reserved             Reserved             unsigned             0x00                 do not change

  78                   Reserved             Reserved             unsigned             0                    do not change

  79                   Reserved             Reserved             unsigned             0                    do not change

  80                   Reserved             Reserved             unsigned             0                    do not change

  81                   Reserved             Reserved             unsigned             0                    do not change

  82                   Reserved             Reserved             unsigned             0                    do not change

  83                   Reserved             Reserved             unsigned             0                    do not change

  84                   Reserved             Reserved             unsigned             0                    do not change

  85                   Reserved             Reserved             unsigned             0                    do not change

  86                   Reserved             Reserved             unsigned             0                    do not change

  87                   Reserved             Reserved             unsigned             0                    do not change

  88                   Reserved             Reserved             unsigned             0                    do not change

  89                   Reserved             Reserved             unsigned             0                    do not change

  90                   Reserved             Reserved             unsigned             0                    do not change

  91                   Reserved             Reserved             unsigned             0                    do not change

  92                   Reserved             Reserved             unsigned             0                    do not change

  93                   tx\_param24          low\_power\_en       unsigned             0                    0: disable low power
                                                                                                           mode\
                                                                                                           1: enable low power
                                                                                                           mode

  94                   tx\_param25          lp\_rf\_stg10        unsigned             0xf                  the attenuation of
                                                                                                           RF gain stage 0 and
                                                                                                           1,\
                                                                                                           0xf: 0db, 0xe:
                                                                                                           -2.5db, 0xd: -6db,
                                                                                                           0x9: -8.5db, 0xc:
                                                                                                           -11.5db, 0x8: -14db,
                                                                                                           0x4: -17.5, 0x0: -23

  95                   tx\_param26          lp\_bb\_att\_ext     unsigned             0                    the attenuation of
                                                                                                           BB gain,\
                                                                                                           0: 0db, 1: -0.25db,
                                                                                                           2: -0.5db, 3:
                                                                                                           -0.75db, 4: -1db, 5:
                                                                                                           -1.25db, 6: -1.5db,
                                                                                                           7: -1.75db, 8: -2db
                                                                                                           …….(max valve is
                                                                                                           24(-6db))

  96                   tx\_param27          pwr\_ind\_11b\_en    unsigned             0                    0: 11b power is same
                                                                                                           as mcs0 and 6m\
                                                                                                           1: enable 11b power
                                                                                                           different with ofdm

  97                   tx\_param28          pwr\_ind\_11b\_0     unsigned             0                    1m, 2m power index
                                                                                                           \[0\~5\]

  98                   tx\_param29          pwr\_ind\_11b\_1     unsigned             0                    5.5m, 11m power
                                                                                                           index \[0\~5\]

  99                   Reserved             Reserved             unsigned             0                    do not change

  100                  Reserved             Reserved             unsigned             0                    do not change

  101                  Reserved             Reserved             unsigned             0                    do not change

  102                  Reserved             Reserved             unsigned             0                    do not change

  103                  Reserved             Reserved             unsigned             0                    do not change

  104                  Reserved             Reserved             unsigned             0                    do not change

  105                  Reserved             Reserved             unsigned             0                    do not change

  106                  Reserved             Reserved             unsigned             0                    do not change

  107                  tx\_param37          vdd33\_const         unsigned             0                    the voltage of
                                                                                                           PA\_VDD\
                                                                                                           x=0xff: it can
                                                                                                           measure VDD33,\
                                                                                                           18&lt;=x&lt;=36: use
                                                                                                           input voltage, the
                                                                                                           value is
                                                                                                           voltage\*10, 33 is
                                                                                                           3.3V, 30 is 3.0V,\
                                                                                                           x&lt;18 or x&gt;36:
                                                                                                           default voltage is
                                                                                                           3.3V

  108                  Reserved             Reserved             unsigned             0                    do not change

  109                  Reserved             Reserved             unsigned             0                    do not change

  110                  Reserved             Reserved             unsigned             0                    do not change

  111                  Reserved             Reserved             unsigned             0                    do not change

  112                  tx\_param42          freq\_correct\_en    unsigned             0                    bit\[0\]:0-&gt;do
                                                                                                           not correct
                                                                                                           frequency offset ,
                                                                                                           1-&gt;correct
                                                                                                           frequency offset .\
                                                                                                           bit\[1\]:0-&gt;bbpll
                                                                                                           is 168M, it can
                                                                                                           correct + and -
                                                                                                           frequency offset,
                                                                                                           1-&gt;bbpll is 160M,
                                                                                                           it only can correct
                                                                                                           + frequency offset\
                                                                                                           bit\[2\]:0-&gt;auto
                                                                                                           measure frequency
                                                                                                           offset and correct
                                                                                                           it, 1-&gt;use 113
                                                                                                           byte
                                                                                                           force\_freq\_offset
                                                                                                           to correct frequency
                                                                                                           offset.\
                                                                                                           0: do not correct
                                                                                                           frequency offset.\
                                                                                                           1: auto measure
                                                                                                           frequency offset and
                                                                                                           correct it, bbpll is
                                                                                                           168M, it can correct
                                                                                                           + and - frequency
                                                                                                           offset.\
                                                                                                           3: auto measure
                                                                                                           frequency offset and
                                                                                                           correct it, bbpll is
                                                                                                           160M, it only can
                                                                                                           correct + frequency
                                                                                                           offset.\
                                                                                                           5: use 113 byte
                                                                                                           force\_freq\_offset
                                                                                                           to correct frequency
                                                                                                           offset, bbpll is
                                                                                                           168M, it can correct
                                                                                                           + and - frequency
                                                                                                           offset.\
                                                                                                           7: use 113 byte
                                                                                                           force\_freq\_offset
                                                                                                           to correct frequency
                                                                                                           offset, bbpll is
                                                                                                           160M , it only can
                                                                                                           correct + frequency
                                                                                                           offset .

  113                  tx\_param43          force\_freq\_offset  unsigned             0                    signed, unit is 8khz

  114                  Reserved             Reserved             unsigned             0                    do not change

  115                  Reserved             Reserved             unsigned             0                    do not change

  116                  Reserved             Reserved             unsigned             0                    do not change

  117                  Reserved             Reserved             unsigned             0                    do not change

  118                  Reserved             Reserved             unsigned             0                    do not change

  119                  Reserved             Reserved             unsigned             0                    do not change

  120                  Reserved             Reserved             unsigned             0                    do not change

  121                  Reserved             Reserved             unsigned             0                    do not change

  122                  Reserved             Reserved             unsigned             0                    do not change

  123                  Reserved             Reserved             unsigned             0                    do not change

  124                  Reserved             Reserved             unsigned             0                    do not change

  125                  Reserved             Reserved             unsigned             0                    do not change

  126                  Reserved             Reserved             unsigned             0                    do not change

  127                  Reserved             Reserved             unsigned             0                    do not change
  -----------------------------------------------------------------------------------------------------------------------------


