#ifndef LOGGER_H
#define LOGGER_H

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

/* This defines a ISO C90 portable Logger
 * this logger always log to the console, and optionally to files
 * log levels are supported
 *  one can easily append prefix to the logger
 */
 
#ifndef LOGGER_PREFIX_MAXLEN
#define LOGGER_PREFIX_MAXLEN 32
#endif

/* Store the prefix for the logger*/
extern char logger_prefix[LOGGER_PREFIX_MAXLEN];

/* Adds a prefix to every logged message*/
void logger_append_prefix(const char * prefix );
void logger_clear_prefix(void);


/* logger lvl from 0 to 7 */
#define LOGGER_MAX_LVL 8

/* useful defines for simple use */
#define LOGGER_DEBUGLOG_LVL 0
#define LOGGER_LOG_LVL 1
#define LOGGER_WARNING_LVL 6
#define LOGGER_ERROR_LVL 7

#define logger_dbglog( msg ) logger_write( LOGGER_DEBUGLOG_LVL, (msg) )
#define logger_log( msg ) logger_write( LOGGER_LOG_LVL, (msg) )
#define logger_warning( msg ) logger_write( LOGGER_WARNING_LVL, (msg) )
#define logger_error( msg ) logger_write( LOGGER_ERROR_LVL, (msg) )

void logger_write(short level, const char * fmt, ... );

/* to disable console output if not in debug mode */
#ifdef NDEBUG
#define DISABLE_STDOUT_TARGET
#endif

/* defining minimal lvl to actually log */
extern short logger_filter_lvl;

short int logger_filter_lvl_out(short min_logged_lvl);

/* logger target definition */
extern FILE* logger_target;

short int logger_set_target(FILE* target);
short int logger_rem_target();


#endif /* LOGGER_H */
