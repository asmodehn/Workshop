#ifndef DN_CLIENT_H
#define DN_CLIENT_H

#include "DumbNet/dn_common.h"

//client only
#define DUMB_MAXDATASIZE 100 // max number of bytes we can get at once

extern dn_socket client_connec_init(const char* host);
extern void client_connec_proc(dn_socket sockfd);

#endif
