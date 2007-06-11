#include "Logger.h"

int main ( int argc, char* argv[] )
{
	/* Log in a file to work even in Release builds */
	/*FILE * logfile = fopen( "testfile.log","w"); */
	FILE * logfile = tmpfile();
	if ( logfile == NULL )
		return -1; /* file not opened */

	logger_set_target(logfile);
	
	logger_filter_lvl_out(LOGGER_LOG_LVL);
	logger_filter_lvl_show_out(LOGGER_WARNING_LVL);
	
	if ( logger_dbglog("test dbglog\n") != 0 ) /* outputs nowhere */
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	if ( logger_log("test log\n") != 9 ) /* outputs in file only */
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	if ( logger_warning("test warning\n") != 13 ) /* outputs in console and file */
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	logger_filter_lvl_out(42); /*setting wrong log level */
	if ( logger_error("test error\n") != 11 ) /* always output everywhere */
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	return 0 ; /* everything was fine */
}
