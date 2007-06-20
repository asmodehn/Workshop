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
 * LOGGER_MSG_MAXLEN : the maximum length of the message that can be logged.
 * LOGGER_CUSTOM_PREFIX_MAXLEN : the maximum length of the custom prefix prepended
 * LOGGER_FILELINE_PREFIX_MAXLEN : the maximum length of the "file:line:" prepended
 */
 
#ifndef LOGGER_MSG_MAXLEN
#define LOGGER_MSG_MAXLEN 4096
#endif

#ifndef LOGGER_CUSTOM_PREFIX_MAXLEN
#define LOGGER_CUSTOM_PREFIX_MAXLEN 512
#endif

	
#ifndef LOGGER_FILELINE_PREFIX_MAXLEN
#define LOGGER_FILELINE_PREFIX_MAXLEN 512
#endif

#ifdef LOGGER_INTERNAL_LINKAGE
/*If internal linkage, the source file Logger.c must also be included in the file already including Logger.h */
#define LOGGER_FUNCTION_LINKAGE_TYPE static
#else /* the default */
#define LOGGER_FUNCTION_LINKAGE_TYPE extern	
#endif
	
/* Adds a prefix to every logged message*/
LOGGER_FUNCTION_LINKAGE_TYPE void logger_append_prefix(const char * prefix );
LOGGER_FUNCTION_LINKAGE_TYPE void logger_clear_prefix(void);

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

LOGGER_FUNCTION_LINKAGE_TYPE void logger_set_prepend_date(void);
LOGGER_FUNCTION_LINKAGE_TYPE void logger_set_prepend_time(void);
LOGGER_FUNCTION_LINKAGE_TYPE void logger_unset_prepend_date(void);
LOGGER_FUNCTION_LINKAGE_TYPE void logger_unset_prepend_time(void);

/* TODO : Look for detection of C99 standard to use _VA_ARGS_ in macros */
/* in C90 use () with arguments when calling the macro */
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
LOGGER_FUNCTION_LINKAGE_TYPE int logger_write(short level, const char * fmt, ... );
LOGGER_FUNCTION_LINKAGE_TYPE int logger_write_fileline(short level, const char * file, int line, const char * fmt, ...);
		
LOGGER_FUNCTION_LINKAGE_TYPE short int logger_filter_lvl_out(short min_logged_lvl);
LOGGER_FUNCTION_LINKAGE_TYPE short int logger_filter_lvl_show_out(short min_showed_lvl);

LOGGER_FUNCTION_LINKAGE_TYPE short int logger_set_target(FILE* target);
LOGGER_FUNCTION_LINKAGE_TYPE short int logger_rem_target();

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif /* LOGGER_H */
