#ifndef HEADER_H
#define HEADER_H

#include "WkPlatform.hh"

/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
extern "C" {
#endif

WK_DECLSPEC int C_display(const char* txt);

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif
