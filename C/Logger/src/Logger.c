#include "Logger.h"

/* This is the implementation of an ISO C90 portable Logger
 * this logger always log to the console, and optionally to files
 * log levels are supported
 *  one can easily append prefix to the logger
 */
 
/* Adds a prefix to every logged message*/
char logger_prefix[LOGGER_PREFIX_MAXLEN] = "";

void logger_append_prefix(const char * prefix )
{
	strncat(logger_prefix, prefix, LOGGER_PREFIX_MAXLEN - 1);
	logger_prefix[LOGGER_PREFIX_MAXLEN-1] = '\0'; /* just to make sure */
}

void logger_clear_prefix(void)
{
	logger_prefix[0] = '\0';
}

short logger_filter_lvl = 0;

int logger_write(short level, const char * fmt, ... )
{
	int nbchar = 0;
	char * prefmt = strdup(logger_prefix);
	va_list argptr;
	va_start( argptr, fmt );

	if ( level >= logger_filter_lvl )
	{
		/* adding prefix */
		strncat(prefmt, fmt, strlen(fmt));
		
		/* TODO: if multi-threaded, lock this section.  Don't want multiple threads logging at the same time */
		if ( logger_target != NULL )
		{
			nbchar = vfprintf(logger_target,prefmt, argptr);
		}
#ifndef DISABLE_STDOUT_TARGET
		nbchar = vfprintf(stdout,prefmt, argptr);
#endif	
	}
	va_end(argptr);
	free(prefmt);
	return nbchar;
}

short int logger_filter_lvl_out(short min_logged_lvl)
{
	logger_filter_lvl = min_logged_lvl;
	return logger_filter_lvl;
}

FILE* logger_target;

/* logger target definition */
short int logger_set_target(FILE* target)
{
	logger_target = target;
	return 1;
}

short int logger_rem_target(void)
{
	logger_target = NULL;
	return 1;
}
