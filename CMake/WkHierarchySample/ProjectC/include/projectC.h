#ifndef PROJECTC_H
#define PROJECTC_H

#include "WkPlatform.h"

/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
extern "C" {
#endif

WK_DECLSPEC int C_display(const char* txt);

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif /* PROJECTC */
