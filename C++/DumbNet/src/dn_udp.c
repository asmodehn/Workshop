#include "DumbNet/dn_udp.c"

dn_socket dn_udp_client_init()
{
    dn_socket sockfd;
    struct addrinfo hints, *servinfo, *p;
    int rv;
    int numbytes;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;
    hints.ai_protocol = 0;

    // loop through all the results and make a socket
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                p->ai_protocol)) == -1) {
            perror("udp_client_init: socket");
            continue;
        }
        break;
    }

    if (p == NULL) {
        fprintf(stderr, "udp_client_init: failed to create socket\n");
        return 2;
    }

    printf("udp_client_init: socket created\n");

    return sockfd;
}


dn_socket dn_udp_server_init(int localport)
{
    dn_socket sockfd;
    struct addrinfo hints, *servinfo, *p;
    int rv;
    int numbytes;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC; /* IPv4 or IPv6 */
    hints.ai_socktype = SOCK_DGRAM; /* datagram */
    hints.ai_protocol = 0; /* Any protocol */
    hints.ai_flags = AI_PASSIVE; /* for wildcard IP address */
    hints.ai_canonname = NULL;
    hints.ai_addr = NULL;
    hints.ai_next = NULL;

    if ((rv = getaddrinfo(NULL, localport, &hints, &servinfo)) != 0) {
        fprintf(stderr, "udp_init: getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and make a socket
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                p->ai_protocol)) == -1) {
            perror("udp__server_init: socket");
            continue;
        }

        if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
            close(sockfd);
            perror("udp_server_init: bind");
            continue;
        }

        break;
    }

    if (p == NULL) {
        fprintf(stderr, "udp_server_init: failed to bind socket\n");
        return 2;
    }

    printf("udp_server_init: socket bound to port %i\n", localhost,localport );

    return sockfd;
}


size_t dn_udp_sendto(dn_socket sock, const void* buf, size_t len )
{
    dn_socket sockfd;
    int numbytes;

    if ((numbytes = send(sockfd, msg, strlen(msg), 0 )) == -1) {
        perror("udp_send: send");
        exit(1);
    }

    printf("udp_send: sent %d bytes\n", numbytes );

    return numbytes;
}



size_t dn_udp_recv(dn_socket sock, void* buf, size_t len )
{
    dn_socket sockfd;
    int numbytes;

    if ((numbytes = recv(sockfd, msg, len, 0 )) == -1) {
        perror("udp_recv: recv");
        exit(1);
    }

    printf("udp_recv: received %d bytes\n", numbytes );

    return numbytes;
}

void dn_udp_fin(dn_socket)
{
    close(sockfd);
    printf("udp_fin: closed socket");
}


size_t dn_udp_sendto(const char* host, int port ,const void* buf, size_t len )
{
    dn_socket sockfd;
    struct addrinfo hints, *servinfo, *p;
    int rv;
    int numbytes;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;

    if ((rv = getaddrinfo(host, port, &hints, &servinfo)) != 0) {
        fprintf(stderr, "udp_sendto: getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and make a socket
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                p->ai_protocol)) == -1) {
            perror("udp_sendto: socket");
            continue;
        }

        break;
    }

    if (p == NULL) {
        fprintf(stderr, "udp_sendto: failed to bind socket\n");
        return 2;
    }

    if ((numbytes = sendto(sockfd, msg, strlen(msg), 0,
             p->ai_addr, p->ai_addrlen)) == -1) {
        perror("udp_sendto: sendto");
        exit(1);
    }

    freeaddrinfo(servinfo);

    printf("udp_sendto: sent %d bytes to %s:%i\n", numbytes, host, port);
    close(sockfd);

    return numbytes;
}

size_t dn_udp_recvfrom(const char* host, int port, void* buf, size_t len )
{
    dn_socket sockfd;
    struct addrinfo hints, *servinfo, *p;
    int rv;
    int numbytes;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;

    if ((rv = getaddrinfo(host, port, &hints, &servinfo)) != 0) {
        fprintf(stderr, "udp_recvfrom: getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and make a socket
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
            perror("udp_recvfrom: socket");
            continue;
        }

        if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
            close(sockfd);
            perror("udp_recvfrom: bind");
            continue;
        }

        break;
    }

    if (p == NULL) {
        fprintf(stderr, "udp_recvfrom: failed to bind socket\n");
        return 2;
    }

    freeaddrinfo(servinfo);

    printf("udp_recvfrom: waiting to recvfrom %s...\n", host);

    addr_len = sizeof their_addr;
    if ((numbytes = recvfrom(sockfd, buf, len , 0,
        (struct sockaddr *)&their_addr, &addr_len)) == -1) {
        perror("recvfrom");
        exit(1);
    }

    printf("udp_recvfrom: got packet from %s\n",
        inet_ntop(their_addr.ss_family,
            get_in_addr((struct sockaddr *)&their_addr),
            s, sizeof s));
    printf("udp_recvfrom: packet is %d bytes long\n", numbytes);
    buf[numbytes] = '\0';
    printf("udp_recvfrom: packet contains \"%s\"\n", buf);

    close(sockfd);

    return numbytes;

}

