#ifndef VLD
	#include "dbgmem.h"
#endif
#include "Logger.h"

int main ( int argc, char* argv[] )
{
	int res = 0;
	FILE * logfile;
	
	/*dbgmem_debug_heap_init();
	atexit ( dbgmem_debug_heap_fini );*/
	
	logfile = fopen( "testfile.log","w");
	if ( logfile == NULL )
	{
		res=-1; /* file not opened */
	}
	else
	{
		logger_set_target(logfile);
		
		if ( logger_log("test\n") != 5 )
		{
			res=1; /* error : number of character outputted different from what was expected */
		}
	}

	#ifndef VLD
		dbgmem_dump_blocks();
	#endif

	return res;
}
