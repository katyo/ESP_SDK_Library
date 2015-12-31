MinEspSDK (meSDK)
=================

Minimalist SDK for ESP8266ex v1.4.1

Forked from [pvvx:MinEspSDKLib](//github.com/pvvx/MinEspSDKLib)

---

Overview
--------

A complete set of WiFi and TCP/UDP ([LwIP](http://savannah.nongnu.org/projects/lwip/) 1.4.0) functions.

There are missing espconn API and SSL support.
This SDK is aimed to optimal operation with sensors,
so it will implement things like quick start after deep-sleep and
possibility of controlling loading process (full start or continue sleep after poll sensors).

In purpose of power-saving, the time from resuming after deep-sleep
to starting of poll sensors will be in range of 30..40 ms.

Currently (by default) after power-on/reset or after deep-sleep
the TCP connection from STATION to SOFTAP typically is established
less than ~540 ms, when no DHCP operation is required.
The most time is wasted by WiFi initialization.
The half duplex speed of TCP is greater than 1 MByte per second.

Components
----------

* From [Espressif SDK](http://bbs.espressif.com/) 1.4.1 used only:
  libpp.a, libwpa.a, libnet80211.a, parts libphy.a, user_interface.o
* LwIP based on [Open source LWIP for ESP_IOT_SDK_V1.4.0](http://bbs.espressif.com/viewtopic.php?f=46&t=1221).

Features
--------

* Supported 48 KBytes IRAM option.
* Supported quick start using [ESP Rapid Loader](../ESP_Rapid_Loader).
* Supported flash size from 512 KB and up to 16 MB.

Memory usage
------------

* Free IRAM: 29 KBytes
* Free Heap: 52 KBytes
* Total Free RAM: 81 KBytes

Flash programming options
-------------------------

* SPI_SPEED: 40MHz or 80MHz.
* SPI_MODE: QIO only.
* FLASH_SIZE: You always can use flash size equal to 512 KB.
  The real size of flash determines automatically when loading of firmware.

Usage
-----

You can use [**esp-open-sdk**](//github.com/pfalcon/esp-open-sdk) for build.

The complete set for building of your project using this SDK library:
**lib/libsdk.a** + [**libmicroc.a**](//github.com/anakod/esp_microc) and *include* directory.
