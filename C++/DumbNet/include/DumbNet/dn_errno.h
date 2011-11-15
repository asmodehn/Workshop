#ifndef DN_ERRNO_H
#define DN_ERRNO_H

#include "DumbNet/dn_common.h"

#include <errno.h>

extern int dn_errno;

///error messages (indexed by errcode)
extern const char* dn_get_errlist(int index);

///size of errlist()
extern int dn_nerr;

///
extern const char* dn_perror();

#endif
