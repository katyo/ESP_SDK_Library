/*
 * Compatibility for AxTLS with LWIP raw tcp mode (http://lwip.wikia.com/wiki/Raw/TCP)
 *
 *  Created on: Jan 15, 2016
 *      Author: Slavey Karadzhov
 */

#ifndef LWIPR_COMPAT_H
#define LWIPR_COMPAT_H

#include "lwip/opt.h"

/*
 * All those functions will run only if LWIP tcp raw mode is used
 */
#if LWIP_RAW

#ifdef __cplusplus
extern "C" {
#endif

#include "lwip/tcp.h"
#include "ssl/lwipr_platform.h"
#include "ssl/ssl.h"
#include "ssl/tls1.h"

#include "sdk/mem_manager.h"
/* some functions to mutate the way these work */
#define malloc port_malloc
#define realloc port_realloc
#define calloc port_calloc
#define free port_free

#define ERR_AXL_INVALID_SSL -101
#define ERR_AXL_INVALID_TCP -102
#define ERR_AXL_INVALID_CLIENTFD -103
#define ERR_AXL_INVALID_CLIENTFD_DATA -104

#define SOCKET_READ(A, B, C) 	ax_port_read(A, B, C)
#define SOCKET_WRITE(A, B, C) 	ax_port_write(A, B, C)

/*
 * Define the AXL_DEBUG function to add debug functionality
 */
#ifndef AXL_DEBUG
	#define AXL_DEBUG(...)
#endif

/**
 * Define watchdog function to be called during CPU intensive operations.
 */
#ifndef WATCHDOG_FEED
	#define WATCHDOG_FEED()
#endif

typedef struct {
	struct tcp_pcb *tcp;
	struct pbuf *tcp_pbuf;
	int pbuf_offset;
} AxlTcpData;


typedef struct {
  int size;      /* slots used so far */
  int capacity;  /* total available slots */
  AxlTcpData *data;     /* array of TcpData objects */
} AxlTcpDataArray;

/*
 * High Level Functions - these are the ones that should be used directly
 */

void axl_init(int capacity);
int axl_append(struct tcp_pcb *tcp);
int axl_free(struct tcp_pcb *tcp);

#define axl_ssl_write(A, B, C) ssl_write(A, B, C)
int axl_ssl_read(SSL *sslObj, uint8_t **in_data, struct tcp_pcb *tcp, struct pbuf *p);

int ax_get_file(const char *filename, uint8_t **buf);

/*
 * Lower Level Socket Functions - used internally from axTLS
 */

int ax_port_write(int clientfd, uint8_t *buf, uint16_t bytes_needed);
int ax_port_read(int clientfd, uint8_t *buf, int bytes_needed);

/*
 * Lower Level Utility functions
 */
void ax_fd_init(AxlTcpDataArray *vector, int capacity);
int ax_fd_append(AxlTcpDataArray *vector, struct tcp_pcb *tcp);
AxlTcpData* ax_fd_get(AxlTcpDataArray *vector, int index);
int ax_fd_getfd(AxlTcpDataArray *vector, struct tcp_pcb *tcp);
void ax_fd_set(AxlTcpDataArray *vector, int index, struct tcp_pcb *tcp);
void ax_fd_double_capacity_if_full(AxlTcpDataArray *vector);
void ax_fd_free(AxlTcpDataArray *vector);

#ifdef __cplusplus
}
#endif

#endif /* LWIP_RAW */

#endif /* LWIPR_COMPAT_H */
