/******************************************************************************
 * Copyright 2013-2014 Espressif Systems (Wuxi)
 *
 * FileName: espconn_mdns.c
 *
 * Description: udp proto interface
 *
 * Modification history:
 *     2014/3/31, v1.0 create this file.
 *******************************************************************************/

#include "lwipopts.h"

#ifdef USE_ESPCONN

#  include "ets_sys.h"
#  include "os_type.h"

#  include "lwip/mdns.h"

/******************************************************************************
 * FunctionName : espconn_mdns_enable
 * Description  : join a multicast group
 * Parameters   : host_ip -- the ip address of udp server
 *          multicast_ip -- multicast ip given by user
 * Returns      : none
 *******************************************************************************/
void
espconn_mdns_enable(void) {
  mdns_enable();
}

/******************************************************************************
 * FunctionName : espconn_mdns_disable
 * Description  : join a multicast group
 * Parameters   : host_ip -- the ip address of udp server
 *          multicast_ip -- multicast ip given by user
 * Returns      : none
 *******************************************************************************/
void
espconn_mdns_disable(void) {
  mdns_disable();
}

/******************************************************************************
 * FunctionName : espconn_mdns_set_hostname
 * Description  : join a multicast group
 * Parameters   : host_ip -- the ip address of udp server
 *          multicast_ip -- multicast ip given by user
 * Returns      : none
 *******************************************************************************/
void
espconn_mdns_set_hostname(char *name) {
  mdns_set_hostname(name);
}

/******************************************************************************
 * FunctionName : espconn_mdns_init
 * Description  : join a multicast group
 * Parameters   : host_ip -- the ip address of udp server
 *          multicast_ip -- multicast ip given by user
 * Returns      : none
 *******************************************************************************/
char *
espconn_mdns_get_hostname(void) {
  return (char *)mdns_get_hostname();
}

/******************************************************************************
 * FunctionName : espconn_mdns_get_servername
 * Description  : join a multicast group
 * Parameters   : info -- the info  of mdns
 * Returns      : none
 *******************************************************************************/
void
espconn_mdns_set_servername(const char *name) {
  mdns_set_servername(name);
}

/******************************************************************************
 * FunctionName : espconn_mdns_get_servername
 * Description  : join a multicast group
 * Parameters   : info -- the info  of mdns
 * Returns      : none
 *******************************************************************************/
char *
espconn_mdns_get_servername(void) {
  return (char *)mdns_get_servername();
}

/******************************************************************************
 * FunctionName : mdns_server_register
 * Description  : join a multicast group
 * Parameters   : info -- the info  of mdns
 * Returns      : none
 *******************************************************************************/
void
espconn_mdns_server_register(void) {
  mdns_server_register();
}

/******************************************************************************
 * FunctionName : mdns_server_register
 * Description  : join a multicast group
 * Parameters   : info -- the info  of mdns
 * Returns      : none
 *******************************************************************************/
void
espconn_mdns_server_unregister(void) {
  mdns_server_unregister();
}

/******************************************************************************
 * FunctionName : espconn_mdns_init
 * Description  : join a multicast group
 * Parameters   : host_ip -- the ip address of udp server
 *          multicast_ip -- multicast ip given by user
 * Returns      : none
 *******************************************************************************/
void
espconn_mdns_close(void) {
  mdns_close();
}

/******************************************************************************
 * FunctionName : espconn_mdns_init
 * Description  : join a multicast group
 * Parameters   : host_ip -- the ip address of udp server
 *          multicast_ip -- multicast ip given by user
 * Returns      : none
 *******************************************************************************/
void
espconn_mdns_init(struct mdns_info *info) {
  mdns_init(info);
}

#endif /* USE_ESPCONN */
