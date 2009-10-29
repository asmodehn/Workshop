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

#define PORT "3490"  /* the port users will be connecting to */

#define BACKLOG 10     /* how many pending connections queue will hold */

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

int main_server(void)
{
    int sockfd;  // listen on sock_fd,
    //struct addrinfo hints, *servinfo, *p;
    struct addrinfo *servinfo, *p;

    /*struct sockaddr_storage their_addr;*/ /* connector's address information */
    /*socklen_t sin_size;
    struct sigaction sa;*/
    /*int yes=1;*/
    /*char s[INET6_ADDRSTRLEN];*/


    /*
        memset(&hints, 0, sizeof hints);
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = AI_PASSIVE; // use my IP

        if ((rv = getaddrinfo(NULL, PORT, &hints, &servinfo)) != 0) {
            fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
            return 1;
        }
    */
    setup_addrinfo( &servinfo, NULL, PORT, AI_PASSIVE, AF_UNSPEC, SOCK_STREAM);

    // loop through all the results and bind to the first we can
    for (p = servinfo; p != NULL; p = p->ai_next)
    {

        sockfd = create_socket( p->ai_family, p->ai_socktype, p->ai_protocol);


        /*
             if ((sockfd = socket(p->ai_family, p->ai_socktype,
                     p->ai_protocol)) == -1) {
                 perror("server: socket");
                 continue;
             }

             if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
                     sizeof(int)) == -1) {
                 perror("setsockopt");
                 exit(1);
             }

             if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
                 close(sockfd);
                 perror("server: bind");
                 continue;
             }
        */

        socket_listen(sockfd, p->ai_addr, p->ai_addrlen, BACKLOG);

        break;
    }

    if (p == NULL)
    {
        fprintf(stderr, "server: failed to bind\n");
        return 2;
    }

    freeaddrinfo(servinfo); // all done with this structure
    /*
                if (listen(sockfd, BACKLOG) == -1) {
                    perror("listen");
                    exit(1);
                }

                sa.sa_handler = sigchld_handler; // reap all dead processes
                sigemptyset(&sa.sa_mask);
                sa.sa_flags = SA_RESTART;
                if (sigaction(SIGCHLD, &sa, NULL) == -1) {
                    perror("sigaction");
                    exit(1);
                }

                printf("server: waiting for connections...\n");
            */

    /*
        while(1) {  // main accept() loop
            sin_size = sizeof their_addr;
            new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);
            if (new_fd == -1) {
                perror("accept");
                continue;
            }

            inet_ntop(their_addr.ss_family,
                get_in_addr((struct sockaddr *)&their_addr),
                s, sizeof s);
            printf("server: got connection from %s\n", s);

            if (!fork()) { // this is the child process
                close(sockfd); // child doesn't need the listener
                if (send(new_fd, "Hello, world!", 13, 0) == -1)
                    perror("send");
                close(new_fd);
                exit(0);
            }
            close(new_fd);  // parent doesn't need this
        }
    */
    socket_accept(sockfd, &socket_on_connect_cb);

    return 0;
}


/*
** client.c -- a stream socket client demo
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>

#include <arpa/inet.h>

#define PORT "3490" // the port client will be connecting to

#define MAXDATASIZE 100 // max number of bytes we can get at once

int main_client(int argc, char *argv[])
{
    int sockfd, numbytes;
    char buf[MAXDATASIZE];
    struct addrinfo hints, *servinfo, *p;
    int rv;
    char s[INET6_ADDRSTRLEN];

    if (argc != 2)
    {
        fprintf(stderr,"usage: client hostname\n");
        exit(1);
    }

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if ((rv = getaddrinfo(argv[1], PORT, &hints, &servinfo)) != 0)
    {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and connect to the first we can
    for (p = servinfo; p != NULL; p = p->ai_next)
    {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                             p->ai_protocol)) == -1)
        {
            perror("client: socket");
            continue;
        }

        if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1)
        {
            close(sockfd);
            perror("client: connect");
            continue;
        }

        break;
    }

    if (p == NULL)
    {
        fprintf(stderr, "client: failed to connect\n");
        return 2;
    }

    inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr),
              s, sizeof s);
    printf("client: connecting to %s\n", s);

    freeaddrinfo(servinfo); // all done with this structure

    if ((numbytes = recv(sockfd, buf, MAXDATASIZE-1, 0)) == -1)
    {
        perror("recv");
        exit(1);
    }

    buf[numbytes] = '\0';

    printf("client: received '%s'\n",buf);

    close(sockfd);

    return 0;
}




int main (int argc, char *argv[])
{
    int i;

    /* parcourir les arguments */
    for (i = 1; i != argc; ++i)
    {
        /* si le premier caractère de l'argument est '-'... */
        if (argv[i][0] == '-')
        {
            /* ...c'est une option. */
            char* popt;

            /* parcourir les caractères de l'option */
            for (popt = &argv[i][1]; *popt != '\0'; ++popt)
            {
                switch (*popt)
                {
                case 'a':
                    /*option a*/
                    break ;
                case 'b':
                    /*option b*/
                    break ;
                default :
                    /*option inconnue*/
                    break;
                }
            }
        }
        else
        {
            /* ...c'est un argument */
            if ( strcmp( argv[i], "client" ) == 0 )
            {
                main_client(argc, argv);
            }
            else
            {
                //if ( strcmp ( argv[i] , "server" ) == 0 )
                main_server();
            }
        }
    }
    return 0;
}
