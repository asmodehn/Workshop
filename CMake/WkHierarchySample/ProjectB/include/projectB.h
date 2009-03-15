#ifndef PROJECTB_H
#define PROJECTB_H

/*We are depending on projectC*/
#include "projectC.h"

/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
extern "C" {
#endif

int B_display(const char* txt);

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif // PROJECTB
