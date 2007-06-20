#include "dbgmem.h"
#define LOGGER_WITH_DEBUG_INFO
#include "Logger.h"

int main ( int argc, char* argv[] )
{
	int res = 0;
	char prefix[LOGGER_FILELINE_PREFIX_MAXLEN+5] = "";
	
	dbgmem_debug_heap_init();
	atexit ( dbgmem_debug_heap_fini );
	
	if ( snprintf(prefix, sizeof(prefix),"%s:%d:test\n",__FILE__,__LINE__) && logger_log("test\n") != strlen(prefix) )
	{
		
#ifdef NDEBUG
	/* on release mode, no output will be made to the console. this is the expected behavior */
#else
		res= 1; /* error : number of character outputted different from what was expected */
#endif
	}

	dbgmem_dump_blocks();

	return res;
}
