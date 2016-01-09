#ifndef SDIO_SLAVE_H
#  define SDIO_SLAVE_H
#  include "hw/slc_register.h"
#  include "c_types.h"

#  include "user_interface.h"
struct sdio_queue {
  uint32_t blocksize:12;
  uint32_t datalen:12;
  uint32_t unused:5;
  uint32_t sub_sof:1;
  uint32_t eof:1;
  uint32_t owner:1;

  uint32_t buf_ptr;
  uint32_t next_link_ptr;
};

struct sdio_slave_status_element {
  uint32_t wr_busy:1;
  uint32_t rd_empty:1;
  uint32_t comm_cnt:3;
  uint32_t intr_no:3;
  uint32_t rx_length:16;
  uint32_t res:8;
};

union sdio_slave_status {
  struct sdio_slave_status_element elm_value;
  uint32_t word_value;
};

#  define RX_AVAILIBLE 2
#  define TX_AVAILIBLE 1
#  define INIT_STAGE   0

#  define SDIO_QUEUE_LEN 8
#  define MOSI  0
#  define MISO  1
#  define SDIO_DATA_ERROR 6

#  define SLC_INTEREST_EVENT (SLC_TX_EOF_INT_ENA | SLC_RX_EOF_INT_ENA | SLC_RX_UDF_INT_ENA | SLC_TX_DSCR_ERR_INT_ENA)
#  define TRIG_TOHOST_INT() SET_PERI_REG_MASK(SLC_INTVEC_TOHOST, BIT0); \
  CLEAR_PERI_REG_MASK(SLC_INTVEC_TOHOST, BIT0)

/*
   void sdio_slave_init(void);
   void sdio_slave_isr(void *para);
   void sdio_task_init(void);
   void sdio_err_task(os_event_t *e);
   void rx_buff_load_done(uint16_t rx_len);
   void tx_buff_handle_done(void);
   void rx_buff_read_done(void);
   void tx_buff_write_done(void);
 */
#endif
