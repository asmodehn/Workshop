
#ifndef DN_SERVER_H
#define DN_SERVER_H

#include "DumbNet/dn_common.h"

//server only
#define BACKLOG 10     // how many pending connections queue will hold

extern void sigchld_handler(int s);




///TCP section
extern dn_socket tcp_init();
extern void tcp_connec_proc ( dn_socket sockfd /*listening socket*/
                            , dn_socket new_fd /*comm socket */
                        );

extern void tcp_connec_send (dn_socket commsock);
extern void tcp_connec_recv (dn_socket commsock);

extern void tcp_connec_accept (dn_socket sockfd /*listening socket*/
                            ,void (*serv_connec_proc) (dn_socket, dn_socket)
                        );

extern void tcp_fin(dn_socket sockfd);




#endif
