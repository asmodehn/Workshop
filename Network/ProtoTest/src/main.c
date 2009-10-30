
#include "prototest.h"

#define PORT "3490"  /* the port users will be connecting to */

#define BACKLOG 10     /* how many pending connections queue will hold */

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
    /*int rv;*/
    char s[INET6_ADDRSTRLEN];

    if (argc != 2)
    {
        fprintf(stderr,"usage: client hostname\n");
        exit(1);
    }

    setup_addrinfo(  &servinfo, argv[1], PORT, 0, AF_UNSPEC, SOCK_STREAM);
    /*

        memset(&hints, 0, sizeof hints);
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;

        if ((rv = getaddrinfo(argv[1], PORT, &hints, &servinfo)) != 0)
        {
            fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
            return 1;
        }
    */
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
