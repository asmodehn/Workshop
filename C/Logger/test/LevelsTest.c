#include "Logger.h"

int main ( int argc, char* argv[] )
{
	/* Log in a file to work even in Release builds */
	FILE * logfile = fopen( "testfile.log","w");
	if ( logfile == NULL )
		return -1; /* file not opened */

	logger_set_target(logfile);
	
	if ( logger_log("test\n") == 5 )
		return 0;
	else
		return 1; /* error : number of character outputted different from what was expected */
	return 0;
}
