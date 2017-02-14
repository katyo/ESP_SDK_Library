#ifndef GDBSTUB_H
#  define GDBSTUB_H

#  ifdef __cplusplus
extern "C" {
#  endif

#  ifdef DEBUG_GDBSTUB
#    define gdbstub_init() __gdbstub_init()
#  else
#    define gdbstub_init()
#  endif

void __gdbstub_init(void);

#  ifdef __cplusplus
}
#  endif

#endif
