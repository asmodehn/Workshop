#include "dbgmem.h"
#include "Logger.h"

int main ( int argc, char* argv[] )
{
	int res = 0;
	dbgmem_debug_heap_init();
	atexit ( dbgmem_debug_heap_fini );
	
	/* Log in a file to see difference with console output */
	FILE * logfile = fopen("testfile.log","w");
	if ( logfile == NULL )
	{
		res=-1; /* file not opened */
	}
	else
	{

		logger_set_target(logfile);
	
		logger_filter_lvl_out(LOGGER_LOG_LVL);
		logger_filter_lvl_show_out(LOGGER_WARNING_LVL);

		logger_clear_prefix();
	
		if ( logger_dbglog("test dbglog\n") != 0 ) /* outputs nowhere */
		{
			res=1; /* error : number of character outputted different from what was expected */
		}

		if ( logger_log("test log\n") != strlen("test log\n") ) /* outputs in file only */
		{
			res=1; /* error : number of character outputted different from what was expected */
		}

		if ( logger_warning("test warning\n") != strlen("test warning\n") ) /* outputs in console and file */
		{
			res=1; /* error : number of character outputted different from what was expected */
		}

		logger_filter_lvl_out(LOGGER_MAX_LVL); /*setting max log level */
		if ( logger_error("test error\n") != strlen("test error\n") ) /* always output everywhere */
		{
			res=1; /* error : number of character outputted different from what was expected */
		}
		fclose(logfile);
	}
	
	dbgmem_dump_blocks();
	return res;
}
