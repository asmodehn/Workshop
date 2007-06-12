#include "dbgmem.h"
#include "Logger.h"

int main ( int argc, char* argv[] )
{
	int res = 0;
	
	dbgmem_debug_heap_init();
	atexit ( dbgmem_debug_heap_fini );
	
	FILE * logfile = fopen( "testfile.log","w");
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

	dbgmem_dump_blocks();

	return res;
}
