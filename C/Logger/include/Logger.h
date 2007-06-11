#ifndef LOGGER_H
#define LOGGER_H

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
extern "C" {
#endif

	
/* This defines a ISO C90 portable Logger
 * this logger always log to the console, and optionally to files
 * log levels are supported
 * one can easily append prefix to the logger
 * Usable defines :
 * LOGGER_WITH_DEBUG_INFO : adds source filename and line number to log output when using macros
 * LOGGER_DISABLE_STDOUT_TARGET : completely disable std output.
 * LOGGER_PREFIX_MAXLEN : the maximum length of the prefix.
 */
 
#ifndef LOGGER_PREFIX_MAXLEN
#define LOGGER_PREFIX_MAXLEN 32
#endif

/* Store the prefix for the logger*/
extern char logger_prefix[LOGGER_PREFIX_MAXLEN];

/* Adds a prefix to every logged message*/
void logger_append_prefix(const char * prefix );
void logger_clear_prefix(void);

/* logger lvl from 0 to 7
 * This is likely to be enough for any purpose
 * LOGGER_MAX_LVL leveled messages cannot be filtered
 */
#define LOGGER_MAX_LVL 7

/* useful defines for simple use */
#define LOGGER_DEBUGLOG_LVL 0
#define LOGGER_LOG_LVL 1
#define LOGGER_WARNING_LVL 6
#define LOGGER_ERROR_LVL 7

/* These are booleans flags : value 0 or 1 */
extern unsigned short logger_prepend_date;
extern unsigned short logger_prepend_time;

void logger_set_prepend_date(void);
void logger_set_prepend_time(void);
void logger_unset_prepend_date(void);
void logger_unset_prepend_time(void);

#ifdef LOGGER_WITH_DEBUG_INFO
	#define logger_dbglog( msg ) logger_write_fileline( LOGGER_DEBUGLOG_LVL, __FILE__, __LINE__ , (msg) )
	#define logger_log( msg ) logger_write_fileline( LOGGER_LOG_LVL, __FILE__, __LINE__ , (msg) )
	#define logger_warning( msg ) logger_write_fileline( LOGGER_WARNING_LVL, __FILE__, __LINE__ , (msg) )
	#define logger_error( msg ) logger_write_fileline( LOGGER_ERROR_LVL, __FILE__, __LINE__ , (msg) )
#else
	#define logger_dbglog( msg ) logger_write( LOGGER_DEBUGLOG_LVL, (msg) )
	#define logger_log( msg ) logger_write( LOGGER_LOG_LVL, (msg) )
	#define logger_warning( msg ) logger_write( LOGGER_WARNING_LVL, (msg) )
	#define logger_error( msg ) logger_write( LOGGER_ERROR_LVL, (msg) )
#endif
/* returns the number of character outputted (including prefix)
 * if no output should occurs ( because of filtering, 0 is returned
 * if console output is made ( stdout target not disabled and loglevel not filtered out )
 * then the number of character in other targets ( file ) is forgotten.
 * Otherwise the number of character outputted  to previous target is returned
 */
int logger_write(short level, const char * fmt, ... );
int logger_write_fileline(short level, const char * file, int line, const char * fmt, ...);
		
/* defining minimal lvl to actually log */
extern unsigned short logger_filter_lvl;
/* defining minimal lvl to log to the console. should be > logger_filter_lvl */
extern unsigned short logger_filter_lvl_show;

short int logger_filter_lvl_out(short min_logged_lvl);
short int logger_filter_lvl_show_out(short min_showed_lvl);

/* logger target definition */
extern FILE* logger_target;

short int logger_set_target(FILE* target);
short int logger_rem_target();

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif /* LOGGER_H */
