#ifndef LOGGER_INTERNAL_LINKAGE
/* if internal linkage, the header file is already present just before this one */
#include "Logger.h"
#endif

#include <stdlib.h>
#include <time.h>

/* This is the implementation of an ISO C90 portable Logger
 * this logger always log to the console, and optionally to files
 * log levels are supported
 *  one can easily append prefix to the logger
 */
 
/* Adds a prefix to every logged message*/
static char logger_prefix[LOGGER_CUSTOM_PREFIX_MAXLEN] = "";

LOGGER_FUNCTION_LINKAGE_TYPE void logger_append_prefix(const char * prefix )
{
	strncat(logger_prefix, prefix, sizeof(logger_prefix) - strlen(logger_prefix) - 1);
}

LOGGER_FUNCTION_LINKAGE_TYPE void logger_clear_prefix(void)
{
	logger_prefix[0] = '\0';
}

static unsigned short logger_prepend_date = 0;
static unsigned short logger_prepend_time = 0;

LOGGER_FUNCTION_LINKAGE_TYPE void logger_set_prepend_date(void) { logger_prepend_date = 1; }
LOGGER_FUNCTION_LINKAGE_TYPE void logger_set_prepend_time(void) { logger_prepend_time = 1; }
LOGGER_FUNCTION_LINKAGE_TYPE void logger_unset_prepend_date(void) { logger_prepend_date = 0; }
LOGGER_FUNCTION_LINKAGE_TYPE void logger_unset_prepend_time(void) { logger_prepend_time = 0; }

static unsigned short logger_filter_lvl = 0;
static unsigned short logger_filter_lvl_show = 0;

static FILE* logger_target;

static int logger_write_target_pv(short lvl, const char * fmt, va_list argptr )
{
	int nbchar = 0;
	char dtprefixed_msg[21 + LOGGER_MSG_MAXLEN] = "";
	char dtformat[19] = "";
	time_t tp;
	
	if ( logger_prepend_date ) strncat(dtformat,"%Y/%m/%d ",sizeof(dtformat) - strlen(dtformat) -1);
	if ( logger_prepend_time ) strncat(dtformat,"%H:%M:%S ",sizeof(dtformat) - strlen(dtformat) -1);

	time(&tp);
	strftime( dtprefixed_msg, sizeof(dtprefixed_msg), dtformat, localtime(&tp) );
	strncat( dtprefixed_msg, fmt, sizeof(dtprefixed_msg) - strlen(dtprefixed_msg) -1);
	
	/* TODO: if multi-threaded, lock this section.  Don't want multiple threads logging at the same time */
	if ( logger_target != NULL )
	{
		nbchar = vfprintf(logger_target,dtprefixed_msg, argptr);
	}
#ifndef LOGGER_DISABLE_STDOUT_TARGET
	if ( lvl >= logger_filter_lvl_show )
	{
		nbchar = vfprintf(stdout,dtprefixed_msg, argptr);
	}
#endif
	return nbchar;
}

LOGGER_FUNCTION_LINKAGE_TYPE int logger_write(short level, const char * fmt, ... )
{
	int nbchar = 0;
	char msg[LOGGER_MSG_MAXLEN] = "";
	va_list argptr;
	va_start( argptr, fmt );

	if ( level >= logger_filter_lvl )
	{
		/* adding predefined message's prefix */
		strncat(msg, logger_prefix, sizeof(msg) - strlen(msg) - 1);
		strncat(msg, fmt, sizeof(msg) - strlen(msg) - 1);
		nbchar = logger_write_target_pv(level, msg,argptr);
	}
	va_end(argptr);
	return nbchar;
}

LOGGER_FUNCTION_LINKAGE_TYPE int logger_write_fileline(short level, const char * file, int line, const char * fmt, ...)
{
	int nbchar = 0;
	va_list argptr;
	char filelinebuf [LOGGER_FILELINE_PREFIX_MAXLEN] = "";
	char msg[LOGGER_MSG_MAXLEN] = "";
	va_start( argptr, fmt );
	

	if ( level >= logger_filter_lvl )
	{
		/* adding predefined message's prefix */
		strncat(msg, logger_prefix, sizeof(msg) - strlen(msg) - 1);

#ifdef _MSC_VER //becoz VS2005 doesn't know have the snprintf function even if it's in the standard :/
		sprintf_s(filelinebuf,sizeof(filelinebuf),"%s:%d:", file, line);
#else
		snprintf(filelinebuf,sizeof(filelinebuf),"%s:%d:", file, line);
#endif
		
		strncat(msg, filelinebuf, sizeof(msg) - strlen(msg) -1);
		strncat(msg, fmt, sizeof(msg) - strlen(msg) -1);
		nbchar = logger_write_target_pv(level, msg, argptr );
	}
	va_end(argptr);
	return nbchar;
}

LOGGER_FUNCTION_LINKAGE_TYPE short int logger_filter_lvl_out(short min_logged_lvl)
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

LOGGER_FUNCTION_LINKAGE_TYPE short int logger_filter_lvl_show_out(short min_showed_lvl)
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

/* logger target definition */
LOGGER_FUNCTION_LINKAGE_TYPE short int logger_set_target(FILE* target)
{
	logger_target = target;
	return 1;
}

LOGGER_FUNCTION_LINKAGE_TYPE short int logger_rem_target(void)
{
	logger_target = NULL;
	return 1;
}
