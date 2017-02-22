#  include <stdlib.h>
#  include <string.h>

#  include "bios.h"
#  include "sdk/sdk_config.h"
#  include "sdk/mem_manager.h"

#ifndef MEM_DEBUG
#define MEM_DEBUG 0
#endif

#if MEM_DEBUG
#include <assert.h>
#else
#define assert(x) ((void)0)
#endif

#ifndef MAX
#define MAX(a,b) ((a) >= (b) ? (a) : (b))
#endif

#define RARG
#define RONEARG
#define RCALL
#define RONECALL
#define MALLOC_LOCK ets_intr_lock()
#define MALLOC_UNLOCK ets_intr_unlock()

#define nano_malloc		port_malloc
#define nano_free		port_free
#define nano_realloc		port_realloc
#define nano_zalloc		port_zalloc
#define nano_calloc		port_calloc

#define nano_malloc_usable_size port_malloc_usable_size
#define nano_mallinfo		port_mallinfo

/* Redefine names to avoid conflict with user names */
#define free_list __malloc_free_list
#define sbrk_start __malloc_sbrk_start
#define current_mallinfo __malloc_current_mallinfo

#define ALIGN_TO(size, align)                   \
  (((size) + (align) -1) & ~((align) -1))

/* Alignment of allocated block */
#define MALLOC_ALIGN (8U)
#define CHUNK_ALIGN (sizeof(void*))
#define MALLOC_PADDING ((MAX(MALLOC_ALIGN, CHUNK_ALIGN)) - CHUNK_ALIGN)

/* as well as the minimal allocation size
 * to hold a free pointer */
#define MALLOC_MINSIZE (sizeof(void *))
#define MALLOC_PAGE_ALIGN (0x1000)
#define MAX_ALLOC_SIZE (0x80000000U)

typedef size_t malloc_size_t;

typedef struct malloc_chunk {
  /*          ------------------
   *   chunk->| size (4 bytes) |
   *          ------------------
   *          | Padding for    |
   *          | alignment      |
   *          | holding neg    |
   *          | offset to size |
   *          ------------------
   * mem_ptr->| point to next  |
   *          | free when freed|
   *          | or data load   |
   *          | when allocated |
   *          ------------------
   */
  /* size of the allocated payload area, including size before
     CHUNK_OFFSET */
  long size;

  /* since here, the memory is either the next free block, or data load */
  struct malloc_chunk * next;
} chunk;

#define CHUNK_OFFSET ((malloc_size_t)(&(((struct malloc_chunk *)0)->next)))

/* size of smallest possible chunk. A memory piece smaller than this size
 * won't be able to create a chunk */
#define MALLOC_MINCHUNK (CHUNK_OFFSET + MALLOC_PADDING + MALLOC_MINSIZE)

/* Forward data declarations */
extern chunk * free_list;
extern char * sbrk_start;
extern struct mallinfo current_mallinfo;

static inline chunk * ICACHE_IRAM_ATTR
get_chunk_from_ptr(void * ptr) {
  chunk * c = (chunk *)((char *)ptr - CHUNK_OFFSET);
  /* Skip the padding area */
  if (c->size < 0) c = (chunk *)((char *)c + c->size);
  return c;
}

extern char _heap_start;
#define _heap_end (*(char*)0x3fffc000)
#define _heap_size ((size_t)((size_t)&_heap_end - (size_t)&_heap_start))

static char * ICACHE_IRAM_ATTR
_sbrk_r(int incr) {
  static char *heap_top = (char*)&_heap_start;
  char *prev_heap_top;
  
  prev_heap_top = heap_top;
  
  if (heap_top + incr > &_heap_end) {
    //os_printf("Heap and stack collision\n");
    return (char*)-1;
  }
  
  heap_top += incr;
  return prev_heap_top;
}

/* List list header of free blocks */
chunk * free_list = NULL;

/* Starting point of memory allocated from system */
char * sbrk_start = NULL;

/** Function sbrk_aligned
 * Algorithm:
 *   Use sbrk() to obtain more memory and ensure it is CHUNK_ALIGN aligned
 *   Optimise for the case that it is already aligned - only ask for extra
 *   padding after we know we need it
 */
static void* ICACHE_IRAM_ATTR
sbrk_aligned(RARG malloc_size_t s) {
  char *p, *align_p;

  if (sbrk_start == NULL) sbrk_start = _sbrk_r(RCALL 0);

  p = _sbrk_r(RCALL s);

  /* sbrk returns -1 if fail to allocate */
  if (p == (void *)-1)
    return p;

  align_p = (char*)ALIGN_TO((unsigned long)p, CHUNK_ALIGN);
  if (align_p != p) {
    /* p is not aligned, ask for a few more bytes so that we have s
     * bytes reserved from align_p. */
    p = _sbrk_r(RCALL align_p - p);
    if (p == (void *)-1)
      return p;
  }
  return align_p;
}

/** Function nano_malloc
 * Algorithm:
 *   Walk through the free list to find the first match. If fails to find
 *   one, call sbrk to allocate a new chunk.
 */
void * ICACHE_IRAM_ATTR
nano_malloc(RARG malloc_size_t s) {
  chunk *p, *r;
  char * ptr, * align_ptr;
  int offset;

  malloc_size_t alloc_size;

  alloc_size = ALIGN_TO(s, CHUNK_ALIGN); /* size of aligned data load */
  alloc_size += MALLOC_PADDING; /* padding */
  alloc_size += CHUNK_OFFSET; /* size of chunk head */
  alloc_size = MAX(alloc_size, MALLOC_MINCHUNK);

  if (alloc_size >= MAX_ALLOC_SIZE || alloc_size < s) {
    //RERRNO = ENOMEM;
    return NULL;
  }

  MALLOC_LOCK;

  p = free_list;
  r = p;

  while (r) {
    int rem = r->size - alloc_size;
    if (rem >= 0) {
      if (rem >= (int)MALLOC_MINCHUNK) {
        /* Find a chunk that much larger than required size, break
         * it into two chunks and return the second one */
        r->size = rem;
        r = (chunk *)((char *)r + rem);
        r->size = alloc_size;
      }
      /* Find a chunk that is exactly the size or slightly bigger
       * than requested size, just return this chunk */
      else if (p == r) {
        /* Now it implies p==r==free_list. Move the free_list
         * to next chunk */
        free_list = r->next;
      } else {
        /* Normal case. Remove it from free_list */
        p->next = r->next;
      }
      break;
    }
    p=r;
    r=r->next;
  }

  /* Failed to find a appropriate chunk. Ask for more memory */
  if (r == NULL) {
    r = sbrk_aligned(RCALL alloc_size);

    /* sbrk returns -1 if fail to allocate */
    if (r == (void *)-1) {
      //RERRNO = ENOMEM;
      MALLOC_UNLOCK;
      return NULL;
    }
    r->size = alloc_size;
  }
  MALLOC_UNLOCK;

  ptr = (char *)r + CHUNK_OFFSET;

  align_ptr = (char *)ALIGN_TO((unsigned long)ptr, MALLOC_ALIGN);
  offset = align_ptr - ptr;

  if (offset) {
    *(int *)((char *)r + offset) = -offset;
  }

  assert(align_ptr + size <= (char *)r + alloc_size);
  return align_ptr;
}

#define MALLOC_CHECK_DOUBLE_FREE

/** Function nano_free
 * Implementation of libc free.
 * Algorithm:
 *  Maintain a global free chunk single link list, headed by global
 *  variable free_list.
 *  When free, insert the to-be-freed chunk into free list. The place to
 *  insert should make sure all chunks are sorted by address from low to
 *  high.  Then merge with neighbor chunks if adjacent.
 */
void ICACHE_IRAM_ATTR
nano_free (RARG void * free_p) {
  chunk * p_to_free;
  chunk * p, * q;

  if (free_p == NULL) return;

  p_to_free = get_chunk_from_ptr(free_p);

  MALLOC_LOCK;
  if (free_list == NULL) {
    /* Set first free list element */
    p_to_free->next = free_list;
    free_list = p_to_free;
    MALLOC_UNLOCK;
    return;
  }

  if (p_to_free < free_list) {
    if ((char *)p_to_free + p_to_free->size == (char *)free_list) {
      /* Chunk to free is just before the first element of
       * free list  */
      p_to_free->size += free_list->size;
      p_to_free->next = free_list->next;
    } else {
      /* Insert before current free_list */
      p_to_free->next = free_list;
    }
    free_list = p_to_free;
    MALLOC_UNLOCK;
    return;
  }

  q = free_list;
  /* Walk through the free list to find the place for insert. */
  do {
    p = q;
    q = q->next;
  } while (q && q <= p_to_free);

  /* Now p <= p_to_free and either q == NULL or q > p_to_free
   * Try to merge with chunks immediately before/after it. */

  if ((char *)p + p->size == (char *)p_to_free) {
    /* Chunk to be freed is adjacent
     * to a free chunk before it */
    p->size += p_to_free->size;
    /* If the merged chunk is also adjacent
     * to the chunk after it, merge again */
    if ((char *)p + p->size == (char *) q)
      {
        p->size += q->size;
        p->next = q->next;
      }
  }
#ifdef MALLOC_CHECK_DOUBLE_FREE
  else if ((char *)p + p->size > (char *)p_to_free) {
    /* Report double free fault */
    //RERRNO = ENOMEM;
    MALLOC_UNLOCK;
    return;
  }
#endif
  else if ((char *)p_to_free + p_to_free->size == (char *) q) {
    /* Chunk to be freed is adjacent
     * to a free chunk after it */
    p_to_free->size += q->size;
    p_to_free->next = q->next;
    p->next = p_to_free;
  } else {
    /* Not adjacent to any chunk. Just insert it. Resulting
     * a fragment. */
    p_to_free->next = q;
    p->next = p_to_free;
  }
  MALLOC_UNLOCK;
}

/* Function nano_calloc
 * Implement calloc simply by calling malloc and set zero */
void * ICACHE_IRAM_ATTR
nano_calloc(RARG malloc_size_t n, malloc_size_t elem) {
  void * mem = nano_malloc(RCALL n * elem);
  if (mem != NULL) memset(mem, 0, n * elem);
  return mem;
}

/* Function nano_zalloc
 * Implement zalloc simply by calling cmalloc with one elem */
void * ICACHE_IRAM_ATTR
nano_zalloc(RARG malloc_size_t n) {
  return nano_calloc(RCALL n, 1);
}

/* Function nano_realloc
 * Implement realloc by malloc + memcpy */
void * ICACHE_IRAM_ATTR
nano_realloc(RARG void * ptr, malloc_size_t size) {
  void * mem;

  if (ptr == NULL) return nano_malloc(RCALL size);

  if (size == 0) {
    nano_free(RCALL ptr);
    return NULL;
  }

  /* TODO: There is chance to shrink the chunk if newly requested
   * size is much small */
  if (nano_malloc_usable_size(RCALL ptr) >= size)
    return ptr;

  mem = nano_malloc(RCALL size);
  if (mem != NULL) {
    memcpy(mem, ptr, size);
    nano_free(RCALL ptr);
  }
  return mem;
}

struct mallinfo current_mallinfo={0,0,0,0,0,0,0,0,0,0};

struct mallinfo ICACHE_IRAM_ATTR
nano_mallinfo(RONEARG) {
  char * sbrk_now;
  chunk * pf;
  size_t free_size = 0;
  size_t total_size;

  MALLOC_LOCK;

  if (sbrk_start == NULL) total_size = 0;
  else {
    sbrk_now = _sbrk_r(RCALL 0);

    if (sbrk_now == (void *)-1)
      total_size = (size_t)-1;
    else
      total_size = (size_t) (sbrk_now - sbrk_start);
  }

  for (pf = free_list; pf; pf = pf->next)
    free_size += pf->size;

  current_mallinfo.arena = total_size;
  current_mallinfo.fordblks = free_size;
  current_mallinfo.uordblks = total_size - free_size;

  MALLOC_UNLOCK;
  return current_mallinfo;
}

size_t ICACHE_IRAM_ATTR
port_free_heap(void) {
  return _heap_size - port_mallinfo().uordblks;
}

malloc_size_t ICACHE_IRAM_ATTR
nano_malloc_usable_size(RARG void * ptr) {
  chunk * c = (chunk *)((char *)ptr - CHUNK_OFFSET);
  int size_or_offset = c->size;

  if (size_or_offset < 0) {
    /* Padding is used. Excluding the padding size */
    c = (chunk *)((char *)c + c->size);
    return c->size - CHUNK_OFFSET + size_or_offset;
  }
  return c->size - CHUNK_OFFSET;
}

size_t ICACHE_IRAM_ATTR
port_size_align(size_t size) {
  size += MALLOC_MINCHUNK;	/* + 0x10 SDK 1.1.2 */
  if ((size & 7) != 0) {
    size &= ~7;
    size += 8;
  }
  return size;
}
