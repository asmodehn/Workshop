#include "Logger.h"

#include <stdlib.h>
#include <time.h>

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

unsigned short logger_prepend_date = 0;
unsigned short logger_prepend_time = 0;

void logger_set_prepend_date(void) { logger_prepend_date = 1; }
void logger_set_prepend_time(void) { logger_prepend_time = 1; }
void logger_unset_prepend_date(void) { logger_prepend_date = 0; }
void logger_unset_prepend_time(void) { logger_prepend_time = 0; }

int logger_write_target_pv(short lvl, const char * fmt, ...)
{
	int nbchar = 0;
	char * dtprefixed = strdup("");
	char * dtformat = strdup("");
	time_t tp;
	va_list argptr;
	va_start( argptr, fmt );
	
	if ( logger_prepend_date ) strncat(dtformat,"%Y/%m/%d ",9);
	if ( logger_prepend_time ) strncat(dtformat,"%H:%M:%S ",9);

	time(&tp);
	strftime( dtprefixed, 32, dtformat, localtime(&tp) );
	strncat( dtprefixed, fmt, strlen(fmt));
	
	/* TODO: if multi-threaded, lock this section.  Don't want multiple threads logging at the same time */
	if ( logger_target != NULL )
	{
		nbchar = vfprintf(logger_target,dtprefixed, argptr);
	}
#ifndef LOGGER_DISABLE_STDOUT_TARGET
	if ( lvl >= logger_filter_lvl_show )
	{
		nbchar = vfprintf(stdout,dtprefixed, argptr);
	}
#endif
	va_end(argptr);
	free(dtformat);
	free(dtprefixed);
	return nbchar;
}


unsigned short logger_filter_lvl = 0;
unsigned short logger_filter_lvl_show = 0;

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
		nbchar = logger_write_target_pv(level, prefmt,argptr);
	}
	va_end(argptr);
	free(prefmt);
	return nbchar;
}

int logger_write_fileline(short level, const char * file, int line, const char * fmt, ...)
{
	int nbchar = 0;
	char * prefmt = strdup("%s:%d:");
	va_list argptr;
	va_start( argptr, fmt );

	if ( level >= logger_filter_lvl )
	{
		/* adding prefix */
		strncat(prefmt, fmt, strlen(fmt));
		nbchar = logger_write_target_pv(level, prefmt, file, line, argptr );
	}
	va_end(argptr);
	free(prefmt);
	return nbchar;
}

short int logger_filter_lvl_out(short min_logged_lvl)
{
	if ( min_logged_lvl <= LOGGER_MAX_LVL) /* min_logged_lvl is only valid if ERRORS can still be outputted */
	{
		logger_filter_lvl = min_logged_lvl;
		if ( logger_filter_lvl_show < logger_filter_lvl ) /* maintain console log less verbose than file log */
		{
			logger_filter_lvl_show = logger_filter_lvl;
		}
	}
	return logger_filter_lvl;
}

short int logger_filter_lvl_show_out(short min_showed_lvl)
{
	if ( min_showed_lvl <= LOGGER_MAX_LVL) /* min_showed_lvl is only valid if ERRORS can still be outputted */
	{
		if ( min_showed_lvl > logger_filter_lvl )  /* maintain console log less verbose than file log */
		{
			logger_filter_lvl_show = min_showed_lvl;
		}
	}
	return logger_filter_lvl_show;
	
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
