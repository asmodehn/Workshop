#include "Logger.h"

int main ( int argc, char* argv[] )
{
	/* Log in a file to work even in Release builds */
	/*FILE * logfile = fopen( "testfile.log","w"); */
	FILE * logfile = tmpfile();
	if ( logfile == NULL )
		return -1; /* file not opened */

	logger_set_target(logfile);
	
	logger_filter_lvl_out(LOGGER_WARNING_LVL);
	
	if ( logger_dbglog("test\n") != 0 )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	if ( logger_log("test\n") != 0 )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	if ( logger_warning("test\n") != 5 )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	if ( logger_error("test\n") != 5 )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	return 0 ; /* everything was fine */
}
