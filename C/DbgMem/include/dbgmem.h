#ifndef DBGMEM_H
#define DBGMEM_H

#include <stdlib.h>
#include <string.h> /* for strdup only is it really standard ? not in cppreference.com - AV */

/* Redefines memory operator if NDEBUG not defined, so it works a bit like assert */
#ifndef NDEBUG
#define DEBUG_MEMORY
#endif

/* define DEBUG_MEMORY for the Memory Debugger to actually check memory operations */
#ifdef DEBUG_MEMORY

#define calloc(n,s) dbgmem_calloc (n,s, __FILE__, __LINE__);
#define malloc(s) dbgmem_malloc (s, __FILE__, __LINE__);
#define realloc(p,s) dbgmem_realloc (p, s, __FILE__, __LINE__);
#define free(p) dbgmem_free(p, __FILE__, __LINE__);
#ifdef strdup
#	undef strdup
#	define strdup(s) dbgmem_strdup(p, __FILE__, __LINE__);
#endif

#endif

/* Declarations */

extern int no_dbgmem; /* set to one to dynamically cancel memory operator redefinition. 0 is the default */

void * dbgmem_calloc( size_t num, size_t size , const char* filename, int line);
void * dbgmem_malloc( size_t size, const char* filename, int line);
void * dbgmem_realloc( void *ptr, size_t size, const char* filename, int line);
void   dbgmem_free( void *ptr, const char* filename, int line);

#ifdef strdup
char * dbgmem_strdup( const char* str, const char* filename, int line );
#endif

void dbgmem_debug_heap_init(void);
void dbgmem_debug_heap_fini(void);
int dbgmem_dump_blocks();

#endif /* DBGMEM_H*/
