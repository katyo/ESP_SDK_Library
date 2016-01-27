#ifndef __MEM_H__
#  define __MEM_H__

/* в модуле mem_manager.o */

#define ALLOC_ATTR __attribute__((malloc))
#define FREE_ATTR

void *port_malloc(size_t size) ALLOC_ATTR;
void port_free(void *ptr) FREE_ATTR;
void *port_zalloc(size_t size) ALLOC_ATTR;
void *port_calloc(size_t size, size_t count) ALLOC_ATTR;
void *port_realloc(void *ptr, size_t size) ALLOC_ATTR FREE_ATTR;
//void port_heap_init(void);
#define port_heap_init()
size_t port_size_align(size_t size);
size_t port_malloc_usable_size(void *ptr);

struct mallinfo {
  size_t arena;    /* total space allocated from system */
  size_t ordblks;  /* number of non-inuse chunks */
  size_t smblks;   /* unused -- always zero */
  size_t hblks;    /* number of mmapped regions */
  size_t hblkhd;   /* total space in mmapped regions */
  size_t usmblks;  /* unused -- always zero */
  size_t fsmblks;  /* unused -- always zero */
  size_t uordblks; /* total allocated space */
  size_t fordblks; /* total non-inuse space */
  size_t keepcost; /* top-most, releasable (via malloc_trim) space */
};

struct mallinfo port_mallinfo(void);
size_t port_free_heap(void);

#  define os_malloc   port_malloc
#  define os_free     port_free
#  define os_zalloc   port_zalloc
#  define os_calloc   port_calloc
#  define os_realloc  port_realloc
#  define system_get_free_heap_size port_free_heap

#endif /* __MEM_H__ */
