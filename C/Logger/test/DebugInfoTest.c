#ifndef VLD
	#include "dbgmem.h"
#endif
#define LOGGER_WITH_DEBUG_INFO
#include "Logger.h"

int main ( int argc, char* argv[] )
{
	int res = 0;
	char prefix[LOGGER_FILELINE_PREFIX_MAXLEN+5] = "";
	
	/*dbgmem_debug_heap_init();
	atexit ( dbgmem_debug_heap_fini );*/

#ifdef _MSC_VER //becoz VS2005 doesn't know have the snprintf function even if it's in the standard :/
		if ( sprintf_s(prefix, sizeof(prefix),"%s:%d:test\n",__FILE__,__LINE__) && logger_log("test\n") != strlen(prefix) )
#else
		if ( snprintf(prefix, sizeof(prefix),"%s:%d:test\n",__FILE__,__LINE__) && logger_log("test\n") != strlen(prefix) )
#endif
	{
		
#ifdef NDEBUG
	/* on release mode, no output will be made to the console. this is the expected behavior */
#else
		res= 1; /* error : number of character outputted different from what was expected */
#endif
	}


	#ifndef VLD
		dbgmem_dump_blocks();
	#endif

	return res;
}
