#include "Logger.h"

int main ( int argc, char* argv[] )
{
	/*FILE * logfile = fopen( "testfile.log","w"); */
	FILE * logfile = tmpfile();
	if ( logfile == NULL )
		return -1; /* file not opened */

	logger_set_target(logfile);
	
	if ( logger_log("test\n") == 5 )
		return 0;
	else
		return 1; /* error : number of character outputted different from what was expected */
}
