#include "Logger.h"

int main ( int argc, char* argv[] )
{
	/* Log in a file to work even in Release builds */
	/*FILE * logfile = fopen( "testfile.log","w"); */
	FILE * logfile = tmpfile();
	if ( logfile == NULL )
		return -1; /* file not opened */

	logger_set_target(logfile);

	logger_clear_prefix();
	logger_append_prefix( "Testing " );
	logger_append_prefix( "Logger : " );
	
	if ( logger_log("testing\n") != 25 )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	return 0 ; /* everything was fine */
}
