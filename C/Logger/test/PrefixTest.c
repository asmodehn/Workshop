#include "Logger.h"

int main ( int argc, char* argv[] )
{
	logger_clear_prefix();
	logger_append_prefix( "Testing " );
	logger_append_prefix( "Logger : " );
	
	if ( logger_log("testing\n") != strlen("Testing Logger : testing\n") )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	logger_clear_prefix();
	
	logger_set_prepend_date();
	logger_unset_prepend_time();

	if ( logger_log("testing\n") != strlen("AAAA/MM/DD testing\n") )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	logger_unset_prepend_date();
	logger_set_prepend_time();

	if ( logger_log("testing\n") != strlen("HH:MM:SS testing\n") )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	logger_set_prepend_date();
	logger_set_prepend_time();

	if ( logger_log("testing\n") != strlen("AAAA/MM/DD HH:MM:SS testing\n") )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	
	logger_append_prefix( "Testing " );
	logger_append_prefix( "Logger : " );

	
	if ( logger_log("testing\n") != strlen("AAAA/MM/DD HH:MM:SS Testing Logger : testing\n" ) )
	{
		return 1; /* error : number of character outputted different from what was expected */
	}

	
	return 0 ; /* everything was fine */
}
