#ifndef DN_UDP_H
#define DN_UDP_H

#include "DumbNet/dn_common.h"
#include "DumbNet/dn_errno.h"


///TODO : handle flags on send and receive
///TODO : handle options on init

///UDP section

///init
extern dn_socket dn_udp_client_init();
extern dn_socket dn_udp_server_init(const char* localhost, int localport);
///comm
extern size_t dn_udp_sendto(dn_socket sock, const void* buf, size_t len, const char* tohost, int toport );
extern size_t dn_udp_recvfrom(dn_socket sock, const void* buf, size_t len, const char* fromhost, int fromport );
///finalizing
extern void dn_udp_fin(dn_socket);


#endif
