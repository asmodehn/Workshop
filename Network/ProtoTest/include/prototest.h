#ifndef PROTOTEST_HH
#define PROTOTEST_HH


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>


void sigchld_handler(int s)
{
    while (waitpid(-1, NULL, WNOHANG) > 0);
}

/* get sockaddr, IPv4 or IPv6: */
void *get_in_addr(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET)
    {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }

    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

/*Encapsulate the call to getaddrinfo
returns a linked list to addrinfos containing the machine NIC information in servinfo.
*/
int setup_addrinfo( struct addrinfo ** servinfo, const char * node, const char * service, int ai_flags, int ai_family, int ai_socktype)
{
    struct addrinfo hints;
    struct addrinfo *p;
    int rv;
    char ipstr[INET6_ADDRSTRLEN];


    memset(&hints, 0, sizeof hints);
    hints.ai_flags = ai_flags;
    hints.ai_family = ai_family;
    hints.ai_socktype = ai_socktype;

    if ((rv = getaddrinfo(node, service, &hints, servinfo)) != 0)
    {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return 0; //returning null pointer as a error code
    }

#ifdef _DEBUG
    printf("IP addresses for %s:\n\n", node);

    for (p = *servinfo;p != NULL; p = p->ai_next)
    {
        void *addr;
        char *ipver;

        // get the pointer to the address itself,
        // different fields in IPv4 and IPv6:
        if (p->ai_family == AF_INET)   // IPv4
        {
            struct sockaddr_in *ipv4 = (struct sockaddr_in *)p->ai_addr;
            addr = &(ipv4->sin_addr);
            ipver = "IPv4";
        }
        else   // IPv6
        {
            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)p->ai_addr;
            addr = &(ipv6->sin6_addr);
            ipver = "IPv6";
        }

        // convert the IP to a string and print it:
        inet_ntop(p->ai_family, addr, ipstr, sizeof ipstr);
        printf("  %s: %s\n", ipver, ipstr);
    }
#endif

    return 0;

}

int create_socket(int ai_family, int ai_socktype, int ai_protocol)
{
    int sockfd;//listening socket
    int yes=1;
    //char yes='1'; // Solaris people use this

    if ((sockfd = socket(ai_family, ai_socktype,
                         ai_protocol)) == -1)
    {
        perror("server: socket");
    }

    // lose the pesky "Address already in use" error message
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
                   sizeof(int)) == -1)
    {
        perror("setsockopt");
    }
    return sockfd ;
}

/*
bind and listen on the socket previously setup.
beware : p should remain valid until the close happens
*/
int socket_listen(int sockfd, struct sockaddr* ai_addr, int ai_addrlen, int backlog)
{
    struct sigaction sa;

    if (bind(sockfd, ai_addr, ai_addrlen) == -1)
    {
        close(sockfd);
        perror("server: bind");
    }

    if (listen(sockfd, backlog) == -1)
    {
        perror("listen");
        exit(1);
    }

    sa.sa_handler = sigchld_handler; // reap all dead processes
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART;
    if (sigaction(SIGCHLD, &sa, NULL) == -1)
    {
        perror("sigaction");
        exit(1);
    }

    printf("server: waiting for connections...\n");

    return 0;
}


int socket_connect()
{
    return -1;
}


int   socket_accept( int sockfd, int (*onconnect_cb)( int new_fd, struct sockaddr * client_addr, socklen_t sockaddr_size ) )
{
    //TODO : handle a table here because we pass a pointer to child process
    // BUG here until then.
    int new_fd; //new connection on new_fd
    struct sockaddr_storage their_addr; // connector's address information
    socklen_t sin_size;
    char s[INET6_ADDRSTRLEN];

    while (1)   // main accept() loop
    {
        sin_size = sizeof their_addr;
        new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);
        if (new_fd == -1)
        {
            perror("accept");
            continue;
        }

        inet_ntop(their_addr.ss_family,
                  get_in_addr((struct sockaddr *)&their_addr),
                  s, sizeof s);
        printf("server: got connection from %s\n", s);

        if (!fork())   // this is the child process
        {
            close(sockfd); // child doesn't need the listener

            onconnect_cb( new_fd, (struct sockaddr *) &their_addr, sin_size);
            exit(0);
        }
        close(new_fd);  // parent doesn't need this
    }

}


int socket_on_connect_cb( int new_fd, struct sockaddr * client_addr, socklen_t sockaddr_size )
{
    char s[INET6_ADDRSTRLEN];

    inet_ntop(client_addr->sa_family,
              get_in_addr(client_addr),
              s, sizeof s);
    printf("server: child process for connection from %s\n", s);

    if (send(new_fd, "Hello, world!", 13, 0) == -1)
        perror("send");

    close(new_fd);

    return 0;
}










#endif
