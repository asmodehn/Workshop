#ifndef VLD
	#include "dbgmem.h"
#endif
#include "Logger.h"

int main ( int argc, char* argv[] )
{
	int res = 0;
	/*dbgmem_debug_heap_init();
	atexit ( dbgmem_debug_heap_fini );*/
	
	logger_clear_prefix();
	logger_append_prefix( "Testing " );
	logger_append_prefix( "Logger : " );
	
	if ( logger_log("testing\n") != strlen("Testing Logger : testing\n") )
	{
		res=1; /* error : number of character outputted different from what was expected */
	}

	logger_clear_prefix();
	
	logger_set_prepend_date();
	logger_unset_prepend_time();

	if ( logger_log("testing\n") != strlen("AAAA/MM/DD testing\n") )
	{
		res=1; /* error : number of character outputted different from what was expected */
	}

	logger_unset_prepend_date();
	logger_set_prepend_time();

	if ( logger_log("testing\n") != strlen("HH:MM:SS testing\n") )
	{
		res=1; /* error : number of character outputted different from what was expected */
	}

	logger_set_prepend_date();
	logger_set_prepend_time();

	if ( logger_log("testing\n") != strlen("AAAA/MM/DD HH:MM:SS testing\n") )
	{
		res=1; /* error : number of character outputted different from what was expected */
	}

	
	logger_append_prefix( "Testing " );
	logger_append_prefix( "Logger : " );

	
	if ( logger_log("testing\n") != strlen("AAAA/MM/DD HH:MM:SS Testing Logger : testing\n" ) )
	{
		res=1; /* error : number of character outputted different from what was expected */
	}

	#ifndef VLD
		dbgmem_dump_blocks();
	#endif

	return res;
}
