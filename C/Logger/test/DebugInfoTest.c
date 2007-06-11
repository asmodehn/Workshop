#define LOGGER_WITH_DEBUG_INFO
#include "Logger.h"

int main ( int argc, char* argv[] )
{
#ifdef NDEBUG
	return 0; /* on release mode, no output will be made to the console. this is the expected behavior */
#else
	if ( logger_log("test\n") == strlen("../test/DebugInfoTest.c:9:test\n") )
		return 0;
	else
		return 1; /* error : number of character outputted different from what was expected */
#endif
}
