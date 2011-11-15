#ifndef DN_COMMON_H
#define DN_COMMON_H

//#define _CXX0X_WARNING_H

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>

#define DUMB_PORT "2611"  // the port that users can use by default (IANA unassigned)

//defining the dn_socket type
typedef int dn_socket;

// get sockaddr, IPv4 or IPv6:
extern void *get_in_addr(struct sockaddr *sa);


#endif
